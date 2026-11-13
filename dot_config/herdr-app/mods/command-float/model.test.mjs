import test from "node:test";
import assert from "node:assert/strict";
import {
  parseConfig, stripJsonc, validKey, normalizeRoot, findInstance, planCleanup, mergeKeys,
  MOD_LABEL, MOD_NAME, COMMAND_LABEL, CONTEXT_LABEL, SPACE_LABEL,
} from "./model.js";

const example = `{
  // comment
  "paletteKey": "cmd-alt-p",
  "commands": [{
    "id": "lazygit", "label": "Lazygit", "command": "lazygit",
    "cwd": "repo", "key": "ctrl-shift-g", "args": [],
  }],
}`;

test("JSONC preserves comment markers in strings and accepts trailing commas", () => {
  const config = parseConfig(example);
  assert.equal(config.commands[0].id, "lazygit");
  assert.equal(config.commands[0].cwd, "repo");
  assert.match(stripJsonc('{"x":"https://example.test/*literal*/"}'), /https:\/\/example\.test\/\*literal\*\//);
});

test("config supplies defaults and direct args", () => {
  const config = parseConfig('{"commands":[{"id":"yazi","label":"Yazi","command":"yazi","args":["--debug"]}]}');
  assert.equal(config.paletteKey, "cmd-alt-p");
  assert.deepEqual(config.commands[0].args, ["--debug"]);
  assert.equal(config.commands[0].width, 0.9);
});

test("config rejects duplicates, compound cwd and bad keys", () => {
  assert.throws(() => parseConfig('{"commands":[{"id":"x","label":"X","command":"x","cwd":"~"}]}'), /cwd/);
  assert.throws(() => parseConfig('{"commands":[{"id":"x","label":"X","command":"x","key":"g"}]}'), /key/);
  const duplicate = '{"commands":[{"id":"x","label":"X","command":"x"},{"id":"x","label":"Y","command":"y"}]}';
  assert.throws(() => parseConfig(duplicate), /Duplicate/);
});

test("shortcut validation requires a real modifier", () => {
  assert.equal(validKey("ctrl-shift-g"), true);
  assert.equal(validKey("cmd-alt-p"), true);
  assert.equal(validKey("shift-g"), false);
  assert.equal(validKey("ctrl-alt-delete"), false);
});

test("paths normalize per platform", () => {
  assert.equal(normalizeRoot("/tmp/repo///", false), "/tmp/repo");
  assert.equal(normalizeRoot("C:\\Repo\\", true), "c:/repo");
});

test("instance identity includes command, context and space", () => {
  const labels = { [MOD_LABEL]: MOD_NAME, [COMMAND_LABEL]: "lazygit", [CONTEXT_LABEL]: "/repo", [SPACE_LABEL]: "s1" };
  const terminals = [{ address: "work/t2", state: "live", labels }];
  assert.equal(findInstance(terminals, "lazygit", "/repo", "s1").address, "work/t2");
  assert.equal(findInstance(terminals, "yazi", "/repo", "s1"), null);
  assert.equal(findInstance(terminals, "lazygit", "/other", "s1"), null);
});

test("cleanup keeps the shown process and expires hidden ones", () => {
  const labels = { [MOD_LABEL]: MOD_NAME, [SPACE_LABEL]: "s1" };
  const terminals = [
    { address: "t1", state: "live", labels },
    { address: "work/t2", state: "live", labels },
  ];
  const plan = planCleanup({ terminals, spaceIds: ["s1"], readyMachines: [null, "work"], hiddenAt: { "work/t2": 0 }, keep: "t1", now: 31 * 60 * 1000 });
  assert.deepEqual(plan.kill, ["work/t2"]);
  assert.deepEqual(plan.hiddenAt, {});
});

test("key merge manages global and terminal bindings idempotently", () => {
  const config = parseConfig(example);
  const initial = '{"global":{"cmd-p":"app.palette"},"terminal":{"cmd-c":"terminal.copy"}}';
  const first = mergeKeys(initial, config);
  assert.equal(first.conflicts.length, 0);
  const parsed = JSON.parse(first.text);
  assert.equal(parsed.global["ctrl-shift-g"], "command-float.lazygit");
  assert.equal(parsed.terminal["ctrl-shift-g"], "command-float.lazygit");
  assert.equal(parsed.global["cmd-p"], "app.palette");
  assert.equal(mergeKeys(first.text, config).changed, false);
});

test("key merge skips unrelated conflicts and removes stale managed bindings", () => {
  const config = parseConfig(example);
  const initial = '{"global":{"ctrl-shift-g":"other.action","ctrl-shift-y":"command-float.old"},"terminal":{}}';
  const merged = mergeKeys(initial, config);
  assert.equal(merged.conflicts.length, 1);
  const parsed = JSON.parse(merged.text);
  assert.equal(parsed.global["ctrl-shift-g"], "other.action");
  assert.equal(parsed.global["ctrl-shift-y"], undefined);
  assert.equal(parsed.global["cmd-alt-p"], "mod.open:command-float");
});
