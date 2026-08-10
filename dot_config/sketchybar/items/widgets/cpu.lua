local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

sbar.exec(
	string.format(
		"killall cpu_load >/dev/null 2>&1; exec $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update %.1f",
		settings.widgets.cpu.poll_seconds
	)
)

local cpu = sbar.add("item", "widgets.cpu", {
	position = "right",
	background = {
		height = settings.ui.item_height,
		color = { alpha = 0 },
		border_color = { alpha = 0 },
		drawing = true,
	},
	icon = {
		string = icons.cpu,
		color = colors.blue,
		padding_right = settings.paddings + 3,
	},
	label = {
		string = "cpu ??%",
		font = settings.label_font,
		align = "left",
		padding_left = 0,
		width = settings.widgets.cpu.label_width,
	},
	padding_right = settings.paddings,
})

local function get_cpu_color(load)
	local thresholds = settings.widgets.cpu.thresholds
	if load > thresholds.critical then
		return colors.red
	end
	if load > thresholds.high then
		return colors.orange
	end
	if load > thresholds.medium then
		return colors.yellow
	end
	return colors.blue
end

cpu:subscribe("cpu_update", function(env)
	local load = tonumber(env.total_load)

	cpu:set({
		icon = { color = get_cpu_color(load) },
		label = env.total_load .. "%",
	})
end)

sbar.add("bracket", "widgets.cpu.bracket", { cpu.name }, {
	background = colors.island,
})

sbar.add("item", "widgets.cpu.padding", {
	position = "right",
	width = settings.group_padding,
})
