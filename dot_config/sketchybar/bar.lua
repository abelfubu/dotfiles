local colors = require("colors")
local settings = require("settings")

sbar.bar({
	height = settings.ui.bar_height,
	color = colors.bar.bg,
	padding_right = 0,
	padding_left = 1,
	display = 1,
	margin = 0,
	y_offset = 0,
	corner_radius = 0,
	border_width = 0,
	shadow = off,
})
