local settings = require("settings")
local colors = require("colors")

sbar.add("item", "calendar.left.padding", {
	position = "right",
	width = settings.group_padding,
})

local cal = sbar.add("item", {
	icon = {
		drawing = false,
	},
	label = {
		color = colors.white,
		padding_left = 8,
		padding_right = 8,
		width = "dynamic",
		font = settings.label_font,
	},
	position = "right",
	update_freq = settings.widgets.calendar.update_freq,
	padding_left = 1,
	padding_right = 1,
})

sbar.add("bracket", { cal.name }, {
	background = colors.island,
})

sbar.add("item", "calendar.right.padding", {
	position = "right",
	width = settings.group_padding,
})

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
	cal:set({
		label = {
			string = os.date("%d/%m, %H:%M"),
		},
	})
end)
