local settings = require("settings")
local colors = require("colors")
local icons = require("icons")

sbar.add("item", "calendar.left.padding", {
	position = "right",
	width = settings.group_padding,
})

local function add_datetime_item(icon, color)
	return sbar.add("item", {
		icon = {
			string = icon,
			color = color,
			padding_right = 2,
			font = {
				style = "Light",
				size = settings.font_sizes.icon_large,
			},
		},
		label = {
			color = colors.white,
			padding_left = 4,
			padding_right = 4,
			width = "dynamic",
			font = settings.label_font,
		},
		position = "right",
		update_freq = settings.widgets.calendar.update_freq,
		padding_left = 1,
		padding_right = 1,
	})
end

local clock = add_datetime_item(icons.clock, colors.orange)
local cal = add_datetime_item(icons.calendar, colors.blue)

sbar.add("bracket", { cal.name, clock.name }, {
	background = colors.island,
})

sbar.add("item", "calendar.right.padding", {
	position = "right",
	width = settings.group_padding,
})

cal:subscribe({ "forced", "routine", "system_woke" }, function()
	cal:set({ label = { string = os.date("%Y-%m-%d") } })
end)

clock:subscribe({ "forced", "routine", "system_woke" }, function()
	clock:set({ label = { string = os.date("%H:%M") } })
end)
