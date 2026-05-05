local wezterm = require("wezterm")

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "One Dark (Gogh)"
	else
		return "One Light (Gogh)"
	end
end

local font_size = 16
-- local font = "Geist Mono"
-- local font = "Operator Mono SSm Lig"
-- local font = "JetBrainsMono Nerd Font"
local font = "CommitMono"
local font_weight = "Medium"

wezterm.on("gui-startup", function()
	local tab, pane, window = wezterm.mux.spawn_window({
		cwd = wezterm.home_dir .. "/dev",
	})

	window:gui_window():maximize()
	tab:set_title("dev")
end)

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.window_background_opacity = 0.95

config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.font = wezterm.font_with_fallback({
	{
		family = font,
		weight = font_weight,
	},
	"JetBrainsMono Nerd Font",
})
config.harfbuzz_features = { "ss01", "ss02", "cv02", "cv10" }
config.font_size = font_size
config.line_height = 1.8

config.window_decorations = "RESIZE"

config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
	regex = [[(\S+):(\d+):(\d+)]],
	format = "file://$1:$2:$3",
})

table.insert(config.hyperlink_rules, {
	regex = [[(\S+):(\d+)]],
	format = "file://$1:$2",
})

config.leader = { key = "d", mods = "ALT", timeout_milliseconds = 5000 }

config.keys = {

	{
		mods = "LEADER",
		key = "c",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		mods = "LEADER",
		key = "x",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		mods = "LEADER",
		key = "b",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		mods = "LEADER",
		key = "n",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		mods = "LEADER",
		key = "|",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "-",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "h",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		mods = "LEADER",
		key = "j",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		mods = "LEADER",
		key = "k",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		mods = "LEADER",
		key = "l",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		mods = "SHIFT",
		key = "LeftArrow",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		mods = "SHIFT",
		key = "RightArrow",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		mods = "SHIFT",
		key = "DownArrow",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
	{
		mods = "SHIFT",
		key = "UpArrow",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "Enter",
		mods = "CMD",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		key = "o",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},
	{
		key = "s",
		mods = "CMD",
		action = wezterm.action.SendKey({ key = "s", mods = "CTRL" }),
	},
	{
		key = "j",
		mods = "CMD",
		action = wezterm.action.SendKey({ key = "j", mods = "CTRL" }),
	},
	{
		key = "k",
		mods = "CMD",
		action = wezterm.action.SendKey({ key = "k", mods = "CTRL" }),
	},
	{
		key = "l",
		mods = "CMD",
		action = wezterm.action.SendKey({ key = "l", mods = "CTRL" }),
	},
	{
		key = "h",
		mods = "CMD",
		action = wezterm.action.SendKey({ key = "h", mods = "CTRL" }),
	},
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.SendKey({ key = "w", mods = "CTRL" }),
	},
	{
		key = "p",
		mods = "CMD",
		action = wezterm.action.SendKey({ key = "p", mods = "CTRL" }),
	},
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES" }),
	},
	{
		key = "g",
		mods = "CMD",
		action = wezterm.action.SpawnCommandInNewTab({
			label = "Lazygit",
			args = { "/bin/zsh", "-l", "-c", "lazygit" },
		}),
	},
	{
		key = "1",
		mods = "CMD",
		action = wezterm.action.SpawnCommandInNewTab({
			label = "Sql",
			args = { "/bin/zsh", "-l", "-c", "lazysql" },
		}),
	},
	{
		key = "d",
		mods = "CMD",
		action = wezterm.action.SpawnCommandInNewTab({
			label = "Dash",
			args = { "/bin/zsh", "-l", "-c", "gh dash" },
		}),
	},
	{
		key = "o",
		mods = "CMD",
		action = wezterm.action.SplitPane({
			direction = "Right",
			command = { args = { "/bin/zsh", "-l", "-c", "opencode" } },
			size = { Percent = 27 },
		}),
	},
}

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

config.window_padding = {
	top = 0,
	right = 16,
	left = 16,
	bottom = 0,
}

local wezmuxbar = wezterm.plugin.require("https://github.com/abelfubu/wezmuxbar")
wezmuxbar.add_mux_bar(config, { tab_bar_position = "top", date = false, time = false })
wezmuxbar.setup_switcher(config)

wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim").apply_to_config(config, {
	direction_keys = {
		move = { "h", "j", "k", "l" },
		resize = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
	},
	modifiers = {
		move = "CTRL",
		resize = "CTRL",
	},
	log_level = "info",
})

-- wezterm.plugin.update_all()

return config
