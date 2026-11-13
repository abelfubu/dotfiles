import { View, div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { terminals, run, theme, props, closeOverlay, shared, setShared } from "herdr";

// Ephemeral child-terminal viewer used by Go To. Dismissing the dialog ends
// the terminal; Keep deliberately transfers ownership to a normal Herdr tab.
export default class DiffviewPeek extends View {
  init() {
    this.keep = false;
    setShared("diffview-peek.current", props()?.terminal ?? null);
  }

  button(t, id, label, onClick, tooltip) {
    return div().id(id).px(8).py(2).rounded(5).text_color(t.muted).cursor_pointer()
      .hover(s => s.bg(t.hover).text_color(t.foreground))
      .tooltip(tooltip)
      .on_click(onClick)
      .child(label);
  }

  render() {
    const t = theme();
    const { terminal } = props() ?? {};
    const term = terminals().find(item => item.address === terminal);
    return h_flex().size_full().px(12).gap(8).items_center().bg(t.surface)
      .border_b(1).border_color(t.border).text_size(12)
      .child(div().flex_1().truncate().font_semibold().text_color(t.foreground)
        .child(term?.name || term?.program?.name || terminal || "Diffview"))
      .child(div().flex_none().text_color(t.dim).child(terminal ?? ""))
      .child(this.button(t, "diffview-keep", "↗ Keep", () => {
        this.keep = true;
        run("terminal.keep", { terminal });
        closeOverlay();
      }, "Keep this terminal as a tab"))
      .child(this.button(t, "diffview-close", "✕", () => closeOverlay(), "Close and terminate (Cmd+W)"));
  }

  async close() {
    const { terminal } = props() ?? {};
    if (shared("diffview-peek.current") === terminal) setShared("diffview-peek.current", null);
    const preserve = shared("diffview-peek.preserve");
    if (preserve?.terminal === terminal && Date.now() - preserve.at < 2000) {
      setShared("diffview-peek.preserve", null);
      return;
    }
    const live = terminals().some(item => item.address === terminal && item.state === "live");
    if (!this.keep && terminal && live) run("terminal.kill", { terminal });
  }
}
