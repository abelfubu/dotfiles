local colors = require("colors")
local settings = require("settings")

local brand_font = "GeistMono Nerd Font"

local codex = sbar.add("item", "usage.codex", {
	position = "right",
	icon = {
		string = "",
		font = { family = brand_font, style = "Regular", size = settings.font_sizes.icon_large },
		color = colors.white,
		padding_left = 7,
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
		padding_right = 7,
	},
})

sbar.add("bracket", "usage.bracket", { codex.name, copilot.name }, {
	background = colors.island,
})

sbar.add("item", "usage.padding", {
	position = "right",
	width = settings.group_padding,
})

local function provider_remaining(provider)
	if not provider or not provider.resources then
		return nil
	end

	local lowest = nil
	for _, resource in pairs(provider.resources) do
		if type(resource) == "table" and type(resource.remaining) == "number" then
			lowest = lowest and math.min(lowest, resource.remaining) or resource.remaining
		end
	end
	return lowest
end

local function update_usage()
	local command = "/Applications/OpenUsage.app/Contents/Helpers/openusage"
	sbar.exec(command, function(result)
		if type(result) ~= "table" or type(result.providers) ~= "table" then
			codex:set({ label = "--" })
			copilot:set({ label = "--" })
			return
		end

		local codex_remaining = provider_remaining(result.providers.codex)
		local copilot_remaining = provider_remaining(result.providers.copilot)
		codex:set({ label = codex_remaining and (codex_remaining .. "%") or "--" })
		copilot:set({ label = copilot_remaining and (copilot_remaining .. "%") or "--" })
	end)
end

codex:subscribe({ "forced", "routine", "system_woke" }, update_usage)
