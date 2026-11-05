for _, mod in pairs({
	{ "nvim" },
	{ "copy_mode" },
	{ "resize" },
}) do
	do
		local ok, extension = pcall(require, mod[1])
		if ok then
			extension.setup(mod[2] or {})
		end
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

-- >>> md-viewer: Cmd-F binding (managed by md-viewer setup; edits are replaced) >>>
local function md_viewer_pane(block)
	if block == nil then
		return false
	end
	local terminal = "com.superlogical.terminal"
	local process = rex.block.call(terminal, "process", { block_id = block })
	if process ~= nil then
		return process.foreground ~= nil and process.foreground.name == "md-viewer"
	end
	local listed = rex.session.list_blocks({})
	for _, entry in ipairs((listed or {}).blocks or {}) do
		if entry.block_id == block then
			return entry.label == "md-viewer"
		end
	end
	return false
end

rex.action({
	name = "md_viewer_find",
	title = "Find (md-viewer aware)",
	description = "Opens md-viewer's find in an md-viewer pane and Rex's Find everywhere else.",
	run = function(ctx, args)
		if md_viewer_pane(ctx.block_id) then
			local _, err =
				rex.block.call("com.superlogical.terminal", "write", { block_id = ctx.block_id, data = "\27[102;9u" })
			if err == nil then
				return { target = "md-viewer" }
			end
		end
		rex.client.queue("client.find.open")
		return { target = "rex" }
	end,
})

rex.bind("cmd+f", "md_viewer_find")
-- <<< md-viewer <<<
