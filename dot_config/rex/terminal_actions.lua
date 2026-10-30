local M = {}

-- Register a tab launcher. command defaults to name and is resolved on the shell's PATH.
function M.register(tool)
	rex.action({
		name = tool.name,
		title = "Open " .. tool.title,
		run = function(ctx)
			local process, process_err = rex.block.call(
				"com.superlogical.terminal",
				"process",
				{ block_id = ctx.block_id }
			)
			if not process then
				error(process_err, 0)
			end
			local cwd = process.foreground and process.foreground.cwd
			if not cwd then
				error(tool.name .. ": cannot determine the current pane's working directory", 0)
			end

			local window, err = rex.session.new_window({
				window_label = tool.title,
				focus = true,
				layout = rex.layout.block({
					flavor = "com.superlogical.terminal.shell",
					options = {
						cwd = cwd,
						theme = { background = "#1e1e2e" },
						command = {
							"/bin/sh",
							"-c",
							-- Restore the original pane's focus before the tab closes.
							[[cd "$3" && "$4"; rex focus -s "$2" "$1" >/dev/null 2>&1]],
							tool.name,
							ctx.block_id,
							ctx.session_id,
							cwd,
							tool.command or tool.name,
						},
					},
				}),
			})
			if not window then
				error(err, 0)
			end
			rex.client.queue("session.select", {
				session_id = ctx.session_id,
				window_id = window.window_id,
			})
			return window
		end,
	})
	rex.bind(tool.key, tool.name)
end

return M
