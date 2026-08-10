local colors = require("colors")
local settings = require("settings")

local brand_font = "GeistMono Nerd Font"

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
		string = "--",
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

local function update_usage()
	local command = "/opt/homebrew/bin/openusage export --output - --format json"
	sbar.exec(command, function(result)
		local codex_snapshot = find_snapshot(result, "codex")
		local copilot_snapshot = find_snapshot(result, "copilot")

		local codex_remaining = remaining_percent(codex_snapshot, {
			"rate_limit_secondary",
			"rate_limit_primary",
		})
		local copilot_remaining = remaining_percent(copilot_snapshot, {
			"premium_interactions_quota",
			"chat_quota",
			"completions_quota",
		})

		codex:set({ label = codex_remaining and (codex_remaining .. "%") or "--" })
		copilot:set({ label = copilot_remaining and (copilot_remaining .. "%") or "--" })
	end)

	sbar.exec("$CONFIG_DIR/plugins/kimi_usage.sh", function(result)
		local used = type(result) == "table" and tonumber(result.used) or nil
		kimi:set({ label = used and (math.floor(used + 0.5) .. "%") or "--" })
	end)
end

codex:subscribe({ "forced", "routine", "system_woke" }, update_usage)
