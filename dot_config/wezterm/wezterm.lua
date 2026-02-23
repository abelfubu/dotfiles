local wezterm = require("wezterm")

local font_size = 16
local font = "JetBrainsMono Nerd Font"

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

config.color_scheme = "One Dark (Gogh)"
config.font = wezterm.font_with_fallback({ { family = font }, "JetBrainsMono Nerd Font" })
config.font_size = font_size
config.line_height = 1.6

config.window_decorations = "RESIZE"

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
		key = "/",
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
		mods = "LEADER",
		key = "LeftArrow",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		mods = "LEADER",
		key = "RightArrow",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		mods = "LEADER",
		key = "DownArrow",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
	{
		mods = "LEADER",
		key = "UpArrow",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "Enter",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		key = "m",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},
	{
		key = "s",
		mods = "CMD",
		action = wezterm.action.SendKey({ key = "s", mods = "CTRL" }),
	},
	-- {
	-- 	key = "j",
	-- 	mods = "CMD",
	-- 	action = wezterm.action.SendKey({ key = "j", mods = "CTRL" }),
	-- },
	-- {
	-- 	key = "k",
	-- 	mods = "CMD",
	-- 	action = wezterm.action.SendKey({ key = "k", mods = "CTRL" }),
	-- },
	-- {
	-- 	key = "l",
	-- 	mods = "CMD",
	-- 	action = wezterm.action.SendKey({ key = "l", mods = "CTRL" }),
	-- },
	-- {
	-- 	key = "h",
	-- 	mods = "CMD",
	-- 	action = wezterm.action.SendKey({ key = "h", mods = "CTRL" }),
	-- },
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

wezterm.plugin.require("https://github.com/abelfubu/wezmuxbar").add_mux_bar(config, {
	tab_bar_position = "top",
})

local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
-- you can put the rest of your Wezterm config here
smart_splits.apply_to_config(config, {
	-- the default config is here, if you'd like to use the default keys,
	-- you can omit this configuration table parameter and just use
	-- smart_splits.apply_to_config(config)

	-- directional keys to use in order of: left, down, up, right
	-- if you want to use separate direction keys for move vs. resize, you
	-- can also do this:
	direction_keys = {
		move = { "h", "j", "k", "l" },
		resize = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
	},
	-- modifier keys to combine with direction_keys
	modifiers = {
		move = "CTRL", -- modifier to use for pane movement, e.g. CTRL+h to move left
		resize = "CTRL", -- modifier to use for pane resize, e.g. META+h to resize to the left
	},
	-- log level to use: info, warn, error
	log_level = "info",
})

-- wezterm.plugin.update_all()

return config
