local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local wifi = sbar.add("item", "widgets.wifi", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Bold"],
			size = settings.font_sizes.icon_medium,
		},
		padding_left = 8,
		padding_right = 8,
	},
	label = { drawing = false },
})

sbar.add("bracket", "widgets.wifi.bracket", {
	wifi.name,
}, {
	background = colors.island,
})

sbar.add("item", "widgets.wifi.padding", {
	position = "right",
	width = settings.group_padding,
})

local network_script = [[
VPN_STATUS="OFF"
if scutil --nwi | grep -m1 'VPN' >/dev/null; then
  VPN_STATUS="ON"
fi

IFACE="__NETWORK_INTERFACE__"
WIFI_POWER=$(networksetup -getairportpower "$IFACE" | awk '{print $4}')
if [ "$WIFI_POWER" = "Off" ]; then
  CONN="OFF"
else
  SUMMARY=$(ipconfig getsummary "$IFACE")
  SSID=$(printf "%s\n" "$SUMMARY" | awk -F ' SSID : ' '/ SSID : / {print $2}')
  if [ -n "$SSID" ]; then
    if printf "%s\n" "$SUMMARY" | grep -qE '^ *sname = [a-zA-Z0-9]'; then
      CONN="HOTSPOT"
    else
      CONN="WIFI"
    fi
  elif [ -n "$(ipconfig getifaddr "$IFACE")" ]; then
    CONN="ETHERNET"
  else
    CONN="NO_INTERNET"
  fi
fi
echo "${VPN_STATUS}|${CONN}"
]]
network_script = network_script:gsub("__NETWORK_INTERFACE__", settings.network.interface)

local function update_wifi()
	sbar.exec(network_script, function(result)
		result = result:gsub("^%s*(.-)%s*$", "%1")
		local vpn_status, connection_type = result:match("([^|]+)|([^|]+)")
		local icon
		local color

		if connection_type == "WIFI" then
			icon = (vpn_status == "ON") and icons.wifi.vpn or icons.wifi.connected
			color = (vpn_status == "ON") and colors.blue or colors.white
		elseif connection_type == "HOTSPOT" then
			icon = icons.wifi.hotspot
			color = (vpn_status == "ON") and colors.blue or colors.white
		elseif connection_type == "ETHERNET" then
			icon = icons.wifi.ethernet
			color = (vpn_status == "ON") and colors.blue or colors.white
		elseif connection_type == "NO_INTERNET" then
			icon = icons.wifi.disconnected
			color = colors.yellow
		else
			icon = icons.wifi.disconnected
			color = colors.red
		end

		wifi:set({
			icon = { string = icon, color = color },
		})
	end)
end

wifi:subscribe({ "wifi_change", "system_woke" }, update_wifi)

wifi:subscribe("mouse.clicked", function(env)
	if env.BUTTON == "right" then
		sbar.exec("open 'x-apple.systempreferences:com.apple.wifi-settings-extension'")
		return
	end

	local toggle_script = string.format([[
IFACE="%s"
STATUS=$(networksetup -getairportpower "$IFACE" | awk '{print $4}')
if [ "$STATUS" = "On" ]; then
  networksetup -setairportpower "$IFACE" off
else
  networksetup -setairportpower "$IFACE" on
fi
]], settings.network.interface)

	sbar.exec(toggle_script, function()
		sbar.exec("sleep 1", update_wifi)
	end)
end)

sbar.exec("sleep 0.1", update_wifi)
