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




-- Create a wibox widget
local mywibox = awful.wibar({
    position = "top",
    height = 20,
    screen = screen.primary
})
-- Create a popup widget
local mypopup = awful.popup({
    widget = {
        {
            {
                widget = wibox.widget.slider,
                forced_width = 200,
                forced_height = 20,
                bar_shape = gears.shape.rounded_rect,
                bar_height = 10,
                handle_shape = gears.shape.circle,
                handle_width = 20,
                handle_color = "#FFFFFF",
                bar_color = "#FFFFFF22",
                value = 50
            },
            layout = wibox.layout.fixed.horizontal
        },
        -- margins = 10,
        widget = wibox.container.margin
    },
    placement = awful.placement.top_right,
    screen = screen.primary,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 5)
    end
})

-- Add a mouse hover event to show the popup
mywibox:connect_signal("mouse::enter", function()
    mypopup.visible = true
end)

-- Add a mouse leave event to hide the popup
mywibox:connect_signal("mouse::leave", function()
    mypopup.visible = false
end)

