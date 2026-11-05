local M = {}

-- Register a floating pane launcher. command defaults to name and is resolved on the shell's PATH.
function M.register(tool)
	rex.action({
		name = tool.name,
		title = "Open " .. tool.title,
		run = function(ctx)
			local process, process_err =
				rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
			if not process then
				error(process_err, 0)
			end
			local cwd = process.foreground and process.foreground.cwd
			if not cwd then
				error(tool.name .. ": cannot determine the current pane's working directory", 0)
			end

			local placement, placement_err = rex.session.describe_block({ block_id = ctx.block_id })
			local window_id = placement and placement.block and placement.block.window_id
			if not window_id then
				error(placement_err or (tool.name .. ": invoking pane is not in a window"), 0)
			end

			local layer, err = rex.session.new_layer({
				window_id = window_id,
				bounds = tool.bounds or { 0, 0, 1, 1 },
				focus = true,
				layout = rex.layout.block({
					flavor = "com.superlogical.terminal.shell",
					label = tool.title,
					options = {
						cwd = cwd,
						theme = { background = "#1e1e2e" },
						command = {
							"/bin/sh",
							"-c",
							[[cd "$1" && exec "$2"]],
							tool.name,
							cwd,
							tool.command or tool.name,
						},
					},
				}),
			})
			if not layer then
				error(err, 0)
			end
			return layer
		end,
	})
	rex.bind(tool.key, tool.name)
end

return M
