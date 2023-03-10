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


-- define volume object
volume = {}

-- volume widget
volume.volumewidget = wibox.widget.textbox()

function volume.update_volume_widget ()
    local command = 'amixer get Master | grep -oE "[0-9]+%"'
    local command_output, command_exitcode = get_command_output(command)

    -- local str = "70%"
    local str = command_output
    local number = tonumber(string.match(str, "%d+"))

    if 1==1 then
        -- volumewidget:set_text(" Volume : "..command_output)
        volume.volumewidget:set_text("  "..number.."%  ")
    else
        volume.volumewidget:set_text( command_output )
    end
end






-- Volume

-- Create a slider widget
volume.volumeslider = wibox.widget {

    forced_width = 200,
    forced_height = 20,
    bar_border_color    = beautiful.border_color,
    bar_border_width    = 1,
    bar_margins         = {},
    handle_color        = "#00ff00",
    handle_border_color = beautiful.border_color,
    handle_border_width = 1,
    widget              = wibox.widget.slider,
    maximum = 100,
    minimum = 0,
    value = 50,
}

-- Connect the slider widget to the progressbar widget
 volume.volumeslider:connect_signal("property::value", function()
     -- myprogressbar.value = volumeslider.value
    local value = volume.volumeslider.value
    local command = "amixer set Master "..value.."% "
    -- amixer set Master 66%
    local exit_status = os.execute(command .. " >/dev/null 2>&1")
    volume.update_volume_widget()


 end)


-- Create a popup widget
-- local volumesliderpopup = awful.popup {
--     widget = volumeslider,
--     -- placement = awful.placement.centered,
--     placement = awful.placement.centered,
--     -- placement = awful.placement.next_to(volumewidget),
--     shape = function(cr, width, height)
--         gears.shape.rounded_rect(cr, width, height, 5)
--     end,
--     border_color = "#aaaaaa",
--     border_width = 2,
--     ontop = true,
--     visible = false,
-- }

-- Create a popup widget
volume.volumesliderpopup = awful.popup {
    widget = {
        {
            volume.volumeslider,
            layout = wibox.layout.fixed.horizontal
        },
        top = 10, -- add a 10-pixel margin at the top
        bottom = 10, -- add a 10-pixel margin at the bottom
        -- margins = 10,
        widget = wibox.container.margin
    },
    -- placement = awful.placement.top_right,
    placement = function(c)
        awful.placement.top_right(c, {margins = {top = 50, right = 50}})
    end,
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 5)
    end,
    border_color = "#aaaaaa",
    border_width = 2,
    ontop = true,
    visible = false,
}

-- Add a button binding to close the popup
volume.volumesliderpopup:buttons(
    gears.table.join(
        awful.button({}, 3, function()
            volume.volumesliderpopup.visible = false
        end)
    )
)


-- create an imagebox widget
volume.volumeiconwidget = wibox.widget {
    {
        image = gears.filesystem.get_configuration_dir() .. "images/volume-icon.jpg",
        resize = true,
        widget = wibox.widget.imagebox
    },
    layout = wibox.container.margin(_, _, _, 4)
}

-- Connect a click event to show the popup
volume.volumeiconwidget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then -- left click
        volume.volumesliderpopup.visible = not volume.volumesliderpopup.visible
    end
end)


-- return volumewidget, volumeslider, volumesliderpopup, update_volume_widget, volumeiconwidget

return volume


