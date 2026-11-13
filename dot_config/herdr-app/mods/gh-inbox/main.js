// Your pull requests, the Trunk merge queue and your review requests, as tabs
// you can drag into any order. Data comes from the `gh` and `trunk` CLIs.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { theme, run, props, openOverlay, nextCommand, notify, focused, exec, spaces, shared, setShared, readTextFile, appHome } from "herdr";
import { TRUNK_REPO, TrunkUnavailable, login, searchPrs, stacks, queue, queueItem, testRun, enqueue, dequeue } from "./data.js";
import { startPi } from "./pi.js";
import { parseJsonc } from "./jsonc.js";

const ICON = (name) => `mods/gh-inbox/icons/${name}.svg`;
const GH_EVERY = 60000;
const TRUNK_EVERY = 45000;
// `trunk merge status` lists at most this many items per state.
const LISTING_CAP = 10;
const capped = (n) => (n >= LISTING_CAP ? `${n}+` : String(n));

async function pool(items, size, fn) {
  const out = new Array(items.length);
  let next = 0;
  const worker = async () => {
    while (next < items.length) {
      const k = next++;
      out[k] = await fn(items[k]).catch((e) => ({ failed: String(e?.message ?? e) }));
    }
  };
  await Promise.all(Array.from({ length: Math.min(size, items.length) }, worker));
  return out;
}

const VIEWS = {
  mine: { label: "Mine", icon: "pr", queries: ["author:@me"] },
  review: { label: "Review", icon: "eye", queries: ["review-requested:@me -author:@me"] },
  queue: { label: "Queue", icon: "queue" },
  list: { label: "Pull requests", icon: "pr" },
};

function ago(ms) {
  const m = Math.floor(Math.max(0, ms) / 60000);
  if (m < 1) return "now";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  return h < 24 ? `${h}h` : `${Math.floor(h / 24)}d`;
}

const ordinal = (n) => `${n}${n % 10 === 1 && n % 100 !== 11 ? "st" : n % 10 === 2 && n % 100 !== 12 ? "nd" : n % 10 === 3 && n % 100 !== 13 ? "rd" : "th"}`;
const plural = (n, word) => `${n} ${word}${n === 1 ? "" : "s"}`;

// Theme colors for each kind of state, so the panel follows the theme.
function palette(t) {
  return { ok: t.ansi2, bad: t.ansi1, warn: t.ansi3, run: t.working ?? t.ansi4, merged: t.ansi5, dim: t.dim, muted: t.muted, accent: t.accent };
}

// Visual review runs with changes waiting for a person to approve.
const visualAsks = (pr) => (pr.visual ?? []).filter((v) => v.kind === "approve");

function visualStep(pr, p) {
  const asks = visualAsks(pr);
  if (!asks.length) return null;
  const v = asks[0];
  return { icon: "eye", color: p.warn, label: `Visuals: ${v.summary}`, url: v.url };
}

// The stack-depth check is the PR's only failure (see markStackDepth in data.js).
function stackStep(pr, p) {
  if (!pr.stack) return null;
  const { checked, detail, url } = pr.stack;
  return { icon: "stack", color: p.warn, label: checked ? "Stack too deep" : "Stack depth not checked", url, tip: detail || "Open the stack depth check" };
}

export default class GhInbox extends View {
  init(_props, cx) {
    const allowed = props()?.tabs;
    this.sections = [];
    this.sectionItems = new Map();
    this.configureSections(null);
    this.folded = new Set(JSON.parse(localStorage.getItem("folded") ?? '["review:teams","queue:merged"]'));
    this.known = new Set(JSON.parse(localStorage.getItem("known") ?? "[]"));
    this.notifies = props()?.notify ?? !allowed;

    this.me = null;
    this.mine = null;
    this.reviews = null;
    this.queue = null;
    this.items = new Map();
    this.mineQueue = null;
    this.runs = new Map();
    this.errors = {};
    this.fails = { gh: 0, trunk: 0 };
    this.busy = { gh: false, trunk: false };
    this.configLoaded = false;
    this.seen = null;
    this.width = 268;
    this.handle = cx.focus_handle();
    this.focusId = `${Date.now()}-${Math.random()}`;
    this.hasFocus = false;
    this.selectedKey = null;
    this.actionOpen = false;
    this.actionIndex = 0;
    this.returnPane = null;

    // FocusHandle has no change event; only redraw when its state actually changes.
    cx.timer.every(150, (cx) => {
      const hasFocus = this.handle.is_focused();
      if (hasFocus === this.hasFocus) return;
      this.updateFocus(hasFocus);
      cx.notify();
    });
    cx.timer.every(GH_EVERY, (cx) => this.refreshGh(cx));
    cx.timer.every(TRUNK_EVERY, (cx) => this.refreshTrunk(cx));
    cx.spawn(async (cx) => {
      try {
        const text = await readTextFile(`${appHome()}/mods/gh-inbox/config.jsonc`);
        this.configureSections(parseJsonc(text));
        delete this.errors.config;
      } catch (e) {
        this.errors.config = String(e?.message ?? e);
      }
      this.configLoaded = true;
      this.refreshGh(cx);
      if (this.queueEnabled) this.refreshTrunk(cx);
      cx.notify();
    });

    cx.spawn(async (cx) => {
      for (;;) {
        const c = await nextCommand();
        if (c === "confirmed" && this.pending) await this.act(cx);
        else if (c === "refresh") this.refreshAll(cx);
        else if (c === "focus") {
          this.returnPane = focused()?.pane ?? this.returnPane;
          this.ensureSelection();
          this.handle.focus();
          this.updateFocus(true);
        } else if (c === "next") this.move(1, cx);
        else if (c === "prev") this.move(-1, cx);
        else if (c === "tab-next") this.moveTab(1, cx);
        else if (c === "tab-prev") this.moveTab(-1, cx);
        else if (c === "actions") this.showActions(cx);
        else if (c === "merge") this.runAction("github-merge", cx);
        else if (c === "labels") this.runAction("labels", cx);
        else if (c === "reviewers") this.runAction("reviewers", cx);
        else if (c === "ready") this.runAction("ready", cx);
        else if (c === "approve") this.runAction("approve", cx);
        else if (c === "copy-url") this.runAction("copy", cx);
        else if (c === "diff") this.diffSelected(cx);
        else if (c === "open") this.openSelected(cx);
        else if (c === "escape") this.escape(cx);
        else if (c.startsWith("show-") && this.order.includes(c.slice(5))) this.select(c.slice(5), cx);
        cx.notify();
      }
    });
  }

  configureSections(config) {
    const allowed = props()?.tabs;
    const fallback = (Array.isArray(allowed) && allowed.length ? allowed.filter((id) => VIEWS[id] && id !== "list") : ["mine", "queue", "review"]);
    const source = Array.isArray(config?.sections) && config.sections.length ? config.sections : fallback;
    const used = new Set();
    this.sections = source.map((entry) => typeof entry === "string" ? { id: entry, view: entry } : entry).filter((section) => {
      const view = section?.view ?? (VIEWS[section?.id] && section.id !== "list" ? section.id : "list");
      const queries = Array.isArray(section?.queries) ? section.queries : section?.query != null ? [section.query] : VIEWS[view]?.queries ?? [];
      if (!section || !/^[a-z][a-z0-9-]*$/.test(section.id) || used.has(section.id) || !VIEWS[view]) return false;
      if (view !== "queue" && !queries.some((q) => typeof q === "string" && q.trim())) return false;
      used.add(section.id);
      return true;
    }).map((section) => {
      const view = section.view ?? (VIEWS[section.id] && section.id !== "list" ? section.id : "list");
      const queries = Array.isArray(section.queries) ? section.queries : section.query != null ? [section.query] : VIEWS[view].queries ?? [];
      return {
        id: section.id,
        view,
        label: typeof section.label === "string" && section.label.trim() ? section.label : view === "list" ? section.id : VIEWS[view].label,
        icon: typeof section.icon === "string" ? section.icon : VIEWS[view].icon,
        queries: queries.filter((q) => typeof q === "string" && q.trim()).map((q) => q.trim()),
      };
    });
    this.tabs = Object.fromEntries(this.sections.map((section) => [section.id, section]));
    this.sectionItems = new Map(this.sections.filter((section) => section.view !== "queue").map((section) => [section.id, this.sectionItems?.get(section.id) ?? null]));
    this.tabIds = this.sections.map((section) => section.id);
    this.queueEnabled = this.sections.some((section) => section.view === "queue");
    const saved = JSON.parse(localStorage.getItem("order") ?? "[]");
    this.order = [...saved.filter((id) => this.tabIds.includes(id)), ...this.tabIds.filter((id) => !saved.includes(id))];
    this.tab = this.order.includes(localStorage.getItem("tab")) ? localStorage.getItem("tab") : this.order[0];
  }

  updateFocus(hasFocus) {
    this.hasFocus = hasFocus;
    if (hasFocus) setShared("gh-inbox.keyboard-focus", this.focusId);
    else if (shared("gh-inbox.keyboard-focus") === this.focusId) setShared("gh-inbox.keyboard-focus", null);
  }

  async close(_cx) {
    this.updateFocus(false);
  }

  refreshAll(cx) {
    this.refreshGh(cx);
    if (this.queueEnabled) this.refreshTrunk(cx);
  }

  refreshGh(cx) {
    if (!this.configLoaded || this.busy.gh) return;
    this.busy.gh = true;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        this.me ??= await login();
        const sections = this.sections.filter((section) => section.view !== "queue");
        const results = await Promise.all(sections.map(async (section) => {
          const lists = await Promise.all(section.queries.map((query) => searchPrs(query)));
          const unique = new Map();
          for (const pr of lists.flat()) unique.set(pr.key, pr);
          return [...unique.values()].sort((a, b) => b.updated - a.updated);
        }));
        sections.forEach((section, index) => this.sectionItems.set(section.id, results[index]));
        this.mine = this.sectionItems.get(this.sections.find((section) => section.view === "mine")?.id) ?? null;
        this.reviews = this.sectionItems.get(this.sections.find((section) => section.view === "review")?.id) ?? null;
        for (const p of this.mine ?? []) if (p.repo === TRUNK_REPO) this.known.add(p.number);
        localStorage.setItem("known", JSON.stringify([...this.known].slice(-200)));
        delete this.errors.gh;
        this.fails.gh = 0;
        if (this.queueEnabled && !this.mineQueue) this.refreshTrunk(cx);
        this.announce();
      } catch (e) {
        this.errors.gh = String(e?.message ?? e);
        this.fails.gh++;
      }
      this.busy.gh = false;
      if (!this.errors.gh) this.updated = Date.now();
      cx.notify();
    });
  }

  refreshTrunk(cx) {
    if (!this.configLoaded || !this.queueEnabled || this.busy.trunk) return;
    this.busy.trunk = true;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        this.queue = await queue();
        delete this.errors.trunk;
        this.fails.trunk = 0;
        this.trunkOff = null;
        // The listing is capped per state, so each of your open PRs is asked about directly.
        // Everyone's testing items too while the Queue tab shows, for their progress.
        const open = (this.mine ?? []).filter((m) => m.repo === TRUNK_REPO);
        const numbers = [...new Set([
          ...open.map((m) => m.number),
          ...this.queue.items.filter((i) => this.known.has(i.number) && i.state !== "Merged").map((i) => i.number),
          ...(this.tabs[this.tab]?.view === "queue" ? this.queue.items.filter((i) => i.state === "Testing").map((i) => i.number) : []),
        ])];
        const details = await pool(numbers, 4, (n) => queueItem(n));
        // A lookup that failed keeps the PR's last known state instead of dropping it from the queue.
        this.items = new Map(numbers.map((n, k) => [n, details[k]?.failed ? this.items.get(n) ?? null : details[k]]));
        if (this.mine) {
          const mq = new Map();
          // A cancelled submission is history: the PR is just open again.
          for (const m of open) {
            const k = numbers.indexOf(m.number);
            if (details[k]?.failed && this.mineQueue?.has(m.number)) {
              mq.set(m.number, this.mineQueue.get(m.number));
              continue;
            }
            const d = this.items.get(m.number);
            if (d?.state && d.state !== "Cancelled") mq.set(m.number, { number: m.number, state: d.state, title: m.title });
          }
          for (const i of this.queue.items) if (this.known.has(i.number) && !mq.has(i.number) && !open.some((m) => m.number === i.number)) mq.set(i.number, i);
          this.mineQueue = mq;
        }
        const tests = [...new Set([...this.items.values()].map((d) => d?.testPr).filter(Boolean))];
        const runs = await Promise.all(tests.map((n) => testRun(n).catch(() => null)));
        this.runs = new Map(tests.map((n, k) => [n, runs[k]]));
        this.announce();
      } catch (e) {
        if (e instanceof TrunkUnavailable) {
          // No Trunk here: the queue tab says why, and nothing else mentions it.
          this.trunkOff = e.message;
          this.mineQueue = new Map();
        } else {
          this.errors.trunk = String(e?.message ?? e);
          this.fails.trunk++;
        }
      }
      this.busy.trunk = false;
      cx.notify();
    });
  }

  // The queue entry a PR rides on: its own, or the layer above it that was enqueued for the stack.
  queueFor(pr, group) {
    if (pr.repo !== TRUNK_REPO || !this.mineQueue) return null;
    const find = (n) => this.mineQueue.get(n);
    const own = find(pr.number);
    if (own) return { ...own, via: null };
    if (!group) return null;
    const idx = group.members.findIndex((m) => m.pr.key === pr.key);
    for (const m of group.members.slice(idx + 1)) {
      const hit = find(m.pr.number);
      if (hit) return { ...hit, via: m.pr.number };
    }
    return null;
  }

  // Why a PR can't merge yet, most blocking first.
  blocker(pr, p) {
    if (pr.draft) return { icon: "pr-draft", color: p.dim, label: "Draft" };
    if (pr.conflicts) return { icon: "conflict", color: p.bad, label: "Conflicts" };
    const vr = visualStep(pr, p);
    if (vr) return vr;
    if (pr.checks.fail) return { icon: "fail", color: p.bad, label: `${plural(pr.checks.fail, "check")} failing` };
    const st = stackStep(pr, p);
    if (st) return st;
    if (pr.decision === "CHANGES_REQUESTED") return { icon: "changes", color: p.bad, label: "Changes requested" };
    if (pr.checks.running) return { icon: "spinner", spin: true, color: p.run, label: `CI ${pr.checks.pass}/${pr.checks.total}` };
    if (pr.decision === "REVIEW_REQUIRED") return { icon: "waiting", color: p.warn, label: "Needs review" };
    return null;
  }

  // What happens next for a PR: queue progress first, then what blocks it.
  step(pr, q, p) {
    if (q) {
      const d = this.items.get(q.number);
      const via = q.via ? ` via #${q.via}` : "";
      switch (q.state) {
        case "Merged":
          return { icon: "merged", color: p.merged, label: "Merged" };
        case "Failed":
        case "Pending Failure":
          return { icon: "fail", color: p.bad, label: `Queue ${q.state === "Failed" ? "failed" : "failing"}${via}` };
        case "Cancelled":
          return { icon: "ban", color: p.dim, label: "Removed from queue" };
        case "Tests Passed":
          return { icon: "rocket", color: p.ok, label: "Merging" };
        case "Testing": {
          const r = d?.testPr ? this.runs.get(d.testPr) : null;
          const pct = r?.checks.total ? Math.round(((r.checks.pass + r.checks.fail) / r.checks.total) * 100) : null;
          return { icon: "testing", color: r?.checks.fail ? p.bad : p.run, label: `Testing${pct === null ? "" : ` ${pct}%`}${via}`, progress: r };
        }
        case "Pending": {
          const waiting = this.queue.items.filter((i) => i.state === "Pending");
          const pos = waiting.findIndex((i) => i.number === q.number) + 1;
          return { icon: "hourglass", color: p.accent, label: `${pos > 0 ? `${ordinal(pos)} in line` : `In line, ${LISTING_CAP}+ ahead`}${via}` };
        }
        case "Not Ready": {
          const b = pr ? this.blocker(pr, p) : null;
          return { icon: "paused", color: p.warn, label: `Queued, waiting${b ? `: ${b.label.toLowerCase()}` : ""}${via}` };
        }
      }
    }
    if (!pr) return { icon: "pr", color: p.muted, label: q?.state ?? "" };
    return this.blocker(pr, p) ?? { icon: "check", color: p.ok, label: "Ready to merge" };
  }

  // Posts a notification when one of your PRs changes in a way you'd act on.
  announce() {
    if (!this.notifies || !this.mine) return;
    const now = new Map();
    for (const pr of this.mine) {
      const q = pr.repo === TRUNK_REPO ? this.mineQueue?.get(pr.number) : null;
      now.set(pr.key, { pr, ci: pr.checks.fail ? "fail" : pr.checks.running ? "run" : "ok", decision: pr.decision, queue: q?.state ?? null, visual: visualAsks(pr).length > 0, stack: Boolean(pr.stack) });
    }
    for (const i of this.mineQueue?.values() ?? []) {
      const key = `${TRUNK_REPO}#${i.number}`;
      if (!now.has(key)) now.set(key, { pr: { key, number: i.number, title: i.title, url: `https://github.com/${TRUNK_REPO}/pull/${i.number}` }, queue: i.state });
    }
    const direct = new Set((this.reviews ?? []).filter((r) => r.requested.includes(this.me)).map((r) => r.key));
    if (this.seen) {
      const say = (pr, title, level) => notify({ title, body: `#${pr.number} ${pr.title}`, level, timeout: 8000 });
      for (const [key, s] of now) {
        const was = this.seen.mine.get(key);
        if (!was) continue;
        if (s.queue !== was.queue && s.queue === "Merged") say(s.pr, "Merged", "success");
        else if (s.queue !== was.queue && (s.queue === "Failed" || s.queue === "Cancelled")) say(s.pr, s.queue === "Failed" ? "Merge queue failed" : "Removed from the merge queue", "error");
        if (s.visual && was.visual === false) say(s.pr, "Visual changes to approve", "warning");
        if (s.ci === "fail" && was.ci && was.ci !== "fail" && !s.visual) say(s.pr, "Checks failing", "error");
        if (s.stack && was.stack === false) say(s.pr, "Stack too deep", "warning");
        if (s.decision !== was.decision && s.decision === "APPROVED") say(s.pr, "Approved", "success");
        if (s.decision !== was.decision && s.decision === "CHANGES_REQUESTED") say(s.pr, "Changes requested", "warning");
      }
      for (const r of this.reviews ?? []) if (direct.has(r.key) && !this.seen.direct.has(r.key)) say(r, `Review requested by ${r.author}`, "info");
    }
    this.seen = { mine: now, direct };
  }

  ask(action, pr, layers = 1) {
    this.pending = { action, number: pr.number };
    const enqueueing = action === "enqueue";
    openOverlay({
      mod: "confirm",
      kind: "dialog",
      width: 400,
      height: 190,
      props: {
        title: enqueueing ? (layers > 1 ? `Merge the stack of ${layers} through Trunk?` : `Merge #${pr.number} through Trunk?`) : `Remove #${pr.number} from the queue?`,
        detail: enqueueing
          ? layers > 1
            ? `Enqueues the top layer, #${pr.number}. Trunk tests all ${layers} layers together and merges them at once.`
            : `Adds "${pr.title}" to the merge queue. In a stack, every layer below it goes in with it.`
          : `Takes "${pr.title}" out of the merge queue. It stays open.`,
        command: { name: "gh-inbox.confirmed" },
      },
    });
  }

  openInput(action, pr) {
    openOverlay({ mod: "gh-inbox-input", kind: "dialog", width: 440, height: ["labels", "reviewers"].includes(action) ? 480 : 240, props: { action, pr } });
  }

  confirmGithubMerge(pr) {
    this.pending = { action: "github-merge", number: pr.number, repo: pr.repo };
    openOverlay({
      mod: "confirm", kind: "dialog", width: 400, height: 180,
      props: {
        title: `Merge #${pr.number} on GitHub?`,
        detail: `Merges "${pr.title}" into ${pr.base} using a merge commit.`,
        command: { name: "gh-inbox.confirmed" },
      },
    });
  }

  async github(cx, pr, args, success) {
    try {
      const r = await exec("gh", args);
      const output = (r.stderr.trim() || r.stdout.trim()).split("\n").filter(Boolean).pop() ?? "";
      notify({ title: r.code === 0 ? success : `GitHub refused #${pr.number}`, body: output || pr.repo, level: r.code === 0 ? "success" : "error", timeout: 8000 });
      if (r.code === 0) this.refreshGh(cx);
    } catch (e) {
      notify({ title: `GitHub action failed for #${pr.number}`, body: String(e?.message ?? e), level: "error" });
    }
  }

  async act(cx) {
    const pending = this.pending;
    this.pending = null;
    if (pending.action === "github-merge") {
      await this.github(cx, pending, ["pr", "merge", String(pending.number), "--repo", pending.repo, "--merge"], `#${pending.number} merged`);
      return;
    }
    const { action, number } = pending;
    try {
      const r = action === "enqueue" ? await enqueue(number) : await dequeue(number);
      const last = r.out.trim().split("\n").filter(Boolean).pop() ?? "";
      if (/already exists/i.test(r.out)) {
        notify({ title: `#${number} is already submitted`, body: "Trunk already has it. The panel now shows its queue state.", level: "info", timeout: 8000 });
        this.refreshTrunk(cx);
        return;
      }
      notify({ title: r.code === 0 ? (action === "enqueue" ? `#${number} submitted to Trunk` : `#${number} removed from the queue`) : `Trunk refused #${number}`, body: last, level: r.code === 0 ? "success" : "error", timeout: 8000 });
    } catch (e) {
      notify({ title: `Trunk failed for #${number}`, body: String(e?.message ?? e), level: "error" });
    }
    this.refreshTrunk(cx);
  }

  fold(id, cx) {
    this.folded.has(id) ? this.folded.delete(id) : this.folded.add(id);
    localStorage.setItem("folded", JSON.stringify([...this.folded]));
    cx.notify();
  }

  select(id, cx) {
    const was = this.tab;
    this.tab = id;
    this.selectedKey = null;
    this.actionOpen = false;
    localStorage.setItem("tab", id);
    if (this.tabs[id]?.view === "queue" && this.tabs[was]?.view !== "queue") this.refreshTrunk(cx);
    cx.notify();
  }

  navigationItems() {
    const prs = this.sectionItems.get(this.tab);
    if (this.tabs[this.tab]?.view === "queue") return [];
    if (this.tabs[this.tab]?.view === "review") {
      if (!prs) return [];
      const direct = prs.filter((r) => r.requested.includes(this.me));
      const teams = prs.filter((r) => !r.requested.includes(this.me));
      const items = [];
      for (const [id, list] of [["review:you", direct], ["review:teams", teams]]) {
        if (this.folded.has(id)) continue;
        for (const pr of [...list].sort((a, b) => b.updated - a.updated)) items.push({ pr, review: true, group: null });
      }
      return items;
    }
    const items = [];
    if (!prs) return [];
    const groups = stacks(prs);
    for (const group of [...groups].sort((a, b) => (a.members[0].pr.repo === TRUNK_REPO ? 0 : 1) - (b.members[0].pr.repo === TRUNK_REPO ? 0 : 1))) {
      if (group.members.length > 1) {
        if (this.folded.has(`stack:${group.id}`)) continue;
        for (const member of [...group.members].reverse()) items.push({ pr: member.pr, review: false, group });
      } else {
        items.push({ pr: group.members[0].pr, review: false, group });
      }
    }
    return items;
  }

  selectedItem() {
    return this.navigationItems().find((item) => item.pr.key === this.selectedKey) ?? null;
  }

  ensureSelection() {
    const items = this.navigationItems();
    if (!items.some((item) => item.pr.key === this.selectedKey)) this.selectedKey = items[0]?.pr.key ?? null;
    return this.selectedItem();
  }

  move(delta, cx) {
    const length = this.actionOpen ? this.currentActions().length : this.navigationItems().length;
    if (!length) return;
    const current = this.actionOpen ? this.actionIndex : this.navigationItems().findIndex((item) => item.pr.key === this.selectedKey);
    const next = current < 0 ? (delta > 0 ? 0 : length - 1) : (current + delta + length) % length;
    if (this.actionOpen) this.actionIndex = next;
    else this.selectedKey = this.navigationItems()[next].pr.key;
    cx.notify();
  }

  moveTab(delta, cx) {
    const current = this.order.indexOf(this.tab);
    const next = (current + delta + this.order.length) % this.order.length;
    this.select(this.order[next], cx);
  }

  showActions(cx) {
    if (!this.ensureSelection()) {
      notify({ title: "No pull request selected", body: "Wait for the inbox to load, then try again.", level: "info", timeout: 2500 });
      return;
    }
    this.actionIndex = 0;
    this.actionOpen = true;
    cx.notify();
  }

  diffSelected(cx) {
    const item = this.ensureSelection();
    if (!item) {
      notify({ title: "No pull request selected", body: "Wait for the inbox to load, then try again.", level: "info", timeout: 2500 });
      return;
    }
    this.diffPr(cx, item.pr);
  }

  diffPr(cx, pr) {
    const context = focused();
    const machine = spaces().find((space) => space.id === context?.space)?.machine;
    const cwd = context?.cwd;
    if (!cwd || !context?.space) {
      notify({ title: "No terminal folder", body: "Focus a terminal in the PR's repository, then try again.", level: "error" });
      return;
    }
    cx.spawn(async (cx) => {
      try {
        const remote = await exec("git", ["remote", "get-url", "origin"], { cwd, on: machine });
        const match = remote.stdout.trim().match(/[:\/]([^\/:]+)\/([^\/]+?)(?:\.git)?\/?$/);
        const repo = match ? `${match[1]}/${match[2]}` : null;
        if (remote.code !== 0 || repo?.toLowerCase() !== pr.repo.toLowerCase()) {
          notify({ title: "Wrong repository", body: `Focus a terminal in ${pr.repo}, then try again.`, level: "error", timeout: 6000 });
          return;
        }
        const base = `origin/${pr.base}`;
        const head = `origin/pr/${pr.number}/head`;
        notify({ title: `Fetching PR #${pr.number}`, body: "Preparing the Diffview tab…", level: "info", timeout: 2500 });
        const fetched = await exec("git", [
          "fetch", "origin",
          `+refs/heads/${pr.base}:refs/remotes/${base}`,
          `+refs/pull/${pr.number}/head:refs/remotes/${head}`,
        ], { cwd, on: machine, timeout: 120000 });
        if (fetched.code !== 0) {
          notify({ title: `Could not fetch PR #${pr.number}`, body: fetched.stderr.trim() || "git fetch failed", level: "error", timeout: 8000 });
          return;
        }
        run("tab.new", {
          space: context.space,
          name: `PR #${pr.number} · diff`,
          folder: cwd,
          argv: ["nvim", "-c", `DiffviewOpen ${base}...${head}`],
        });
      } catch (e) {
        notify({ title: `Could not open PR #${pr.number} diff`, body: String(e?.message ?? e), level: "error", timeout: 8000 });
      }
      cx.notify();
    });
  }

  runAction(id, cx) {
    if (!this.ensureSelection()) {
      notify({ title: "No pull request selected", body: "Wait for the inbox to load, then try again.", level: "info", timeout: 2500 });
      return;
    }
    const action = this.currentActions().find((action) => action.id === id);
    if (action) {
      this.actionOpen = false;
      action.run(cx);
    }
    cx.notify();
  }

  openSelected(cx) {
    if (this.actionOpen) {
      const action = this.currentActions()[this.actionIndex];
      if (!action) return;
      this.actionOpen = false;
      cx.notify();
      action.run(cx);
      return;
    }
    const item = this.ensureSelection();
    if (item) cx.open_url(item.pr.url);
  }

  escape(cx) {
    if (this.actionOpen) {
      this.actionOpen = false;
    } else if (this.returnPane) {
      run("pane.focus", { pane: this.returnPane });
    }
    cx.notify();
  }

  currentActions() {
    const item = this.selectedItem();
    if (!item) return [];
    const { pr, review, group } = item;
    const p = palette(theme());
    const q = review ? null : this.queueFor(pr, group);
    let s = review ? this.reviewStep(pr, p) : this.step(pr, q, p);
    const below = !review && !q && s.icon === "check" ? this.blockedBelow(pr, group, p) : null;
    if (below) s = { icon: "stack", color: p.warn, label: `Waiting on #${below.number} below`, below };
    const startAgent = () => startPi(pr, { me: this.me, review, status: s.label, stack: group, asOf: this.updated });
    const actions = [
      { id: "pi", icon: "rocket", label: "Start Pi on this PR", run: (cx) => cx.spawn(startAgent) },
      { id: "open", icon: "external", label: "Open on GitHub", run: (cx) => cx.open_url(pr.url) },
      { id: "diff", icon: "pr", label: "Open diff in Neovim", run: (cx) => this.diffPr(cx, pr) },
      { id: "copy", icon: "copy", label: "Copy PR link", run: (cx) => {
        cx.write_to_clipboard(pr.url);
        notify({ title: "Link copied", body: pr.url, level: "success", timeout: 2500 });
      } },
      { id: "approve", icon: "approved", label: "Approve PR…", run: () => this.openInput("approve", pr) },
      { id: "github-merge", icon: "merged", label: "Merge PR", run: () => this.confirmGithubMerge(pr) },
      { id: "labels", icon: "tag", label: "Add labels…", run: () => this.openInput("labels", pr) },
      { id: "reviewers", icon: "eye", label: "Add reviewers…", run: () => this.openInput("reviewers", pr) },
      ...(pr.draft ? [{ id: "ready", icon: "rocket", label: "Ready for review", run: (cx) => cx.spawn(async (cx) => {
        await this.github(cx, pr, ["pr", "ready", String(pr.number), "--repo", pr.repo], `Marked #${pr.number} ready for review`);
      }) }] : []),
      { id: "assign", icon: "approved", label: "Assign me", run: (cx) => cx.spawn(async (cx) => {
        await this.github(cx, pr, ["pr", "edit", String(pr.number), "--repo", pr.repo, "--add-assignee", this.me ?? "@me"], `Assigned you to #${pr.number}`);
      }) },
    ];
    for (const [index, visual] of visualAsks(pr).entries()) actions.push({
      id: `visual-${index}`, icon: "eye", label: `Approve ${visual.type}${visual.partial ? " (partial)" : ""}`, run: (cx) => cx.open_url(visual.url),
    });
    const stacked = (group?.members.length ?? 0) > 1;
    if (!review && pr.repo === TRUNK_REPO && !this.trunkOff && !stacked && ((!q && s.icon === "check") || (q && ["Failed", "Cancelled"].includes(q.state) && !q.via))) {
      actions.push({ id: "merge", icon: "queue", label: q ? "Merge again via Trunk" : "Merge via Trunk", run: () => this.ask("enqueue", pr) });
    }
    actions.push({ id: "refresh", icon: "refresh", label: "Refresh inbox", run: (cx) => this.refreshAll(cx) });
    return actions;
  }

  actionView(t, cx) {
    const item = this.selectedItem();
    const actions = this.currentActions();
    if (!item) return [this.empty(t, "No pull request selected.")];
    return [
      v_flex().px(10).py(8).gap(2).border_b(1).border_color(t.border)
        .child(div().text_size(10.5).font_medium().text_color(t.dim).child("PR ACTIONS"))
        .child(div().truncate().text_size(12).text_color(t.foreground).child(`#${item.pr.number} ${item.pr.title}`)),
      ...actions.map((action, index) => h_flex().id(`ghi-action-${action.id}`).mx(4).px(8).py(7).gap(8).items_center().rounded(6).cursor_pointer()
        .bg(index === this.actionIndex ? t.selected : t.chrome)
        .text_color(index === this.actionIndex ? t.foreground : t.muted)
        .hover((s) => s.bg(t.hover))
        .on_hover((on, cx) => { if (on) { this.actionIndex = index; cx.notify(); } })
        .on_click((_e, cx) => { this.actionIndex = index; this.openSelected(cx); })
        .child(this.icon(t, action.icon, index === this.actionIndex ? t.accent : t.dim, 14))
        .child(div().flex_1().min_w(0).truncate().text_size(12).child(action.label))
        .when(index === this.actionIndex, (el) => el.child(div().text_size(10).text_color(t.dim).child("↵")))),
      div().px(10).py(8).text_size(10.5).text_color(t.dim).child("h/l tabs · j/k navigate · r refresh · enter run · esc back"),
    ];
  }

  // Dropping a dragged tab on another puts it in that tab's place.
  drop(onto, cx) {
    const from = this.dragging;
    this.dragging = null;
    if (!from || from === onto) return;
    const order = this.order.filter((id) => id !== from);
    order.splice(this.order.indexOf(onto), 0, from);
    this.order = order;
    localStorage.setItem("order", JSON.stringify(order));
    cx.notify();
  }

  counts() {
    const qMine = [...(this.mineQueue?.values() ?? [])].filter((i) => i.state !== "Merged").length;
    const counts = {};
    for (const section of this.sections) {
      const prs = this.sectionItems.get(section.id);
      counts[section.id] = section.view === "queue" ? qMine || null : section.view === "review" ? (prs ?? []).filter((r) => r.requested.includes(this.me)).length || prs?.length : prs?.length;
    }
    return counts;
  }

  // ---- drawing ----

  icon(t, name, color, size = 14, spin = false) {
    const el = svg(ICON(name)).size(size).flex_none().text_color(color);
    return spin ? el.spin(900) : el;
  }

  chip(t, s, size = 11) {
    return h_flex().gap(4).items_center().flex_none().text_size(size).text_color(s.color)
      .child(this.icon(t, s.icon, s.color, size + 1, s.spin))
      .child(div().whitespace_nowrap().child(s.label));
  }

  tabStrip(t, cx) {
    const counts = this.counts();
    return h_flex().px(12).h(41).pt(12).pb(5).flex_none().items_center().gap(2)
      .children(this.order.map((id) => {
        const on = id === this.tab;
        const n = counts[id];
        return h_flex().id(`ghi-tab-${id}`).h(24).px(7).gap(5).items_center().rounded(6).cursor_pointer()
          .text_size(11.5).font_medium()
          .text_color(on ? t.foreground : t.dim)
          .when(on, (el) => el.bg(t.raised))
          .when(Boolean(this.dragging) && this.dragging !== id, (el) => el.border_1().border_color(t.border).border_dashed())
          .hover((s) => s.text_color(t.foreground))
          .on_mouse_down("left", () => { this.dragging = id; })
          .on_mouse_up("left", (_e, cx) => this.drop(id, cx))
          .on_click((_e, cx) => this.select(id, cx))
          .tooltip("Drag to reorder")
          .child(this.tabs[id].label)
          .when(n != null, (el) => el.child(div().text_size(10.5).text_color(on ? t.muted : t.dim).child(String(n))));
      }))
      .child(div().flex_1())
      .child(this.refreshButton(t));
  }

  // Turns yellow while the last refresh failed and the list shows older data.
  refreshButton(t) {
    const busy = this.busy.gh || this.busy.trunk;
    const stale = Object.keys(this.errors).filter((k) => this.errors[k]);
    const color = stale.length ? palette(t).warn : t.dim;
    const when = this.updated ? `Updated ${ago(Date.now() - this.updated)} ago.` : "";
    const why = stale.map((k) => `Last ${k} refresh failed: ${this.errors[k]}`).join("\n");
    return div().id("ghi-refresh").text_color(color).cursor_pointer().hover((s) => s.text_color(t.foreground))
      .tooltip([why, when, "Click to refresh."].filter(Boolean).join("\n"))
      .on_click((_e, cx) => this.refreshAll(cx))
      .child(this.icon(t, busy ? "spinner" : "refresh", color, 13, busy));
  }

  sectionHeader(t, id, label, count, cx, extra = null) {
    const open = !this.folded.has(id);
    return h_flex().id(`ghi-sec-${id}`).px(8).h(28).mt(4).flex_none().items_center().gap(6).rounded(6).cursor_pointer()
      .text_size(11).font_medium().text_color(t.dim).hover((s) => s.text_color(t.muted))
      .on_click((_e, cx) => this.fold(id, cx))
      .child(this.icon(t, open ? "chevron-down" : "chevron-right", t.dim, 11))
      .child(div().child(label))
      .child(div().text_color(t.dim).child(String(count)))
      .child(div().flex_1())
      .when(Boolean(extra), (el) => el.child(extra));
  }

  progressBar(t, p, run) {
    const total = run.checks.total || 1;
    const width = Math.max(60, this.width - 92);
    const done = Math.round(((run.checks.pass + run.checks.fail) / total) * width);
    return v_flex().gap(3).mt(2)
      .child(h_flex().w(width).h(4).rounded(2).bg(t.raised).overflow_hidden()
        .child(div().w(done).h(4).bg(run.checks.fail ? p.bad : p.run)))
      .child(div().text_size(10.5).text_color(t.dim).child(
        `${run.checks.pass + run.checks.fail}/${run.checks.total} checks${run.checks.fail ? `, ${run.checks.fail} failing` : ""} · ${ago(Date.now() - run.started)}`));
  }

  // A PR row: what's next, then CI, reviews and comments at a glance. A click opens the PR;
  // buttons show only when something waits on you.
  prRow(t, pr, cx, { group = null, depth = 0, review = false } = {}) {
    const p = palette(t);
    const q = review ? null : this.queueFor(pr, group);
    let s = review ? this.reviewStep(pr, p) : this.step(pr, q, p);
    const below = !review && !q && s.icon === "check" ? this.blockedBelow(pr, group, p) : null;
    if (below) s = { icon: "stack", color: p.warn, label: `Waiting on #${below.number} below`, below };
    const c = pr.checks;
    const ci = c.fail ? { icon: "fail", color: p.bad, label: `${c.fail}` } : c.running ? { icon: "spinner", spin: true, color: p.run, label: `${c.pass}/${c.total}` } : c.total ? { icon: "check", color: p.ok, label: "" } : null;
    const meta = [];
    if (review) meta.push(div().text_color(t.dim).child(`${pr.author} · ${ago(Date.now() - pr.created)}`));
    else {
      meta.push(div().flex_none().text_color(t.dim).child(pr.author));
      meta.push(s.tip ? this.link(t, `ghi-step-${pr.key}`, this.chip(t, s), s.url, s.tip) : this.chip(t, s));
    }
    if (ci && (review || !["spinner", "fail", "check"].includes(s.icon))) meta.push(c.fail ? this.link(t, `ghi-ci-${pr.key}`, this.chip(t, ci), `${pr.url}/checks`, "Open the failing checks") : this.chip(t, ci));
    if (pr.approvedBy.length && s.icon !== "check") meta.push(this.chip(t, { icon: "approved", color: p.ok, label: String(pr.approvedBy.length) }));
    if (pr.unresolved) meta.push(this.chip(t, { icon: "comment", color: p.warn, label: String(pr.unresolved) }));

    const lead = this.icon(t, pr.draft ? "pr-draft" : q?.state === "Merged" ? "merged" : "pr", pr.draft ? p.dim : review ? t.muted : s.color, 15);
    return [h_flex().id(`ghi-pr-${pr.key}`).px(8).py(5).gap(8).items_start().rounded(8).cursor_pointer()
      .bg(this.selectedKey === pr.key ? t.selected : t.chrome)
      .hover((st) => st.bg(t.hover))
      .on_hover((on, cx) => this.hover(pr.key, on, cx))
      .on_click((_e, cx) => { this.selectedKey = pr.key; cx.open_url(pr.url); })
      .when(depth > 0, (el) => el.pl(8 + 14 * Math.min(depth, 3)))
      .child(div().mt(1).child(lead))
      .child(v_flex().flex_1().min_w(0).gap(2)
        .child(h_flex().gap(5).items_center().min_w(0)
          .child(div().flex_none().text_size(11).text_color(t.dim).child(`#${pr.number}`))
          .child(div().flex_1().min_w(0).truncate().text_size(12.5).text_color(pr.draft ? t.muted : t.foreground).child(pr.title)))
        .child(h_flex().gap(8).items_center().min_w(0).overflow_hidden().text_size(11).children(meta))
        .when(Boolean(s.progress), (el) => el.child(this.progressBar(t, p, s.progress))))];
  }

  // Makes a chip open a page, without opening the PR under it.
  link(t, id, el, url, tip) {
    return el.id(id).cursor_pointer().rounded(4).hover((st) => st.bg(t.hover)).tooltip(tip)
      .on_click((_e, cx) => { cx.stop_propagation(); cx.open_url(url); });
  }

  // The nearest layer under this one in its stack that can't merge yet.
  blockedBelow(pr, group, p) {
    if (!group) return null;
    const idx = group.members.findIndex((m) => m.pr.key === pr.key);
    for (let i = idx - 1; i >= 0; i--) if (this.blocker(group.members[i].pr, p)) return group.members[i].pr;
    return null;
  }

  reviewStep(pr, p) {
    if (pr.draft) return { icon: "pr-draft", color: p.dim, label: "Draft" };
    const vr = visualStep(pr, p);
    if (vr) return vr;
    if (pr.checks.fail) return { icon: "fail", color: p.bad, label: "CI failing" };
    if (pr.checks.running) return { icon: "spinner", spin: true, color: p.run, label: "CI running" };
    return { icon: "pr", color: p.ok, label: "Ready for review" };
  }

  // One failed refresh is usually GitHub having a moment; three in a row is worth showing.
  failing(kind) {
    return Boolean(this.errors[kind]) && this.fails[kind] >= 3;
  }

  empty(t, text) {
    return div().px(10).py(8).text_size(12).text_color(t.dim).child(text);
  }

  errorLine(t, text) {
    return h_flex().px(10).py(4).gap(6).items_start().text_size(11).text_color(palette(t).bad)
      .child(div().mt(1).child(this.icon(t, "conflict", palette(t).bad, 12)))
      .child(div().flex_1().min_w(0).child(text));
  }

  mineView(t, cx) {
    const prs = this.sectionItems.get(this.tab);
    const label = this.tabs[this.tab]?.view === "mine" ? "your" : this.tabs[this.tab].label;
    if (this.errors.gh && !prs) return [this.errorLine(t, `gh: ${this.errors.gh}`)];
    if (!prs) return [this.empty(t, `Loading ${label} pull requests...`)];
    if (!prs.length) return [this.empty(t, "No open pull requests.")];
    const rows = [];
    const groups = stacks(prs);
    const p = palette(t);
    let repo = null;
    for (const g of [...groups].sort((a, b) => (a.members[0].pr.repo === TRUNK_REPO ? 0 : 1) - (b.members[0].pr.repo === TRUNK_REPO ? 0 : 1))) {
      const r = g.members[0].pr.repo;
      if (r !== repo && r !== TRUNK_REPO) rows.push(div().px(8).pt(8).pb(2).text_size(10.5).font_medium().text_color(t.dim).child(r));
      repo = r;
      if (g.members.length > 1) {
        const id = `stack:${g.id}`;
        const top = g.members.at(-1).pr;
        const q = this.queueFor(g.members[0].pr, g);
        const ready = g.members.filter((m) => !this.blocker(m.pr, p)).length;
        const all = ready === g.members.length;
        const extra = q
          ? this.chip(t, { ...this.step(null, q, p), label: q.state }, 10.5)
          : h_flex().gap(6).items_center()
              .child(this.chip(t, all ? { icon: "check", color: p.ok, label: "All ready" } : { icon: "stack", color: t.dim, label: `${ready}/${g.members.length} ready` }, 10.5))
              .when(all && top.repo === TRUNK_REPO && !this.trunkOff, (el) => el.child(div().id(`ghi-merge-${id}`).px(5).h(18).flex().items_center().rounded(5).border_1().border_color(t.border)
                .text_size(10.5).text_color(t.muted).hover((s) => s.bg(t.hover).text_color(t.foreground))
                .on_click((_e, cx) => { cx.stop_propagation(); this.ask("enqueue", top, g.members.length); })
                .child("Merge stack")));
        rows.push(h_flex().id(`ghi-${id}`).px(8).h(24).mt(4).gap(6).items_center().rounded(6).cursor_pointer()
          .text_size(10.5).font_medium().text_color(t.dim).hover((s) => s.text_color(t.muted))
          .on_click((_e, cx) => this.fold(id, cx))
          .child(this.icon(t, "stack", t.dim, 12))
          .child(div().flex_1().min_w(0).truncate().child(`Stack of ${g.members.length} · ${top.head}`))
          .when(Boolean(extra), (el) => el.child(extra))
          .child(this.icon(t, this.folded.has(id) ? "chevron-right" : "chevron-down", t.dim, 11)));
        if (this.folded.has(id)) continue;
        // Top of the stack first, the layer on the base branch last, as `gh stack view` shows it.
        const members = [...g.members].reverse();
        members.forEach((m) => rows.push(...this.prRow(t, m.pr, cx, { group: g, depth: 1 })));
      } else {
        rows.push(...this.prRow(t, g.members[0].pr, cx, { group: g }));
      }
    }
    if (this.failing("gh")) rows.unshift(this.errorLine(t, `gh: ${this.errors.gh}`));
    if (this.failing("trunk")) rows.unshift(this.errorLine(t, `trunk: ${this.errors.trunk}`));
    return rows;
  }

  queueView(t, cx) {
    const p = palette(t);
    if (this.trunkOff) return [this.empty(t, `The merge queue needs Trunk. ${this.trunkOff}`)];
    if (this.errors.trunk && !this.queue) return [this.errorLine(t, `trunk: ${this.errors.trunk}`)];
    if (!this.queue) return [this.empty(t, "Loading the merge queue...")];
    const items = this.queue.items;
    const rows = [];
    const by = (state) => items.filter((i) => i.state === state);
    const running = this.queue.running === "Running";
    rows.push(h_flex().px(8).pt(2).pb(4).gap(8).items_center().text_size(11).text_color(t.dim)
      .child(this.chip(t, { icon: running ? "rocket" : "paused", color: running ? p.ok : p.warn, label: `${this.queue.branch} · ${this.queue.running}` }))
      .child(div().flex_1())
      .child(div().child(`${capped(by("Testing").length)} testing · ${capped(by("Pending").length)} waiting`)));

    const mineByNumber = new Map((this.mine ?? []).filter((m) => m.repo === TRUNK_REPO).map((m) => [m.number, m]));
    const groups = stacks(this.mine ?? []);
    const yours = [...(this.mineQueue?.values() ?? [])];
    if (yours.length) {
      rows.push(this.sectionHeader(t, "queue:yours", "Yours", yours.length, cx));
      if (!this.folded.has("queue:yours")) {
        for (const i of yours) {
          const pr = mineByNumber.get(i.number);
          if (pr) rows.push(...this.prRow(t, pr, cx, { group: groups.find((g) => g.members.some((m) => m.pr.key === pr.key)) }));
          else rows.push(this.queueRow(t, i, p, true));
        }
      }
    }
    const sections = [
      ["Testing", "queue:testing", "Testing"],
      ["Tests Passed", "queue:passed", "Merging"],
      ["Pending", "queue:pending", "Waiting"],
      ["Not Ready", "queue:notready", "Not ready"],
      ["Pending Failure", "queue:pfail", "Failing"],
      ["Failed", "queue:failed", "Failed"],
      ["Merged", "queue:merged", "Recently merged"],
    ];
    for (const [state, id, label] of sections) {
      const list = by(state);
      if (!list.length) continue;
      rows.push(this.sectionHeader(t, id, label, state === "Merged" ? list.length : capped(list.length), cx));
      if (!this.folded.has(id)) list.forEach((i, k) => rows.push(this.queueRow(t, i, p, this.known.has(i.number), state === "Pending" ? k + 1 : null)));
    }
    if (!items.length) rows.push(this.empty(t, "The queue is empty."));
    if (this.failing("trunk")) rows.unshift(this.errorLine(t, `trunk: ${this.errors.trunk}`));
    return rows;
  }

  queueRow(t, i, p, yours, pos = null) {
    const s = this.step(null, { ...i, via: null }, p);
    const r = s.progress;
    const pct = r?.checks.total ? Math.round(((r.checks.pass + r.checks.fail) / r.checks.total) * 100) : null;
    const key = `q-${i.number}`;
    return h_flex().id(`ghi-q-${i.number}`).px(8).h(26).gap(8).items_center().rounded(6).cursor_pointer()
      .text_size(12).hover((st) => st.bg(t.hover))
      .on_hover((on, cx) => this.hover(key, on, cx))
      .on_click((_e, cx) => cx.open_url(`https://github.com/${TRUNK_REPO}/pull/${i.number}`))
      .tooltip(`${i.state}: #${i.number} ${i.title}`)
      .child(this.icon(t, s.icon, s.color, 13))
      .when(pos != null, (el) => el.child(div().w(16).flex_none().text_size(10.5).text_color(t.dim).child(String(pos))))
      .child(div().flex_none().text_size(11).text_color(yours ? p.accent : t.dim).child(`#${i.number}`))
      .child(div().flex_1().min_w(0).truncate().text_color(yours ? t.foreground : t.muted).when(yours, (el) => el.font_medium()).child(i.title))
      .when(pct != null, (el) => el.child(div().flex_none().text_size(10.5).text_color(r.checks.fail ? p.bad : t.dim)
        .child(`${pct}% · ${ago(Date.now() - r.started)}`)));
  }

  hover(key, on, cx) {
    if (on) this.hovered = key;
    else if (this.hovered === key) this.hovered = null;
    cx.notify();
  }

  reviewView(t, cx) {
    const prs = this.sectionItems.get(this.tab);
    if (this.errors.gh && !prs) return [this.errorLine(t, `gh: ${this.errors.gh}`)];
    if (!prs) return [this.empty(t, "Loading review requests...")];
    if (!prs.length) return [this.empty(t, "Nothing is waiting on your review.")];
    const direct = prs.filter((r) => r.requested.includes(this.me));
    const teams = prs.filter((r) => !r.requested.includes(this.me));
    const rows = [];
    for (const [id, label, list] of [["review:you", "Requested from you", direct], ["review:teams", "Your teams", teams]]) {
      if (!list.length) continue;
      rows.push(this.sectionHeader(t, id, label, list.length, cx));
      if (!this.folded.has(id)) for (const pr of list.sort((a, b) => b.updated - a.updated)) rows.push(...this.prRow(t, pr, cx, { review: true }));
    }
    return rows;
  }

  // The sidebar's rail: each tab as an icon and its count.
  rail(t, cx) {
    const counts = this.counts();
    return v_flex().size_full().bg(t.chrome).items_center().pt(10).gap(8)
      .children(this.order.map((id) => v_flex().id(`ghi-rail-${id}`).items_center().gap(1).cursor_pointer()
        .text_color(id === this.tab ? t.foreground : t.dim).hover((s) => s.text_color(t.foreground))
        .on_click((_e, cx) => this.select(id, cx))
        .tooltip(this.tabs[id].label)
        .child(svg(ICON(this.tabs[id].icon)).size(15))
        .child(div().text_size(10).child(counts[id] != null ? String(counts[id]) : ""))));
  }

  render(cx) {
    const t = theme();
    const root = (el) => el.id("ghi-root").track_focus(this.handle)
      .border(1).border_color(this.hasFocus ? t.accent : t.border)
      .on_size_change((size, cx) => {
        if (Math.abs(size.width - this.width) < 1) return;
        this.width = size.width;
        cx.notify();
      });
    if (this.width < 160) return root(this.rail(t, cx));
    const view = this.tabs[this.tab]?.view;
    const body = this.actionOpen ? this.actionView(t, cx) : view === "queue" ? this.queueView(t, cx) : view === "review" ? this.reviewView(t, cx) : this.mineView(t, cx);
    return root(v_flex().size_full().min_h(0).bg(t.chrome).text_size(13)
      .on_mouse_up("left", () => { this.dragging = null; })
      .child(this.tabStrip(t, cx))
      .child(v_flex().id("ghi-list").flex_1().min_h(0).px(8).pb(8).overflow_y_scrollbar().children(body)));
  }
}
