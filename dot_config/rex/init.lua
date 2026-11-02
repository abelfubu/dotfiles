-- Load extensions
for _, mod in pairs({ "nvim", "resize", "copy_mode" }) do
	local ok, extension = pcall(require, mod)
	if ok then
		extension.setup()
	end
end

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
