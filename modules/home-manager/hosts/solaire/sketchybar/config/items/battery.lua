local constants = require("constants")
local settings = require("config.settings")

local isCharging = false

local battery = sbar.add("item", constants.items.battery, {
  position = "right",
  update_freq = 60,
  label = {
    color = settings.colors.white,
    padding_left = 8,
  },
  background = {
    padding_left = 8,
    padding_right = 8,
  }
})

local batteryPopup = sbar.add("item", {
  position = "popup." .. battery.name,
  width = "dynamic",
  icon = {
    padding_left = 0,
    padding_right = 0,
  },
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
  sbar.exec("pmset -g batt", function(batteryInfo)
    local icon = "!"
    local label = "?"

    local found, _, charge = batteryInfo:find("(%d+)%%")
    if found then
      charge = tonumber(charge)
      label = charge .. "%"
    end

    local color = settings.colors.green
    local charging, _, _ = batteryInfo:find("AC Power")

    isCharging = charging

    if charging then
      icon = settings.icons.text.battery.charging
    else
      if found and charge > 20 then
        icon = settings.icons.text.battery._25
        color = settings.colors.white
      else
        icon = settings.icons.text.battery._0
        color = settings.colors.red
      end
    end

    local lead = ""
    if found and charge < 10 then
      lead = "0"
    end

    battery:set({
      icon = {
        string = icon,
        color = color
      },
      label = {
        string = lead .. label,
      },
    })
  end)
end)

battery:subscribe("mouse.clicked", function(env)
  local drawing = battery:query().popup.drawing

  battery:set({ popup = { drawing = "toggle" } })

  if drawing == "off" then
    sbar.exec("pmset -g batt", function(batteryInfo)
      local found, _, remaining = batteryInfo:find("(%d+:%d+) remaining")
      local label = found and ("Time remaining: " .. remaining .. "h") or (isCharging and "Charging" or "No estimate")
      batteryPopup:set({ label = label })
    end)
  end
end)
