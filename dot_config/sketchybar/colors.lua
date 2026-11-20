local settings = require("settings")

local colors = {
	black = 0xff181819,
	white = 0xffe2e2e3,
	red = 0xfffc5d7c,
	blue = 0xff76cce0,
	tokyonight_bg = 0xff1a1b26,
	yellow = 0xffe7c664,
	orange = 0xfff39660,
	grey = 0xff7f8490,
	transparent = 0x00000000,

	bar = {
		bg = 0x00000000,
	},
	popup = {
		bg = 0x00000000,
		border = 0xff7f8490,
	},
	item_container_bg = 0x10e2e2e3,
	item_container_border_bg = 0x40e2e2e3,
}

colors.island = {
	color = colors.item_container_bg,
	height = settings.ui.item_height,
	corner_radius = settings.ui.item_corner_radius,
	border_width = settings.ui.item_border_width,
	border_color = colors.item_container_border_bg,
}

return colors
