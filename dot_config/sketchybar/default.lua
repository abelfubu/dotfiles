local settings = require("settings")
local colors = require("colors")

sbar.default({
	updates = "when_shown",
	icon = {
		font = {
			family = settings.font.icons,
			style = settings.font.style_map["Bold"],
			size = settings.font_sizes.icon,
		},
		color = colors.white,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
		background = { image = { corner_radius = settings.ui.item_corner_radius } },
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Semibold"],
			size = settings.font_sizes.label,
		},
		color = colors.white,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
	},
	background = {
		height = settings.ui.item_height,
		corner_radius = settings.ui.item_corner_radius,
		border_width = settings.ui.item_border_width,
		border_color = colors.bg2,
		image = {
			corner_radius = settings.ui.item_image_corner_radius,
			border_color = colors.grey,
			border_width = 2,
		},
	},
	popup = {
		background = {
			border_width = settings.ui.item_border_width,
			corner_radius = settings.ui.item_corner_radius,
			border_color = colors.popup.border,
			color = colors.popup.bg,
			shadow = { drawing = true },
		},
		blur_radius = 50,
	},
	padding_left = 5,
	padding_right = 5,
	scroll_texts = true,
})
