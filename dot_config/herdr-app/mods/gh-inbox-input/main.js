// Approval text input and repository-label multi-select for GitHub inbox.
import { View, div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { exec, run, props, closeOverlay, notify, theme } from "herdr";

export default class GhInboxInput extends View {
  init(_props, cx) {
    const p = props() ?? {};
    this.action = p.action ?? "approve";
    this.pr = p.pr ?? { number: 0, repo: "", labels: [] };
    this.input = InputState.new({ value: "" });
    this.inputFocused = true;
    this.labels = [];
    this.selected = new Set((this.pr.labels ?? []).map((label) => label.name));
    this.existing = new Set(this.selected);
    this.at = 0;
    this.loading = ["labels", "reviewers"].includes(this.action);
    this.error = null;
    this.handle = cx.focus_handle();
    this.top = 0;
    this.input.on("change", (_e, cx) => {
      if (this.action === "labels") {
        this.at = 0;
        this.top = 0;
      }
      cx.notify();
    });
    this.input.on("submit", () => {
      if (this.action === "approve") this.submit();
    });
    this.input.on("focus", (_e, cx) => { this.inputFocused = true; cx.notify(); });
    this.input.on("blur", (_e, cx) => { this.inputFocused = false; cx.notify(); });
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    if (["labels", "reviewers"].includes(this.action)) cx.spawn((cx) => this.load(cx));
  }

  async load(cx) {
    this.loading = true;
    this.error = null;
    cx.notify();
    try {
      if (this.action === "reviewers") {
        const r = await exec("gh", [
          "api", `repos/${this.pr.repo}/collaborators?per_page=100`, "--paginate", "--jq", ".[].login",
        ]);
        if (r.code !== 0) throw new Error(r.stderr.trim() || "Could not load collaborators");
        const requested = new Set(this.pr.requested ?? []);
        const names = [...new Set(r.stdout.split(/\n/).map((name) => name.trim()).filter(Boolean))];
        this.labels = names.filter((name) => name !== this.pr.author && !requested.has(name)).sort().map((name) => ({ name }));
      } else {
        const r = await exec("gh", ["label", "list", "--repo", this.pr.repo, "--limit", "100", "--json", "name,color,description"]);
        if (r.code !== 0) throw new Error(r.stderr.trim() || r.stdout.trim() || "Could not load labels");
        this.labels = JSON.parse(r.stdout).sort((a, b) => a.name.localeCompare(b.name));
      }
    } catch (e) {
      this.error = String(e?.message ?? e);
    }
    this.loading = false;
    cx.notify();
  }

  shown() {
    const query = this.input.value().trim().toLowerCase();
    return query ? this.labels.filter((label) => label.name.toLowerCase().includes(query)) : this.labels;
  }

  toggle(label, cx) {
    if (this.selected.has(label.name)) this.selected.delete(label.name);
    else this.selected.add(label.name);
    cx.notify();
  }

  newLabels() {
    if (this.action === "reviewers") return [...this.selected];
    return [...this.selected].filter((name) => !this.existing.has(name));
  }

  async submit() {
    const approving = this.action === "approve";
    const reviewing = this.action === "reviewers";
    const additions = approving ? [] : this.newLabels();
    if (!approving && additions.length === 0) {
      notify({
        title: reviewing ? "Select at least one reviewer" : "Select at least one new label",
        body: reviewing ? "People already reviewing the PR are left unchanged." : "Labels already on the PR are left unchanged.",
        level: "info", timeout: 3000,
      });
      return;
    }
    if (reviewing) {
      closeOverlay(props().overlay);
      try {
        const r = await exec("gh", [
          "api", "-X", "POST", `repos/${this.pr.repo}/pulls/${this.pr.number}/requested_reviewers`,
          ...additions.flatMap((reviewer) => ["-f", `reviewers[]=${reviewer}`]),
        ]);
        if (r.code !== 0) throw new Error(r.stderr.trim() || "GitHub refused the review request");
        notify({ title: `Reviewers added to #${this.pr.number}`, body: additions.join(", "), level: "success", timeout: 5000 });
        run("gh-inbox.refresh");
      } catch (e) {
        notify({ title: `Could not request reviewers for #${this.pr.number}`, body: String(e?.message ?? e), level: "error", timeout: 8000 });
      }
      return;
    }
    const message = approving ? this.input.value().trim() : "";
    const args = approving
      ? ["pr", "review", String(this.pr.number), "--repo", this.pr.repo, "--approve", ...(message ? ["--body", message] : [])]
      : ["pr", "edit", String(this.pr.number), "--repo", this.pr.repo];
    for (const name of additions) args.push("--add-label", name);
    closeOverlay(props().overlay);
    try {
      const r = await exec("gh", args);
      const output = (r.stderr.trim() || r.stdout.trim()).split("\n").filter(Boolean).pop() ?? "";
      notify({
        title: r.code === 0 ? (approving ? `#${this.pr.number} approved` : `Labels added to #${this.pr.number}`) : `GitHub refused #${this.pr.number}`,
        body: output || (additions.length ? additions.join(", ") : this.pr.repo),
        level: r.code === 0 ? "success" : "error",
        timeout: 8000,
      });
      if (r.code === 0) run("gh-inbox.refresh");
    } catch (e) {
      notify({ title: `GitHub action failed for #${this.pr.number}`, body: String(e?.message ?? e), level: "error" });
    }
  }

  labelList(t, cx) {
    const shown = this.shown();
    if (this.at >= shown.length) this.at = Math.max(0, shown.length - 1);
    const row = (label, i) => {
      const selected = this.selected.has(label.name);
      return h_flex().id(`label-${i}`).h(30).px(8).gap(8).flex_none().items_center().rounded(4)
        .bg(i === this.at ? t.raised : selected ? t.selected : t.popover)
        .hover((s) => s.bg(t.hover)).cursor_pointer()
        .on_click(() => { this.at = i; this.toggle(label, cx); })
        .child(div().size(14).rounded(3).border_1().border_color(selected ? t.accent : t.input).bg(selected ? t.accent : t.background)
          .flex().items_center().justify_center().text_size(10).text_color(t.accent_foreground).child(selected ? "✓" : ""))
        .when(this.action !== "reviewers", (el) => el.child(div().size(8).rounded(4).flex_none().bg(label.color ? `#${label.color}` : t.dim)))
        .child(div().flex_1().min_w(0).truncate().text_size(12).text_color(t.foreground).child(label.name))
        .when(this.existing.has(label.name), (el) => el.child(div().text_size(9.5).text_color(t.dim).child("on PR")));
    };
    const frame = v_flex().h(230).mt(10).rounded(6).bg(t.background).border_1().border_color(t.input);
    if (!this.loading && !this.error && shown.length > 0) {
      const page = 7;
      this.top = Math.max(0, Math.min(this.top, shown.length - page));
      return frame.p(4).on_scroll_wheel((e, cx) => {
        this.top = Math.max(0, Math.min(shown.length - page, this.top + (e.delta.y > 0 ? 1 : -1)));
        cx.stop_propagation();
        cx.notify();
      }).children(shown.slice(this.top, this.top + page).map((label, offset) => row(label, this.top + offset)));
    }
    return frame.items_center().justify_center()
      .when(this.loading, (el) => el.child(div().text_size(12).text_color(t.dim).child(this.action === "reviewers" ? "Loading collaborators…" : "Loading labels…")))
      .when(!this.loading && Boolean(this.error), (el) => el.gap(10)
        .child(div().px(16).text_align_center().text_size(11.5).text_color(t.blocked).child(this.error))
        .child(h_flex().id("labels-retry").h(28).px(12).items_center().rounded(4).bg(t.raised).cursor_pointer().child("Retry").on_click(() => this.load(cx))))
      .when(!this.loading && !this.error, (el) => el.child(div().text_size(12).text_color(t.dim).child("No matching labels")));
  }

  render(cx) {
    const t = theme();
    const approving = this.action === "approve";
    const reviewing = this.action === "reviewers";
    const title = approving ? `Approve #${this.pr.number}` : reviewing ? `Add reviewers to #${this.pr.number}` : `Add labels to #${this.pr.number}`;
    const label = approving ? "Approval message (optional)" : reviewing ? "Filter collaborators" : "Filter labels";
    const button = (id, text, primary, action) => h_flex().id(id).h(32).px(14).items_center().rounded(6)
      .border_1().border_color(primary ? t.solid : t.input).bg(primary ? t.solid : t.raised)
      .text_color(primary ? t.solid_foreground : t.foreground).text_size(12.5).font_medium().cursor_pointer()
      .hover((s) => s.opacity(0.88)).on_click(action).child(text);
    return v_flex().id("gh-inbox-input").track_focus(this.handle)
      .on_key_down((e, cx) => {
        if (e.key === "escape") {
          closeOverlay(props().overlay);
        } else if (!approving && (e.key === "down" || e.key === "up")) {
          const count = this.shown().length;
          if (count) {
            this.at = (this.at + (e.key === "down" ? 1 : count - 1)) % count;
            const page = 7;
            if (this.at === 0) this.top = 0;
            else if (this.at === count - 1) this.top = Math.max(0, count - page);
            else if (this.at < this.top) this.top = this.at;
            else if (this.at >= this.top + page) this.top = this.at - page + 1;
          }
        } else if (!approving && e.key === "space") {
          const label = this.shown()[this.at];
          if (label) this.selected.has(label.name) ? this.selected.delete(label.name) : this.selected.add(label.name);
        } else if (!approving && e.key === "enter") {
          cx.stop_propagation();
          this.submit();
          return;
        } else return;
        cx.stop_propagation();
        cx.notify();
      })
      .w_full().min_h(0).p(18).pb(30).bg(t.popover).text_color(t.foreground)
      .child(h_flex().items_center()
        .child(div().flex_1().text_size(15).font_semibold().child(title))
        .child(div().text_size(11).text_color(t.dim).child("Esc")))
      .child(div().pt(16).pb(7).text_size(11.5).text_color(t.dim).child(label))
      .child(Input.new(this.input).h(36).px(10).rounded(6).border_1()
        .border_color(this.inputFocused ? t.accent : t.input).bg(t.background).text_size(12.8).text_color(t.foreground))
      .when(!approving, (el) => el.child(this.labelList(t, cx)))
      .child(div().pt(8).text_size(11).text_color(t.dim).child(approving
        ? "Approves the PR, with an optional review comment."
        : reviewing ? "↑/↓ navigate · Space select · Enter request · Current reviewers are omitted"
        : "↑/↓ navigate · Space select · Enter apply · Existing labels stay unchanged"))
      .child(h_flex().pt(18).gap(8).justify_end()
        .child(button("ghi-cancel", "Cancel", false, () => closeOverlay(props().overlay)))
        .child(button("ghi-submit", approving ? "Approve" : `${reviewing ? "Request" : "Apply"}${this.newLabels().length ? ` (${this.newLabels().length})` : ""}`, true, () => this.submit())));
  }
}
