return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		--- @type snacks.Config
		opts = {
			indent = { enabled = false, animate = { enabled = false } },
			lazygit = { enabled = true },
			zen = { toggles = { dim = false }, show = { statusline = true } },
			notifier = { enabled = false },
			terminal = { enabled = true },
			explorer = {
				dim = { enabled = false },
				replace_netrw = true,
			},
			picker = {
				-- layout = { preset = "select", layout = { max_width = 70 } },
				layout = { preset = "custom" },
				layouts = {
					custom = {
						layout = {
							box = "vertical",
							backdrop = false,
							row = -1,
							width = 0,
							height = 0.6,
							border = "top",
							title = " {title} {live} {flags}",
							title_pos = "left",
							{ win = "input", height = 1, border = "bottom" },
							{
								box = "horizontal",
								{ win = "list", border = "none" },
								{ win = "preview", title = "{preview}", width = 0.6, border = "none" },
							},
						},
					},
				},
				formatters = {
					ui_select = true,
					file = {
						filename_first = true,
					},
				},
				sources = {
					explorer = {
						layout = {
							preset = "vscode",
							cycle = false,
							layout = { position = "right", width = 0.33 },
						},
					},
				},
			},
			dashboard = {
				enabled = true,
				width = 30,
				preset = {
					header = [[
abelfubu
          ]],
          -- stylua: ignore
          keys = {
            { icon = " ", key = "f", desc = "[F]ind File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "[N]ew File", action = ":ene | startinsert" },
            { icon = " ", key = "d", desc = "Fin[d] Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "[R]ecent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "[C]onfig", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})", },
            { icon = " ", key = "s", desc = "Restore [S]ession", section = "session" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "[Q]uit", action = ":qa" },
          },
				},
				sections = {
					{ { section = "header" }, { section = "keys", gap = 1, padding = 1 } },
				},
			},
		},
	},
}
