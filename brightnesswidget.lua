
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


-- define brightneess object
local brightness = {}

-- for Brightness
-- brightness widget
brightness.brightnesswidget = wibox.widget.textbox()

brightness.getDisplay = function()

    local command = 'xrandr | grep " connected" | awk \'{ print$1 }\''
    local display = get_command_output(command)
    display = remove_whitespace(display)
    return display

end

brightness.update_brightness_widget = function ()
    local command = 'xrandr --verbose | grep Brightness'
    local command_output, command_exitcode = get_command_output(command)
    command_output = remove_whitespace(command_output)

    -- local str = "Brightness:1.0"
    local str = command_output
    local brightness_level = tonumber(string.match(str, "%d+%.?%d*"))
    brightness_level = brightness_level * 100
    brightness_level = math.floor(brightness_level)
    -- the `tonumber` function converts the string to a floating point number
    -- the `string.match` function looks for a pattern in the string and returns the matched text
    -- the pattern "%d+%.?%d*" matches one or more digits followed by an optional decimal point and zero or more digits

    if 1==1 then
        -- brightnesswidget:set_text(" Brightness : "..command_output)
        brightness.brightnesswidget:set_text("  "..brightness_level.."%")
    else
        brightness.brightnesswidget:set_text(" "..command_output.." ")
    end
end





-- Create a slider widget
brightness.brightnessslider = wibox.widget {

    forced_width = 200,
    forced_height = 20,
    bar_border_color    = beautiful.border_color,
    bar_border_width    = 1,
    bar_margins         = {},
    handle_color        = "#00ffff",
    handle_border_color = beautiful.border_color,
    handle_border_width = 1,
    widget              = wibox.widget.slider,
    maximum = 100,
    minimum = 0,
    value = 70,
}

-- Connect the slider widget to the progressbar widget
brightness.brightnessslider:connect_signal("property::value", function()
     -- myprogressbar.value = brightnessslider.value

    local display = brightness.getDisplay()
    local value = brightness.brightnessslider.value

    local minBrightness = 20
    if value <= minBrightness then
        value = minBrightness
    end

    value = value / 100

    -- for red shift
    local gamma = "1:0.9:0.9"
    -- xrandr --output DISPLAY --brightness 1.0
    local command = "xrandr --output "..display.." --brightness "..value.." --gamma "..gamma
    -- local command = "amixer set Master "..value.."% "
    -- amixer set Master 66%
    local exit_status = os.execute(command .. " >/dev/null 2>&1")
    brightness.update_brightness_widget()


 end)


-- Create a popup widget
-- local brightnesssliderpopup = awful.popup {
--     -- widget = mytextbox,
--     -- widget= wibox.widget {
--     --     forced_width = 20,
--     --     forced_height = 20,
--     --     bar_border_color    = beautiful.border_color,
--     --     bar_border_width    = 1,
--     --     bar_margins         = {},
--     --     handle_color        = "#00ff00",
--     --     handle_border_color = beautiful.border_color,
--     --     handle_border_width = 1,
--     --     widget              = wibox.widget.slider,
--     -- },
--     widget = brightnessslider,
--     -- placement = awful.placement.centered,
--     placement = awful.placement.centered,
--     -- placement = awful.placement.next_to(brightnesswidget),
--     shape = function(cr, width, height)
--         gears.shape.rounded_rect(cr, width, height, 5)
--     end,
--     border_color = "#aaaaaa",
--     border_width = 2,
--     ontop = true,
--     visible = false,
-- }

brightness.brightnesssliderpopup  = awful.popup {
    widget = {
        {
            brightness.brightnessslider,
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
brightness.brightnesssliderpopup:buttons(
    gears.table.join(
        awful.button({}, 3, function()
            brightness.brightnesssliderpopup.visible = false
        end)
    )
)



-- create an imagebox widget
brightness.brightnessiconwidget = wibox.widget {
    {
        image = gears.filesystem.get_configuration_dir() .. "images/brightness-icon.jpg",
        resize = true,
        widget = wibox.widget.imagebox
    },
    layout = wibox.container.margin(_, _, _, 4)
}




-- Connect a click event to show the popup
brightness.brightnessiconwidget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then -- left click
        brightness.brightnesssliderpopup.visible = not brightness.brightnesssliderpopup.visible
    end
end)


return brightness
