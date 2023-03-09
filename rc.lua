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

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
-- terminal = "xterm"
terminal = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })






-- My custom widgets begin


-- My first custom widget
-- praise_widget = wibox.widget.textbox()
-- praise_widget.text = "You are great!"

-- My second custom widget

function get_command_output(command)
    -- local command = "your_bash_command_here"
    local command_output = io.popen(command .. " 2>&1"):read("*all")
    -- local command_output = io.popen(command):read("*all")
    local command_exitcode = os.execute(command .. " >/dev/null 2>&1")
    -- local command_exitcode = 0
    return command_output, command_exitcode
end


function remove_whitespace(input_string)

    -- Use string.gsub to remove leading and trailing white space
    local output_string = string.gsub(input_string, "%s*(.-)%s*", "%1")

    -- Print the result
    return output_string

end


-- Require the Defaults class
-- local Defaults = require("defaults")

-- Create a new instance of the Defaults class
-- local defaults = Defaults:new()

-- Read data from the defaults file
-- local data = defaults:read_data()

-- battery widget
batterywidget = wibox.widget.textbox()
local update_battery_widget = function ()
    local command = "acpi -b"
    local command_output, command_exitcode = get_command_output(command)
    if string.match( command_output, "No support for device type: power_supply") then
        -- batterywidget:set_text(" No Battery ")
        batterywidget:set_text(" ")
    else
        batterywidget:set_text( command_output )
    end
end


-- volume widget
volumewidget = wibox.widget.textbox()

local update_volume_widget = function ()
    local command = 'amixer get Master | grep -oE "[0-9]+%"'
    local command_output, command_exitcode = get_command_output(command)
    if 1==1 then
        volumewidget:set_text(" Volume : "..command_output)
    else
        volumewidget:set_text( command_output )
    end
end



-- brightness widget
brightnesswidget = wibox.widget.textbox()

local getDisplay = function()

    local command = 'xrandr | grep " connected" | awk \'{ print$1 }\''
    local display = get_command_output(command)
    display = remove_whitespace(display)
    return display

end

local update_brightness_widget = function ()
    local command = 'xrandr --verbose | grep Brightness'
    local command_output, command_exitcode = get_command_output(command)
    command_output = remove_whitespace(command_output)
    if 1==1 then
        -- brightnesswidget:set_text(" Brightness : "..command_output)
        brightnesswidget:set_text(" "..command_output.." ")
    else
        brightnesswidget:set_text(" "..command_output.." ")
    end
end


update_battery_widget()
update_volume_widget()
update_brightness_widget()
display = getDisplay()


-- timer
mytimer = timer({ timeout = 5 })
mytimer:connect_signal("timeout", function()
    update_battery_widget()
    update_volume_widget()
    display = getDisplay()
    update_brightness_widget()
    end)
mytimer:start()




-- Volume

-- Create a slider widget
local volumeslider = wibox.widget {

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
 volumeslider:connect_signal("property::value", function()
     -- myprogressbar.value = volumeslider.value
    local value = volumeslider.value
    local command = "amixer set Master "..value.."% "
    -- amixer set Master 66%
    local exit_status = os.execute(command .. " >/dev/null 2>&1")
    update_volume_widget()


 end)


-- Create a popup widget
local volumesliderpopup = awful.popup {
    widget = volumeslider,
    -- placement = awful.placement.centered,
    placement = awful.placement.centered,
    -- placement = awful.placement.next_to(volumewidget),
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 5)
    end,
    border_color = "#aaaaaa",
    border_width = 2,
    ontop = true,
    visible = false,
}


-- Connect a click event to show the popup
volumewidget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then -- left click
        volumesliderpopup.visible = not volumesliderpopup.visible
    end
end)


-- pop up end



-- for Brightness
-- Create a slider widget
local brightnessslider = wibox.widget {

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
 brightnessslider:connect_signal("property::value", function()
     -- myprogressbar.value = brightnessslider.value

    local display = getDisplay()
    local value = brightnessslider.value

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
    update_brightness_widget()


 end)


-- Create a popup widget
local brightnesssliderpopup = awful.popup {
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
    widget = brightnessslider,
    -- placement = awful.placement.centered,
    placement = awful.placement.centered,
    -- placement = awful.placement.next_to(brightnesswidget),
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 5)
    end,
    border_color = "#aaaaaa",
    border_width = 2,
    ontop = true,
    visible = false,
}


-- Connect a click event to show the popup
brightnesswidget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then -- left click
        brightnesssliderpopup.visible = not brightnesssliderpopup.visible
    end
end)


-- pop up end






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

-- Add the progressbar widget to your wibox or layout



-- pop up


-- Create a text box widget
local mytextbox = wibox.widget {
    text = "Hello, world!",
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


-- pop up end

-- my custom  widgets end

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget

        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            myprogressbar,
            mytextbox,
            batterywidget,
            volumewidget,
            brightnesswidget,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },

    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),


    -- Custom Keybindings

    awful.key({ }, "Print", function ()
        awful.util.spawn("scrot -e 'mv $f ~/screenshots/ 2>/dev/null'", false)
    end),

    awful.key({ modkey,           }, "Up",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "Down",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),


    -- Alacritty
    awful.key({ modkey }, "a", function ()
        awful.util.spawn("alacritty")
    end,{description = "alacritty", group = "applications"}),

    -- Brave
    awful.key({ modkey }, "b", function ()
        awful.util.spawn("brave")
    end,{description = "brave", group = "applications"}),

    -- Firefox
    awful.key({ modkey }, "c", function ()
        awful.util.spawn("firefox")
    end,{description = "firefox", group = "applications"}),


    -- Vivaldi
    awful.key({ modkey }, "d", function ()
        awful.util.spawn("vivaldi-stable")
    end,{description = "vivaldi-stable", group = "applications"}),


    -- Pcmanfm (file manager)
    awful.key({ modkey }, "e", function ()
        awful.util.spawn("pcmanfm")
    end,{description = "pcmanfm", group = "applications"})



)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maxbmize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },

    -- Custom rules

    -- Set Firefox to always map on the tag named "2" on screen 1.
    { rule = { class = "Brave" },
      properties = { screen = 1, tag = "2" } },


    -- Set Vivaldi to always map on the tag named "2" on screen 1.
    { rule = { class = "Vivaldi" },
      properties = { screen = 1, tag = "3" } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}



-- My customization
require("my_customization")
