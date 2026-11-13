export const MOD_LABEL = "herdr.mod";
export const MOD_NAME = "command-float";
export const COMMAND_LABEL = "command-float.command";
export const CONTEXT_LABEL = "command-float.context";
export const SPACE_LABEL = "command-float.space";
export const HERDR_SPACE_LABEL = "herdr.space";
export const IDLE_LIMIT_MS = 30 * 60 * 1000;

export function stripJsonc(text) {
  let out = "", i = 0, inString = false, escaped = false;
  while (i < text.length) {
    const c = text[i], next = text[i + 1];
    if (inString) {
      out += c;
      if (escaped) escaped = false;
      else if (c === "\\") escaped = true;
      else if (c === '"') inString = false;
      i++;
      continue;
    }
    if (c === '"') { inString = true; out += c; i++; continue; }
    if (c === "/" && next === "/") {
      out += "  "; i += 2;
      while (i < text.length && text[i] !== "\n") { out += " "; i++; }
      continue;
    }
    if (c === "/" && next === "*") {
      out += "  "; i += 2;
      while (i < text.length && !(text[i] === "*" && text[i + 1] === "/")) {
        out += text[i] === "\n" || text[i] === "\r" ? text[i] : " "; i++;
      }
      if (i < text.length) { out += "  "; i += 2; }
      continue;
    }
    out += c; i++;
  }
  let result = "", string = false, escape = false;
  for (let j = 0; j < out.length; j++) {
    const c = out[j];
    if (string) {
      result += c;
      if (escape) escape = false;
      else if (c === "\\") escape = true;
      else if (c === '"') string = false;
      continue;
    }
    if (c === '"') { string = true; result += c; continue; }
    if (c === ",") {
      let k = j + 1;
      while (k < out.length && /\s/.test(out[k])) k++;
      if (out[k] === "}" || out[k] === "]") continue;
    }
    result += c;
  }
  return result;
}

export function validKey(value) {
  if (typeof value !== "string") return false;
  const parts = value.split("-"), tail = parts.pop();
  return typeof tail === "string" && (/^[a-z0-9]$/.test(tail) || ["left", "right", "up", "down", "space", "enter"].includes(tail))
    && parts.length > 0 && parts.every(p => ["ctrl", "cmd", "alt", "shift"].includes(p))
    && parts.some(p => ["ctrl", "cmd", "alt"].includes(p));
}

export function parseConfig(text) {
  let raw;
  try { raw = JSON.parse(stripJsonc(text ?? "")); }
  catch { throw new Error("config.jsonc is not valid JSONC."); }
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) throw new Error("config.jsonc must contain an object.");
  if (raw.paletteKey !== false && raw.paletteKey != null && !validKey(raw.paletteKey)) throw new Error('"paletteKey" must be false or a shortcut like "cmd-alt-p".');
  if (!Array.isArray(raw.commands)) throw new Error('config.jsonc: "commands" must be an array.');
  const ids = new Set();
  const commands = raw.commands.map((entry, index) => {
    const where = `commands[${index}]`;
    if (!entry || typeof entry !== "object" || Array.isArray(entry)) throw new Error(`${where} must be an object.`);
    if (typeof entry.id !== "string" || !/^[a-z][a-z0-9-]*$/.test(entry.id)) throw new Error(`${where}.id must use lowercase letters, digits and dashes.`);
    if (ids.has(entry.id)) throw new Error(`Duplicate command id: ${entry.id}.`);
    ids.add(entry.id);
    if (typeof entry.label !== "string" || !entry.label.trim()) throw new Error(`${where}.label is required.`);
    if (typeof entry.command !== "string" || !entry.command.trim()) throw new Error(`${where}.command is required.`);
    if (entry.args != null && (!Array.isArray(entry.args) || entry.args.some(a => typeof a !== "string"))) throw new Error(`${where}.args must be an array of strings.`);
    if (entry.cwd != null && !["focused", "repo"].includes(entry.cwd)) throw new Error(`${where}.cwd must be "focused" or "repo".`);
    for (const field of ["width", "height"]) {
      if (entry[field] != null && (typeof entry[field] !== "number" || entry[field] < 0.2 || entry[field] > 1)) throw new Error(`${where}.${field} must be between 0.2 and 1.`);
    }
    if (entry.key != null && !validKey(entry.key)) throw new Error(`${where}.key is not a supported shortcut.`);
    if (entry.machines != null && (!entry.machines || typeof entry.machines !== "object" || Array.isArray(entry.machines)
      || Object.values(entry.machines).some(value => typeof value !== "string" || !value.trim()))) {
      throw new Error(`${where}.machines must map machine names to executable paths.`);
    }
    return {
      id: entry.id,
      label: entry.label.trim(),
      command: entry.command.trim(),
      args: entry.args ?? [],
      cwd: entry.cwd ?? "focused",
      key: entry.key ?? null,
      width: entry.width ?? 0.9,
      height: entry.height ?? 0.9,
      machines: entry.machines ?? {},
    };
  });
  return { paletteKey: raw.paletteKey === undefined ? "cmd-alt-p" : raw.paletteKey, commands };
}

export function normalizeRoot(path, lowercase) {
  let root = path.trim().replace(/\\/g, "/");
  while (root.length > 1 && root.endsWith("/") && !/^[A-Za-z]:\/$/.test(root)) root = root.slice(0, -1);
  return lowercase ? root.toLowerCase() : root;
}

export function firstLine(text) {
  return text.split(/\r?\n/).map(line => line.trim()).find(Boolean) ?? null;
}

export function machineOf(address) {
  const slash = address.indexOf("/");
  return slash === -1 ? null : address.slice(0, slash);
}

function isOwnedLive(terminal) {
  const labels = terminal.labels ?? {};
  return terminal.state === "live" && labels[MOD_LABEL] === MOD_NAME && labels[HERDR_SPACE_LABEL] == null;
}

export function findInstance(terminals, command, context, space) {
  return terminals.find(t => isOwnedLive(t) && t.labels[COMMAND_LABEL] === command
    && t.labels[CONTEXT_LABEL] === context && t.labels[SPACE_LABEL] === space) ?? null;
}

export function planCleanup({ terminals, spaceIds, readyMachines, hiddenAt, keep, now }) {
  const spaces = new Set(spaceIds), ready = new Set(readyMachines), kill = [], next = {};
  for (const terminal of terminals.filter(isOwnedLive)) {
    const { address } = terminal;
    if (!ready.has(machineOf(address))) {
      if (hiddenAt[address] != null) next[address] = hiddenAt[address];
    } else if (spaces.size > 0 && !spaces.has(terminal.labels[SPACE_LABEL])) {
      kill.push(address);
    } else if (address === keep) {
      continue;
    } else if (hiddenAt[address] == null) {
      next[address] = now;
    } else if (now - hiddenAt[address] >= IDLE_LIMIT_MS) {
      kill.push(address);
    } else {
      next[address] = hiddenAt[address];
    }
  }
  return { kill, hiddenAt: next };
}

/** Apply configured shortcuts without replacing unrelated user bindings. */
export function mergeKeys(text, config) {
  const original = JSON.parse(text);
  if (!original || typeof original !== "object" || Array.isArray(original)) throw new Error("keys.json must contain an object.");
  const obj = JSON.parse(JSON.stringify(original));
  for (const section of Object.values(obj)) {
    if (!section || typeof section !== "object" || Array.isArray(section)) continue;
    for (const [key, action] of Object.entries(section)) {
      if (String(action).startsWith(`${MOD_NAME}.`) || action === `mod.open:${MOD_NAME}`) delete section[key];
    }
  }
  for (const name of ["global", "terminal"]) {
    if (obj[name] == null) obj[name] = {};
    if (!obj[name] || typeof obj[name] !== "object" || Array.isArray(obj[name])) throw new Error(`keys.json: "${name}" must be an object.`);
  }
  const conflicts = [];
  const bind = (key, action) => {
    if (!key) return;
    const existing = obj.global[key] ?? obj.terminal[key];
    if (existing && existing !== action) {
      conflicts.push(`${key} → ${existing}`);
      return;
    }
    obj.global[key] = action;
    obj.terminal[key] = action;
  };
  bind(config.paletteKey, `mod.open:${MOD_NAME}`);
  for (const command of config.commands) bind(command.key, `${MOD_NAME}.${command.id}`);
  const merged = JSON.stringify(obj, null, 2) + "\n";
  return { text: JSON.stringify(original) === JSON.stringify(obj) ? text : merged, conflicts, changed: merged !== text && JSON.stringify(original) !== JSON.stringify(obj) };
}
