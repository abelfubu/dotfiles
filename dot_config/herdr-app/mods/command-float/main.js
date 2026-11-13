import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import {
  exec, hc, appHome, focused, machines, spaces, openOverlay, closeOverlay, notify,
  props, shared, setShared, readTextFile, window as app, writeTextFile, nextCommand, theme, run,
} from "herdr";
import {
  MOD_LABEL, MOD_NAME, COMMAND_LABEL, CONTEXT_LABEL, SPACE_LABEL,
  normalizeRoot, firstLine, findInstance, planCleanup, parseConfig, mergeKeys,
} from "./model.js";

// Derived from lazygit-herdr (MIT, Copyright 2026 Nico Mayer), generalized
// from one repo-scoped program to configurable commands and contexts.
const MEMORY = "__command_float_v1";
const STATE_KEY = "command-float.v1";
const LEASE_MS = 15000;

function memory() {
  return globalThis[MEMORY] ??= { dialog: null, lease: null, paths: {} };
}

async function claim(cx, owner) {
  const mem = memory();
  while (mem.lease && mem.lease.owner !== owner && Date.now() - mem.lease.at < LEASE_MS) await cx.sleep(15);
  mem.lease = { owner, at: Date.now() };
}

function release(owner) {
  const mem = memory();
  if (mem.lease?.owner === owner) mem.lease = null;
}

class Problem extends Error {
  constructor(level, title, body) {
    super(body);
    this.level = level;
    this.title = title;
  }
}

function coreError(result) {
  try { return JSON.parse(result.stderr).error.message; }
  catch { return result.stderr.trim() || `exit ${result.code}`; }
}

async function hcJSON(args, what) {
  const [command, ...rest] = args;
  const result = await hc([command, "--json", ...rest]);
  if (result.code !== 0) throw new Error(`${what}: ${coreError(result)}`);
  return JSON.parse(result.stdout);
}

async function listInstances() {
  const data = await hcJSON(["ls", "--label", `${MOD_LABEL}=${MOD_NAME}`], "List command terminals");
  const details = await Promise.all((data.terminals ?? []).map(async terminal => {
    try {
      const info = await hcJSON(["get", terminal.address], "Read terminal");
      return { address: terminal.address, state: info.state ?? terminal.state, labels: info.labels ?? {} };
    } catch { return null; }
  }));
  return details.filter(Boolean);
}

function readHidden() { return shared(STATE_KEY)?.hiddenAt ?? {}; }
function writeHidden(hiddenAt) {
  if (JSON.stringify(hiddenAt) !== JSON.stringify(readHidden())) setShared(STATE_KEY, { hiddenAt });
}
function markHidden(address) { writeHidden({ ...readHidden(), [address]: Date.now() }); }

async function cleanup(terminals, keep) {
  const plan = planCleanup({
    terminals,
    spaceIds: spaces().map(s => s.id),
    readyMachines: machines().filter(m => m.layout === "ready").map(m => m.name),
    hiddenAt: readHidden(),
    keep,
    now: Date.now(),
  });
  writeHidden(plan.hiddenAt);
  await Promise.all(plan.kill.map(address => hc(["kill", address])));
}

async function readConfig() {
  try { return parseConfig(await readTextFile(`${appHome()}/mods/${MOD_NAME}/config.jsonc`)); }
  catch (error) { throw new Problem("error", "Command Float settings", error.message); }
}

async function syncKeys(config) {
  const path = `${appHome()}/keys.json`;
  const current = await readTextFile(path);
  const merged = mergeKeys(current, config);
  if (merged.conflicts.length) {
    notify({
      title: "Command Float shortcut conflicts",
      body: `Not replaced: ${merged.conflicts.join(", ")}`,
      level: "warning",
    });
  }
  if (merged.changed) await writeTextFile(path, merged.text, current);
}

function where(machine) { return machine ?? "this computer"; }

async function execOn(machine, command, args, missing) {
  try { return await exec(command, args, { on: machine }); }
  catch {
    if (machine) throw new Problem("error", `${command} failed on ${machine}`, `Could not run ${command} on ${machine}. Is it installed, and is the machine online?`);
    throw missing;
  }
}

async function findExecutable(definition, machine, localWindows) {
  const configured = definition.machines[machine ?? ""];
  if (configured) return { path: configured, configured: true };
  const paths = memory().paths;
  const key = `${machine ?? ""}\n${definition.command}`;
  if (paths[key]) return { path: paths[key], configured: false };
  const missing = new Problem("error", `${definition.label} not installed`,
    `${definition.command} was not found on ${where(machine)}. Install it, or set machines.${machine ?? ""} in ${MOD_NAME}/config.jsonc.`);
  const result = localWindows
    ? await execOn(machine, "where.exe", [definition.command], missing)
    : await execOn(machine, "sh", ["-c", 'command -v "$1"', "sh", definition.command], missing);
  const path = result.code === 0 ? firstLine(result.stdout) : null;
  if (!path) throw missing;
  paths[key] = path;
  return { path, configured: false };
}

async function repoRoot(machine, cwd, lowercase) {
  const missing = new Problem("error", "git not installed", `git was not found on ${where(machine)}.`);
  const result = await execOn(machine, "git", ["-C", cwd, "rev-parse", "--show-toplevel"], missing);
  const raw = result.code === 0 ? firstLine(result.stdout) : null;
  if (!raw) throw new Problem("warning", "Not a git repo", `${cwd} is not inside a git repository.`);
  return { raw, key: normalizeRoot(raw, lowercase) };
}

async function locate(definition) {
  const now = focused();
  const space = spaces().find(s => s.id === now?.space);
  if (!now || !space) throw new Problem("warning", "No active pane", "Focus a terminal pane and try again.");
  if (!now.cwd) throw new Problem("warning", "Folder unknown", "The active pane has no known folder.");
  const machine = space.machine;
  const localWindows = machine == null && app().platform === "windows";
  let root = { raw: now.cwd, key: normalizeRoot(now.cwd, localWindows) };
  if (definition.cwd === "repo") root = await repoRoot(machine, now.cwd, localWindows);
  return { space: space.id, machine, localWindows, root, previousPane: now.pane };
}

async function start(target, definition) {
  const executable = await findExecutable(definition, target.machine, target.localWindows);
  const result = await hc([
    "run", "--json", "--bg", "--rm", "--no-parent",
    ...(target.machine ? ["--on", target.machine] : []),
    "--cwd", target.root.raw,
    "--label", `${MOD_LABEL}=${MOD_NAME}`,
    "--label", `${COMMAND_LABEL}=${definition.id}`,
    "--label", `${CONTEXT_LABEL}=${target.root.key}`,
    "--label", `${SPACE_LABEL}=${target.space}`,
    "--", executable.path, ...definition.args,
  ]);
  if (result.code === 0) return JSON.parse(result.stdout).address;
  if (executable.configured) {
    throw new Problem("error", `${definition.label} did not start`,
      `${executable.path} could not start: ${coreError(result)}`);
  }
  delete memory().paths[`${target.machine ?? ""}\n${definition.command}`];
  throw new Error(`Start ${definition.label}: ${coreError(result)}`);
}

function dialogSpec(address) {
  return {
    kind: "dialog", width: 0.9, height: 0.9,
    layout: {
      type: "column",
      children: [
        { type: "block", size: { px: 0 }, content: { mod: MOD_NAME, props: { role: "sentinel", terminal: address } } },
        { type: "block", content: { terminal: address } },
      ],
    },
  };
}

function hide(dialog) {
  memory().dialog = null;
  markHidden(dialog.terminal);
  closeOverlay(dialog.overlay);
  if (dialog.previousPane) run("pane.focus", { pane: dialog.previousPane });
}

function show(target, definition, address) {
  const overlay = openOverlay({
    ...dialogSpec(address),
    width: definition.width,
    height: definition.height,
  });
  memory().dialog = { overlay, terminal: address, previousPane: target.previousPane, command: definition.id };
}

async function toggle(definition) {
  const dialog = memory().dialog;
  if (dialog) {
    hide(dialog);
    if (dialog.command === definition.id) {
      await cleanup(await listInstances(), null);
      return;
    }
  }
  const [terminals, located] = await Promise.all([
    listInstances(),
    locate(definition).then(target => ({ target }), problem => ({ problem })),
  ]);
  const { target, problem } = located;
  if (problem) {
    await cleanup(terminals, null);
    throw problem;
  }
  const existing = findInstance(terminals, definition.id, target.root.key, target.space);
  const address = existing?.address ?? await start(target, definition);
  show(target, definition, address);
  await cleanup(terminals, address);
}

async function runToggle(definition, owner, cx) {
  try {
    await claim(cx, owner);
    await toggle(definition);
  } catch (error) {
    const isProblem = error instanceof Problem;
    notify({
      title: isProblem ? error.title : definition.label,
      body: String(error?.message ?? error),
      level: isProblem ? error.level : "error",
    });
  } finally {
    release(owner);
  }
}

async function pickerRunner(owner, cx) {
  try {
    const config = await readConfig();
    const height = Math.min(500, 120 + config.commands.length * 54);
    openOverlay({
      mod: MOD_NAME,
      props: { role: "picker", commands: config.commands },
      kind: "dialog", width: 440, height,
    });
  } catch (error) {
    notify({ title: "Command Float", body: String(error?.message ?? error), level: "error" });
  } finally {
    closeOverlay(owner);
  }
}

export default class CommandFloat extends View {
  init(_props, cx) {
    this.copy = props() ?? {};
    this.handle = cx.focus_handle();
    this.pickerIndex = 0;
    this.config = { paletteKey: false, commands: [] };
    this.configLoaded = false;
    if (this.copy.role === "sentinel") return;
    if (this.copy.role === "picker") {
      this.handle.focus();
      return;
    }
    if (this.copy.overlay) {
      cx.spawn(cx => pickerRunner(this.copy.overlay, cx));
      return;
    }
    // Checks instantiate the docked copy without a window. Keep them free of
    // filesystem writes, processes and keybinding changes.
    if (!app()) return;
    cx.spawn(async cx => {
      try {
        this.config = await readConfig();
        await syncKeys(this.config);
      } catch (error) {
        notify({ title: "Command Float", body: String(error?.message ?? error), level: "error" });
      }
      this.configLoaded = true;
      cx.notify();
    });
    cx.spawn(async cx => {
      for (;;) {
        const id = await nextCommand();
        while (!this.configLoaded) await cx.sleep(20);
        const definition = this.config.commands.find(command => command.id === id);
        if (definition) await runToggle(definition, "docked", cx);
      }
    });
  }

  async close() {
    if (this.copy.role !== "sentinel") return;
    const mem = memory();
    if (mem.dialog?.overlay === this.copy.overlay) mem.dialog = null;
    markHidden(this.copy.terminal);
  }

  pick(definition, cx) {
    const overlay = this.copy.overlay;
    closeOverlay(overlay);
    cx.spawn(cx => runToggle(definition, `picker-${overlay}`, cx));
  }

  renderPicker() {
    const t = theme();
    const commands = this.copy.commands ?? [];
    return v_flex().id("command-float-picker").track_focus(this.handle)
      .w_full().min_h(0).p(14).gap(8).bg(t.popover).text_color(t.foreground)
      .on_key_down((event, cx) => {
        if (["down", "arrowdown"].includes(event.key)) this.pickerIndex = Math.min(commands.length - 1, this.pickerIndex + 1);
        else if (["up", "arrowup"].includes(event.key)) this.pickerIndex = Math.max(0, this.pickerIndex - 1);
        else if (event.key === "enter" && commands[this.pickerIndex]) this.pick(commands[this.pickerIndex], cx);
        else if (event.key === "escape") closeOverlay(this.copy.overlay);
        else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(h_flex().items_center()
        .child(div().flex_1().text_size(15).font_semibold().child("Run a command"))
        .child(div().text_size(11).text_color(t.dim).child("↑↓ Enter · Esc")))
      .child(commands.length ? v_flex().gap(4).children(commands.map((command, index) =>
        h_flex().id(`command-${command.id}`).items_center().gap(12).p(10).rounded(5)
          .bg(index === this.pickerIndex ? t.selected : t.raised)
          .cursor_pointer().hover(state => state.bg(t.hover))
          .on_hover((hovered, cx) => {
            if (hovered) { this.pickerIndex = index; cx.notify(); }
          })
          .on_click((_event, cx) => this.pick(command, cx))
          .child(v_flex().flex_1().gap(2)
            .child(div().text_size(13).font_medium().child(command.label))
            .child(div().text_size(10).text_color(t.dim).truncate()
              .child([command.command, ...command.args].join(" ") + ` · ${command.cwd === "repo" ? "repository" : "focused folder"}`)))
          .child(div().text_size(10).text_color(t.muted).child(command.key ?? ""))))
        : div().p(12).text_size(12).text_color(t.muted).child("No commands configured."));
  }

  render() {
    return this.copy.role === "picker" ? this.renderPicker() : div().w(0).h(0);
  }
}
