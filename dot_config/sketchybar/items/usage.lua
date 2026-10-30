local colors = require("colors")
local settings = require("settings")

local brand_font = settings.font.icons

local codex = sbar.add("item", "usage.codex", {
	position = "right",
	icon = {
		string = "",
		font = { family = brand_font, style = "Regular", size = settings.font_sizes.icon_large },
		color = colors.white,
		padding_left = 4,
		padding_right = 4,
	},
	label = {
		string = "-- · --",
		font = settings.label_font,
		padding_left = 0,
	},
	update_freq = 60,
})

local copilot = sbar.add("item", "usage.copilot", {
	position = "right",
	icon = {
		string = "",
		font = { family = brand_font, style = "Regular", size = settings.font_sizes.icon_large },
		color = colors.white,
		padding_left = 7,
		padding_right = 4,
	},
	label = {
		string = "--",
		font = settings.label_font,
		padding_left = 0,
		padding_right = 0,
	},
})

local kimi = sbar.add("item", "usage.kimi", {
	position = "right",
	icon = {
		string = "",
		font = { family = brand_font, style = "Regular", size = settings.font_sizes.icon_large },
		color = colors.white,
		padding_left = 7,
		padding_right = 4,
	},
	label = {
		string = "--",
		font = settings.label_font,
		padding_left = 0,
		padding_right = 0,
	},
})

local function add_usage_popup(parent, windows)
	parent:set({
		popup = {
			drawing = false,
			align = "right",
			background = {
				color = colors.black,
				border_color = colors.item_container_border_bg,
				border_width = 1,
				corner_radius = settings.ui.item_corner_radius,
			},
		},
	})

	local rows = {}
	for index, window in ipairs(windows) do
		rows[index] = sbar.add("item", parent.name .. ".detail." .. index, {
			position = "popup." .. parent.name,
			background = { height = 30 },
			icon = {
				string = window.icon .. "  " .. window.name,
				font = { family = brand_font, style = "Regular", size = settings.font_sizes.label_compact },
				color = colors.white,
				width = 100,
				align = "left",
				padding_left = 12,
			},
			label = {
				string = "-- · reset unavailable",
				font = settings.label_font,
				color = colors.grey,
				padding_left = 8,
				padding_right = 12,
			},
		})
	end

	parent:subscribe("mouse.entered", function()
		parent:set({ popup = { drawing = true } })
	end)
	parent:subscribe("mouse.exited", function()
		parent:set({ popup = { drawing = false } })
	end)
	return rows
end

local codex_details = add_usage_popup(codex, {
	{ icon = "󰥔", name = "5-hour" },
	{ icon = "󰃭", name = "Weekly" },
})
local kimi_details = add_usage_popup(kimi, {
	{ icon = "󰥔", name = "Quota" },
})

sbar.add("bracket", "usage.bracket", { codex.name, copilot.name, kimi.name }, {
	background = colors.island,
})

sbar.add("item", "usage.padding", {
	position = "right",
	width = settings.group_padding,
})

local function find_snapshot(result, provider_id)
	if type(result) ~= "table" or type(result.snapshots) ~= "table" then
		return nil
	end

	for _, snapshot in ipairs(result.snapshots) do
		if snapshot.provider_id == provider_id then
			return snapshot
		end
	end
	return nil
end

local function remaining_percent(snapshot, metric_names)
	if not snapshot or type(snapshot.metrics) ~= "table" then
		return nil
	end

	local lowest = nil
	for _, name in ipairs(metric_names) do
		local metric = snapshot.metrics[name]
		if type(metric) == "table" then
			local value = nil
			if type(metric.remaining) == "number" and type(metric.limit) == "number" and metric.limit > 0 then
				value = metric.remaining / metric.limit * 100
			elseif type(metric.used) == "number" and type(metric.limit) == "number" and metric.limit > 0 then
				value = (metric.limit - metric.used) / metric.limit * 100
			end
			if value then
				lowest = lowest and math.min(lowest, value) or value
			end
		end
	end

	return lowest and math.max(0, math.floor(lowest + 0.5)) or nil
end

local function reset_countdown(reset_at)
	if type(reset_at) ~= "string" then
		return nil
	end

	local year, month, day, hour, min, sec, fraction =
		reset_at:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)(.-)Z$")
	if not year or (fraction ~= "" and not fraction:match("^%.%d+$")) then
		return nil
	end

	-- Interpret both UTC calendars in the same timezone, with DST disabled.
	local now = os.date("!*t")
	now.isdst = false
	local reset = os.time({
		year = tonumber(year),
		month = tonumber(month),
		day = tonumber(day),
		hour = tonumber(hour),
		min = tonumber(min),
		sec = tonumber(sec),
		isdst = false,
	})
	local minutes = math.max(0, math.ceil(os.difftime(reset, os.time(now)) / 60))
	if minutes >= 1440 then
		return string.format("%dd%dh", math.floor(minutes / 1440), math.floor(minutes % 1440 / 60))
	end
	return string.format("%dh%dm", math.floor(minutes / 60), minutes % 60)
end

local function usage_label(remaining)
	return remaining and (remaining .. "%") or "--"
end

local function detail_label(remaining, reset_at)
	local label = remaining and (remaining .. "% left") or "--"
	local countdown = remaining and reset_countdown(reset_at)
	return label .. " · " .. (countdown and ("resets in " .. countdown) or "reset unavailable")
end

local function update_usage()
	local command = "/opt/homebrew/bin/openusage export --output - --format json"
	sbar.exec(command, function(result)
		local codex_snapshot = find_snapshot(result, "codex")
		local copilot_snapshot = find_snapshot(result, "copilot")

		local codex_5h_remaining = remaining_percent(codex_snapshot, { "rate_limit_primary" })
		local codex_weekly_remaining = remaining_percent(codex_snapshot, { "rate_limit_secondary" })
		local copilot_remaining = remaining_percent(copilot_snapshot, {
			"premium_interactions_quota",
			"chat_quota",
			"completions_quota",
		})

		local resets = codex_snapshot and type(codex_snapshot.resets) == "table" and codex_snapshot.resets or {}
		codex:set({
			label = usage_label(codex_5h_remaining) .. " · " .. usage_label(codex_weekly_remaining),
		})
		codex_details[1]:set({ label = detail_label(codex_5h_remaining, resets.rate_limit_primary) })
		codex_details[2]:set({ label = detail_label(codex_weekly_remaining, resets.rate_limit_secondary) })
		copilot:set({ label = copilot_remaining and (copilot_remaining .. "%") or "--" })
	end)

	sbar.exec("$CONFIG_DIR/plugins/kimi_usage.sh", function(result)
		local remaining = type(result) == "table" and tonumber(result.remaining) or nil
		local limit = type(result) == "table" and tonumber(result.limit) or nil
		local remaining_percentage = remaining
				and limit
				and limit > 0
				and math.max(0, math.floor(remaining / limit * 100 + 0.5))
			or nil
		kimi:set({ label = usage_label(remaining_percentage) })
		kimi_details[1]:set({
			label = detail_label(remaining_percentage, type(result) == "table" and result.reset_at or nil),
		})
	end)
end

codex:subscribe({ "forced", "routine", "system_woke" }, update_usage)
