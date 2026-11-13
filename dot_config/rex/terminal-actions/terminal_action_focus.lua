-- Runs separately so it survives the tool terminal exiting or being closed.
local args = rex.args

local function restore_focus()
	local source = rex.session.describe_block({ block_id = args.source_block_id })
	if source and source.block.window_id then
		local focused, err = rex.session.focus_block({ block_id = args.source_block_id })
		if not focused then
			error(err, 0)
		end
		rex.client.queue("session.select", {
			session_id = args.session_id,
			window_id = source.block.window_id,
		})
	end
	rex.stop()
end

rex.on("window_closed", function(_, event)
	if event.window_id == args.window_id then
		restore_focus()
	end
end)

-- The tool may have exited before this watcher attached. Check after subscribing.
local view, err = rex.session.view({})
if not view then
	error(err, 0)
end
for _, window in ipairs(view.windows or {}) do
	if window.window_id == args.window_id then
		return
	end
end
restore_focus()
