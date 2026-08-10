local font = require("helpers.default_font")

local ui = {
	bar_height = 32,
	item_height = 22,
	item_corner_radius = 6,
	item_border_width = 0,
	item_image_corner_radius = 8,
}

local sizes = {
	icon = 13.0,
	icon_medium = 14.0,
	icon_large = 16.0,
	label = 14.0,
	label_compact = 13.0,
	label_small = 10.0,
	app = 14.0,
}

local widgets = {
	calendar = {
		update_freq = 30,
	},
	cpu = {
		poll_seconds = 5.0,
		label_width = 33,
		thresholds = {
			medium = 30,
			high = 60,
			critical = 80,
		},
	},
	volume = {
		label_width = 25,
	},
	battery = {
		update_freq = 180,
	},
	keyboard = {
		default_label = "??",
		event_name = "input_change",
		notification = "AppleSelectedInputSourcesChangedNotification",
		layout_aliases = {
			Russian = "RU",
			RussianWin = "RU",
			ABC = "EN",
			["U.S."] = "EN",
			US = "EN",
		},
	},
}

return {
	ui = ui,
	font_sizes = sizes,

	paddings = 3,
	group_padding = 3,

	icons = "NerdFont",

	font = font,
	label_font = {
		family = font.text,
		style = font.style_map["Bold"],
		size = sizes.label_compact,
	},
	binaries = {
		aerospace = os.getenv("AEROSPACE_BIN") or "/opt/homebrew/bin/aerospace",
	},
	network = {
		interface = os.getenv("SKETCHYBAR_NET_IFACE") or "en0",
	},
	widgets = widgets,
}
