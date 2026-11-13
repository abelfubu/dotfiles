local M = {}

M.setup = function()
	rex.mode("resize", { exclusive = true })
	rex.bind("cmd+r", "client.mode.enter", { name = "resize" })

	rex.bind("resize/h", "pane.resize", { direction = "left" })
	rex.bind("resize/l", "pane.resize", { direction = "right" })
	rex.bind("resize/k", "pane.resize", { direction = "up" })
	rex.bind("resize/j", "pane.resize", { direction = "down" })

	-- Hold shift for bigger steps
	rex.bind("resize/shift+h", "pane.resize", {
		direction = "left",
		amount = 15,
	})
	rex.bind("resize/shift+l", "pane.resize", {
		direction = "right",
		amount = 15,
	})

	rex.bind("resize/=", "pane.balance")
	rex.bind("resize/enter", "client.mode.exit")
end

return M
