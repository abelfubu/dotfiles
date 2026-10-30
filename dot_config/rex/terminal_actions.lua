local M = {}
local config_dir = (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") .. "/rex"
-- The app's server PATH does not necessarily include the bundled Rex CLI.
local rex_command = os.getenv("HOME")
	.. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"

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
							[[cd "$1" && exec "$2"]],
							tool.name,
							cwd,
							tool.command or tool.name,
						},
					},
				}),
			})
			if not window then
				error(err, 0)
			end
			local watcher, watcher_err = rex.exec.start({
				rex_command, "-C", ctx.client_id,
				"do", "-s", ctx.session_id,
				config_dir .. "/terminal_action_focus.lua",
				"session_id=" .. ctx.session_id,
				"window_id=" .. window.window_id,
				"source_block_id=" .. ctx.block_id,
			}, { detach = true })
			if not watcher then
				error(watcher_err, 0)
			end
			local startup = watcher:wait(0.1)
			if startup and not startup.ok then
				error("Focus watcher failed: " .. startup.stderr, 0)
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
