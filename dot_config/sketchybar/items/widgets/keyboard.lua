local colors = require("colors")
local settings = require("settings")
local keyboard_settings = settings.widgets.keyboard

os.execute(
	string.format(
		"sketchybar --add event %s '%s' 2>/dev/null",
		keyboard_settings.event_name,
		keyboard_settings.notification
	)
)

local keyboard = sbar.add("item", "widgets.keyboard", {
	position = "right",
	icon = { drawing = false },
	label = {
		string = keyboard_settings.default_label,
		font = settings.label_font,
		align = "left",
		padding_left = 6,
		padding_right = 6,
		width = "dynamic",
	},
})

sbar.add("bracket", "widgets.keyboard.bracket", { keyboard.name }, {
	background = colors.island,
})

sbar.add("item", "widgets.keyboard.padding", {
	position = "right",
	width = settings.group_padding,
})

local layout_script = [[
defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null | grep -w "KeyboardLayout Name" | cut -d "=" -f 2 | tr -d '"; '
]]

local function normalize_layout(raw)
	if not raw or raw == "" then
		return keyboard_settings.default_label
	end
	raw = raw:gsub("^%s*(.-)%s*$", "%1")

	local mapped_layout = keyboard_settings.layout_aliases[raw]
	if mapped_layout then
		return mapped_layout
	end

	return string.sub(raw:upper(), 1, 2)
end

local function update_layout()
	sbar.exec(layout_script, function(result)
		local label = normalize_layout(result)
		keyboard:set({ label = label })
	end)
end

keyboard:subscribe({ keyboard_settings.event_name, "system_woke" }, update_layout)

update_layout()
