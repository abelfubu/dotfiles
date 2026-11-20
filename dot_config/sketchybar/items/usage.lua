local colors = require("colors")
local settings = require("settings")

local brand_font = settings.font.icons
local tiny = settings.font_sizes.tiny
local popup_width = 240
local col_width = 24

-- ---------------------------------------------------------------------------
-- Bar: per provider a brand glyph followed by two stacked small values
-- (primary on top in white, secondary below in grey — openusage.ai style).
-- One sketchybar item can only hold an icon + a label, so the values live in
-- a single item: the icon carries the top value at a fixed width and the
-- label is pulled back underneath it with a negative left padding.
-- ---------------------------------------------------------------------------

local function add_provider(name, icon_string)
	local values = sbar.add("item", "usage." .. name .. ".values", {
		position = "right",
		padding_left = 0,
		padding_right = 2,
		update_freq = 120,
		icon = {
			string = "--",
			font = { family = settings.font.icons, style = "Regular", size = tiny },
			color = colors.white,
			width = col_width,
			align = "left",
			padding_left = 0,
			padding_right = 0,
			-- positive y_offset renders UP in sketchybar
			y_offset = 5,
		},
		label = {
			string = "--",
			font = { family = settings.font.text, style = "Regular", size = tiny },
			color = colors.grey,
			padding_left = -col_width,
			padding_right = 0,
			y_offset = -5,
		},
	})

	local icon = sbar.add("item", "usage." .. name .. ".icon", {
		position = "right",
		padding_left = 0,
		icon = {
			string = icon_string,
			font = { family = brand_font, style = "Light", size = settings.font_sizes.icon_large },
			color = colors.white,
			padding_left = 9,
			padding_right = 0,
		},
		label = { drawing = false },
	})

	return icon, values
end

-- Added right-to-left: codex ends up nearest the screen edge.
-- Right-edge spacer first: it lands outermost (rightmost).
sbar.add("item", "usage.padding_right", {
	position = "right",
	width = 8,
})

local codex_icon, codex_values = add_provider("codex", "")
local copilot_icon, copilot_values = add_provider("copilot", "")
local kimi_icon, kimi_values = add_provider("kimi", "")

-- The group's popup lives on the copilot item, centered under the group.

sbar.add("bracket", "usage.bracket", {
	"usage.padding_right",
	codex_icon.name,
	codex_values.name,
	copilot_icon.name,
	copilot_values.name,
	kimi_icon.name,
	kimi_values.name,
}, {
	background = colors.island,
})

sbar.add("item", "usage.padding", {
	position = "right",
	width = settings.group_padding,
})

-- ---------------------------------------------------------------------------
-- Popup: one window with a section per provider (openusage.ai style)
-- ---------------------------------------------------------------------------

local popup_rows = {}

local function add_section_header(name, icon_string, title)
	sbar.add("item", "usage.popup." .. name, {
		position = "popup." .. copilot_values.name,
		background = { height = 26 },
		icon = {
			string = icon_string,
			font = { family = brand_font, style = "Light", size = settings.font_sizes.icon },
			color = colors.white,
			padding_left = 12,
		},
		label = {
			string = title,
			font = { family = settings.font.text, style = "Bold", size = settings.font_sizes.label_compact },
			color = colors.white,
			padding_right = 12,
		},
	})
end

local function add_metric_row(key, title)
	local row = sbar.add("item", "usage.popup." .. key, {
		position = "popup." .. copilot_values.name,
		width = popup_width,
		background = { height = 20 },
		icon = {
			string = title,
			font = { family = settings.font.text, style = "Regular", size = tiny },
			color = colors.grey,
			width = 160,
			align = "left",
			padding_left = 16,
		},
		label = {
			string = "--",
			font = { family = settings.font.text, style = "Semibold", size = tiny },
			color = colors.white,
			width = 60,
			align = "right",
			padding_right = 12,
		},
	})
	popup_rows[key] = row
	return row
end

add_section_header("codex", "", "Codex")
add_metric_row("codex.5h", "5-hour")
add_metric_row("codex.weekly", "Weekly")
add_section_header("copilot", "", "GitHub Copilot")
add_metric_row("copilot.premium", "Premium requests")
add_section_header("kimi", "", "Kimi")
add_metric_row("kimi.quota", "Quota")

copilot_values:set({
	popup = {
		drawing = false,
		align = "center",
		background = {
			color = colors.black,
			border_color = colors.item_container_border_bg,
			border_width = 1,
			corner_radius = settings.ui.item_corner_radius,
		},
	},
})

local popup_open = false
local bar_items = { codex_icon, codex_values, copilot_icon, copilot_values, kimi_icon, kimi_values }
for _, item in ipairs(bar_items) do
	item:subscribe("mouse.clicked", function()
		popup_open = not popup_open
		copilot_values:set({ popup = { drawing = popup_open } })
	end)
end

-- ---------------------------------------------------------------------------
-- Data
-- ---------------------------------------------------------------------------

local state = {
	codex = { five_hr = nil, weekly = nil, five_hr_reset = nil, weekly_reset = nil },
	copilot = { remaining = nil, reset = nil },
	kimi = { remaining = nil, reset = nil },
}

local function usage_label(remaining)
	return remaining and (remaining .. "%") or "--"
end

local function percent_color(remaining)
	if not remaining then
		return colors.grey
	end
	if remaining > 30 then
		return colors.blue
	end
	if remaining > 10 then
		return colors.orange
	end
	return colors.red
end

-- Accepts a unix timestamp, an ISO 8601 string, or a "YYYY-MM-DD" date;
-- returns a "2d3h" / "3h12m" / "12d" countdown.
local function reset_countdown(reset_at)
	local reset
	if type(reset_at) == "number" then
		reset = reset_at
	elseif type(reset_at) == "string" then
		local year, month, day, hour, min, sec = reset_at:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)[T ](%d%d):(%d%d):(%d%d)")
		if not year then
			year, month, day = reset_at:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
			hour, min, sec = 0, 0, 0
		end
		if not year then
			return nil
		end
		reset = os.time({
			year = tonumber(year),
			month = tonumber(month),
			day = tonumber(day),
			hour = tonumber(hour),
			min = tonumber(min),
			sec = tonumber(sec),
			isdst = false,
		})
	end
	if not reset then
		return nil
	end

	local now = os.time(os.date("!*t"))
	local minutes = math.max(0, math.ceil(os.difftime(reset, now) / 60))
	if minutes >= 1440 then
		local days = math.floor(minutes / 1440)
		local hours = math.floor(minutes % 1440 / 60)
		return hours > 0 and (days .. "d" .. hours .. "h") or (days .. "d")
	end
	return string.format("%dh%dm", math.floor(minutes / 60), minutes % 60)
end

-- Compact variant for the tiny bar label: drop hours once we're in days.
local function bar_reset(reset_at)
	local cd = reset_countdown(reset_at)
	if not cd then
		return "--"
	end
	local days = cd:match("^(%d+d)%d+h$")
	return days or cd
end

local function window_remaining(window)
	if type(window) ~= "table" then
		return nil
	end
	local used = tonumber(window.used_percent)
	if not used then
		return nil
	end
	return math.max(0, math.min(100, math.floor(100 - used + 0.5)))
end

local function render_metric(key, title, remaining, reset_at)
	local countdown = reset_countdown(reset_at)
	popup_rows[key]:set({
		icon = { string = countdown and (title .. " · " .. countdown) or title },
		label = { string = usage_label(remaining), color = percent_color(remaining) },
	})
end

local function render()
	codex_values:set({
		icon = { string = usage_label(state.codex.five_hr) },
		label = { string = usage_label(state.codex.weekly) },
	})
	copilot_values:set({
		icon = { string = usage_label(state.copilot.remaining) },
		label = { string = state.copilot.reset and bar_reset(state.copilot.reset) or "--" },
	})
	kimi_values:set({
		icon = { string = usage_label(state.kimi.remaining) },
		label = { string = state.kimi.reset and bar_reset(state.kimi.reset) or "--" },
	})

	render_metric("codex.5h", "5-hour", state.codex.five_hr, state.codex.five_hr_reset)
	render_metric("codex.weekly", "Weekly", state.codex.weekly, state.codex.weekly_reset)
	render_metric("copilot.premium", "Premium requests", state.copilot.remaining, state.copilot.reset)
	render_metric("kimi.quota", "Quota", state.kimi.remaining, state.kimi.reset)
end

-- ---------------------------------------------------------------------------
-- Fetchers
-- ---------------------------------------------------------------------------

local codex_fetch = [[
TOKEN=$(python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.codex/auth.json')))['tokens']['access_token'])" 2>/dev/null)
[ -n "$TOKEN" ] && curl -sf -m 10 "https://chatgpt.com/backend-api/wham/usage" \
	-H "Authorization: Bearer $TOKEN" \
	-H "Originator: codex_cli_rs" \
	-H "Accept: application/json"
]]

local copilot_fetch = [[
TOKEN=$(gh auth token 2>/dev/null)
[ -n "$TOKEN" ] && curl -sf -m 10 "https://api.github.com/copilot_internal/user" \
	-H "Authorization: Bearer $TOKEN" \
	-H "Accept: application/json"
]]

local function update_usage()
	sbar.exec(codex_fetch, function(result)
		local rate_limit = type(result) == "table" and result.rate_limit or nil
		local primary = rate_limit and rate_limit.primary_window or nil
		local secondary = rate_limit and rate_limit.secondary_window or nil
		state.codex.five_hr = window_remaining(primary)
		state.codex.weekly = window_remaining(secondary)
		state.codex.five_hr_reset = primary and primary.reset_at or nil
		state.codex.weekly_reset = secondary and secondary.reset_at or nil
		render()
	end)

	sbar.exec(copilot_fetch, function(result)
		local snapshots = type(result) == "table" and result.quota_snapshots or nil
		local premium = snapshots and snapshots.premium_interactions or nil
		if premium then
			state.copilot.remaining = premium.unlimited and 100
				or math.max(0, math.floor(tonumber(premium.percent_remaining) + 0.5))
		end
		if type(result) == "table" and result.quota_reset_date then
			state.copilot.reset = result.quota_reset_date
		end
		render()
	end)

	sbar.exec("$CONFIG_DIR/plugins/kimi_usage.sh", function(result)
		local remaining = type(result) == "table" and tonumber(result.remaining) or nil
		local limit = type(result) == "table" and tonumber(result.limit) or nil
		if remaining and limit and limit > 0 then
			state.kimi.remaining = math.max(0, math.floor(remaining / limit * 100 + 0.5))
		end
		state.kimi.reset = type(result) == "table" and result.reset_at or nil
		render()
	end)
end

codex_values:subscribe({ "forced", "routine", "system_woke" }, update_usage)

update_usage()
