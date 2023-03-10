-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")



-- create battery object
local battery = {}

-- create an imagebox widget
battery.batteryiconwidget = wibox.widget {
    {
        image = gears.filesystem.get_configuration_dir() .. "images/battery-icon.jpg",
        resize = true,
        widget = wibox.widget.imagebox
    },
    layout = wibox.container.margin(_, _, _, 4)
}



-- battery widget
battery.batterywidget = wibox.widget.textbox()


battery.update_battery_widget = function ()
    local command = "acpi -b"
    local command_output, command_exitcode = get_command_output(command)
    if string.match( command_output, "No support for device type: power_supply") then
        -- batterywidget:set_text(" No Battery ")
        battery.batterywidget:set_text("  ".."AC".."  ")
    else
        battery.batterywidget:set_text( command_output )
    end
end


return battery
