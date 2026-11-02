require("copy_mode")

do
	local ok, navigator = pcall(require, "nvim")
	if ok then
		navigator.setup()
	end
end

-- rex.bind("cmd+h", "pane.focus", { direction = "right" })
-- rex.bind("cmd+l", "pane.focus", { direction = "left" })
-- rex.bind("cmd+k", "pane.focus", { direction = "up" })
-- rex.bind("cmd+j", "pane.focus", { direction = "down" })

local terminal_actions = require("terminal_actions")

terminal_actions.register({
	name = "lazygit",
	title = "Lazygit",
	key = "cmd+g",
	command = "/opt/homebrew/bin/lazygit",
})

terminal_actions.register({
	name = "sabiql",
	title = "Sabiql",
	key = "cmd+s",
	command = "/opt/homebrew/bin/sabiql",
})
