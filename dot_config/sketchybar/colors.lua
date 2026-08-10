local settings = require("settings")

local colors = {
	black = 0xff181819,
	white = 0xffe2e2e3,
	red = 0xfffc5d7c,
	green = 0xff9ed072,
	blue = 0xff76cce0,
	tokyonight_blue = 0xff7aa2f7,
	tokyonight_bg = 0xff1a1b26,
	yellow = 0xffe7c664,
	orange = 0xfff39660,
	magenta = 0xffb39df3,
	grey = 0xff7f8490,
	transparent = 0x00000000,

	bar = {
		bg = 0xb3202020,
		border_color = 0x35e2e2e3,
		-- bg = 0x00ffffff,
		-- border_color = 0x00ffffff,
		blur = 12,
	},
	popup = {
		bg = 0x00000000,
		border = 0xff7f8490,
	},
	item_container_bg = 0x10e2e2e3,
	-- item_container_bg = 0x00e2e2e3,
	item_container_border_bg = 0x40e2e2e3,

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}

colors.island = {
	color = colors.item_container_bg,
	height = settings.ui.item_height,
	corner_radius = settings.ui.item_corner_radius,
	border_width = settings.ui.item_border_width,
	border_color = colors.item_container_border_bg,
}

return colors
