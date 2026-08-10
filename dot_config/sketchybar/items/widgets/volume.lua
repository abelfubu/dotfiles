local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local volume_percent = sbar.add("item", "widgets.volume.percent", {
	position = "right",
	icon = { drawing = false },
	label = {
		string = "??%",
		padding_left = -1,
		font = settings.label_font,
	},
})

local volume_icon = sbar.add("item", "widgets.volume.icon", {
	position = "right",
	padding_right = -1,
	icon = {
		string = icons.volume._100,
		width = 0,
		align = "left",
		color = colors.grey,
		font = {
			style = settings.font.style_map["Regular"],
			size = settings.font_sizes.icon,
		},
	},
	label = {
		width = settings.widgets.volume.label_width,
		align = "left",
		font = {
			family = settings.font.icons,
			style = settings.font.style_map["Regular"],
			size = settings.font_sizes.label,
		},
	},
})

sbar.add("bracket", "widgets.volume.bracket", {
	volume_icon.name,
	volume_percent.name,
}, {
	background = colors.island,
})

sbar.add("item", "widgets.volume.padding", {
	position = "right",
	width = settings.group_padding,
})

volume_percent:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO)
	local icon = icons.volume._0
	if volume > 60 then
		icon = icons.volume._100
	elseif volume > 30 then
		icon = icons.volume._66
	elseif volume > 10 then
		icon = icons.volume._33
	elseif volume > 0 then
		icon = icons.volume._10
	end

	local lead = ""
	if volume < 10 then
		lead = "0"
	end

	volume_icon:set({ label = icon })
	volume_percent:set({ label = lead .. volume .. "%" })
end)

local function handle_volume_click(env)
	if env.BUTTON == "right" then
		sbar.exec("open 'x-apple.systempreferences:com.apple.Sound-Settings.extension'")
	else
		sbar.exec("osascript -e 'set volume output muted not (output muted of (get volume settings))'")
	end
end

local function handle_volume_scroll(env)
	local delta = tonumber(env.SCROLL_DELTA) or 0
	if delta == 0 then
		return
	end

	local change = delta > 0 and 3 or -3
	sbar.exec(
		"osascript -e 'set currentVolume to output volume of (get volume settings)' "
			.. "-e 'set volume output volume (currentVolume + "
			.. change
			.. ")'"
	)
end

for _, item in ipairs({ volume_icon, volume_percent }) do
	item:subscribe("mouse.clicked", handle_volume_click)
	item:subscribe("mouse.scrolled", handle_volume_scroll)
end
