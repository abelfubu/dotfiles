local wezterm = require("wezterm")

local font_size = 16
local font = "JetBrainsMono Nerd Font"

local starting_apps = {
	{ name = "server", cwd = "/dev/nomo-server-app/", command = "nvim\n" },
	{ name = "web", cwd = "/dev/nomo-web-app/", command = "nvim\n" },
	{ name = "mobile", cwd = "/dev/nomo-mobile-app/", command = "nvim\n" },
	{ name = "notes", cwd = "/Nextcloud/Brain/" },
}

wezterm.on("gui-startup", function()
	local tab, pane, window = wezterm.mux.spawn_window({
		cwd = wezterm.home_dir .. "/dev",
	})

	window:gui_window():maximize()
	-- pane:send_text("nvim\n")
	tab:set_title("shell")

	-- for _, app in ipairs(starting_apps) do
	-- 	local new_tab, new_pane = tab:window():spawn_tab({ cwd = wezterm.home_dir .. app.cwd })
	-- 	new_tab:set_title(app.name)
	-- 	new_pane:send_text(app.command)
	-- end

	window:gui_window():perform_action(wezterm.action.ActivateTab(0), pane)

	local tab, pane, window = wezterm.mux.spawn_window({
		cwd = wezterm.home_dir .. "/Nextcloud/Brain/",
		args = { "nvim" },
	})

	window:gui_window():maximize()
	-- pane:send_text("nvim\n")
	tab:set_title("notes")
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

config.leader = { key = "t", mods = "ALT", timeout_milliseconds = 5000 }

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
		key = "S",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			-- Here you can dynamically construct a longer list if needed

			local home = wezterm.home_dir
			local workspaces = {
				{ id = home, label = "Home" },
				{ id = home .. "/work", label = "Work" },
				{ id = home .. "/personal", label = "Personal" },
				{ id = home .. "/.config", label = "Config" },
			}

			window:perform_action(
				wezterm.action.InputSelector({
					action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
						if not id and not label then
							wezterm.log_info("cancelled")
						else
							wezterm.log_info("id = " .. id)
							wezterm.log_info("label = " .. label)
							inner_window:perform_action(
								wezterm.action.SwitchToWorkspace({
									name = label,
									spawn = {
										label = "Workspace: " .. label,
										cwd = id,
									},
								}),
								inner_pane
							)
						end
					end),
					title = "Choose Workspace",
					choices = workspaces,
					fuzzy = true,
					fuzzy_description = "Fuzzy find and/or make a workspace",
				}),
				pane
			)
		end),
	},
}

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
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

wezterm.plugin.update_all()

return config
