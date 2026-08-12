local colors = require("colors")
local settings = require("settings")
local aerospace = settings.binaries.aerospace

sbar.add("event", "aerospace_workspace_change")

local workspaces = {}
local workspace_names = {}

local function set_focused_workspace(focused)
	focused = tostring(focused or ""):gsub("%s+", "")
	for id, item in pairs(workspaces) do
		local selected = tostring(id) == focused
		item:set({
			icon = { color = selected and colors.tokyonight_bg or colors.grey },
			background = {
				drawing = true,
				color = selected and colors.tokyonight_blue or colors.transparent,
			},
		})
	end
end

for id = 1, 9 do
	local name = "aerospace.workspace." .. id
	local item = sbar.add("item", name, {
		position = "center",
		font = settings.label_font,
		icon = {
			string = tostring(id),
			padding_left = 7,
			padding_right = 7,
		},
		label = { drawing = false },
		background = {
			drawing = true,
			color = colors.transparent,
			corner_radius = 4,
			height = settings.ui.item_height,
		},
		padding_left = 2,
		padding_right = 2,
		click_script = aerospace .. " workspace " .. id,
	})

	item:subscribe("aerospace_workspace_change", function(env)
		set_focused_workspace(env.FOCUSED_WORKSPACE)
	end)

	workspaces[id] = item
	table.insert(workspace_names, item.name)
end

sbar.add("bracket", "aerospace.workspaces", workspace_names, {
	background = colors.island,
})

sbar.exec(aerospace .. " list-workspaces --focused", function(result)
	set_focused_workspace(result)
end)
