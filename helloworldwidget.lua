
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



-- progress

-- Create a progressbar widget
local myprogressbar = wibox.widget {
    max_value = 100,
    value = 50,
    forced_width = 100,
    forced_height = 20,
    widget = wibox.widget.progressbar,
}

-- Create a slider widget
local myslider = wibox.widget {

    forced_width = 50,
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
myslider:connect_signal("property::value", function()
    myprogressbar.value = myslider.value
end)

-- Connect a click event to show the slider
myprogressbar:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then -- left click
        -- mypopup.visible = not mypopup.visible

        -- awful.prompt.run {
        --     prompt = "Set value: ",
        --     textbox = myslider,
        --     exe_callback = function(value)
        --         myslider.value = tonumber(value) or myslider.value
        --         myprogressbar.value = myslider.value
        --     end,
        -- }
    end
end)

-- pop up


-- Create a text box widget
local mytextbox = wibox.widget {
    text = "Hello, world! ",
    widget = wibox.widget.textbox,
}


-- Create a popup widget
local mypopup = awful.popup {
    -- widget = mytextbox,
    -- widget= wibox.widget {
    --     forced_width = 20,
    --     forced_height = 20,
    --     bar_border_color    = beautiful.border_color,
    --     bar_border_width    = 1,
    --     bar_margins         = {},
    --     handle_color        = "#00ff00",
    --     handle_border_color = beautiful.border_color,
    --     handle_border_width = 1,
    --     widget              = wibox.widget.slider,
    -- },
    widget = myslider,
    placement = awful.placement.centered,
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 5)
    end,
    border_color = "#aaaaaa",
    border_width = 2,
    ontop = true,
    visible = false,
}

-- Connect a click event to show the popup
mytextbox:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then -- left click
        mypopup.visible = not mypopup.visible
        local area = awful.screen.focused().workarea
        local text = mytextbox.text
        text = text .. table.concat(area,",")
        mytextbox:set_text(text)


    end
end)


return myprogressbar, mytextbox, myslider, mypopup
