-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

------------------------------------------------
------------------ LIBRARIES -------------------
------------------------------------------------

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
            require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local lain = require("lain")
local logout_menu_widget = require("awesome-wm-widgets.logout-menu-widget.logout-menu")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
--beautiful.font = "Ubuntu 8"


------------------------------------------------
-------------------- ERROR ---------------------
------------------------------------------------

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
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}


------------------------------------------------
------------------- OPTIONS --------------------
------------------------------------------------

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "mytheme/theme.lua")
--beautiful.font = "Ubuntu 8"

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. "vim"
browser = "firefox"
fm = "pcmanfm"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.spiral,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    --awful.layout.suit.floating
}
-- }}}

------------------------------------------------
-------------------- MENU ----------------------
------------------------------------------------

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

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}


------------------------------------------------
------------------- WIDGETS --------------------
------------------------------------------------

-- Separator Blanc
tbox_separator2 = wibox.widget.textbox("  ")
tbox_separator1 = wibox.widget.textbox(" ")

-- Separator
bar_separator = wibox.widget.textbox("  ||  ")

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
mytextclock = wibox.widget.textclock()
local clock = wibox.widget.background()
clock:set_widget(mytextclock)
clock:set_bg("#1a1a1a")
clock:set_shape(gears.shape.rectangle)
-- Create a textclock widget (default one)
--mytextclock = wibox.widget.textclock()

-- Volume
local volume_widget = require('awesome-wm-widgets.volume-widget.volume')

--Brightness
local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")

--Battery
local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")

-- Cpu
local cpu = lain.widget.cpu {
	settings = function()
		widget:set_markup(" CPU " .. cpu_now.usage.. "% ")
	end
}

-- Ram
local ram_mem = lain.widget.mem {
	settings = function()
		widget:set_markup(" RAM " .. mem_now.perc.. "% ")
	end
}

-- Updates
local update = awful.widget.watch('/home/zg/.config/awesome/updates-wibox')
local updatew = wibox.widget.background()
updatew:set_widget(update)
updatew:set_bg("#1a1a1a")
updatew:set_shape(gears.shape.rectangular_tag)


------------------------------------------------
-------------------- WIBAR ---------------------
------------------------------------------------

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
                                                  c.minimized = false
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = false}
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
    awful.tag({"P", "ᗣ", "ᗧ", "•••", "M", "ᗣ", "N" }, s, awful.layout.layouts[1])

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
        --buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
       -- filter  = awful.widget.tasklist.filter.currenttags,
       --filter = awful.widget.tasklist.filter.focused
       -- buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, visible  = true})

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            tbox_separator2,
	    --mylauncher,
	    s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
	    wibox.widget.systray(),
	    bar_separator,
	    volume_widget{widget_type = 'icon_and_text'},
	    bar_separator,
	    brightness_widget{type = 'icon_and_text', program = 'xbacklight', step = 2, },
	    bar_separator,
	    cpu.widget,
	    bar_separator,
	    ram_mem,
	    bar_separator,
	    batteryarc_widget({show_current_level = true, arc_thickness = 1, size = 16,}),
            bar_separator,
            mytextclock,
	    bar_separator,
	    logout_menu_widget(),
            tbox_separator2,
	    s.mylayoutbox,
	    tbox_separator1
        },
    }
end)
-- }}}

------------------------------------------------
----------------- MOUSE KEYBINDINGS ------------
------------------------------------------------

root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
   -- awful.button({ }, 4, awful.tag.viewnext),
   -- awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

------------------------------------------------
----------------- KEYBINDINGS ------------------
------------------------------------------------

--Awesome Global Keybidings
globalkeys = gears.table.join(

    -- Applications Keybidings
    awful.key({ modkey,           }, "b" , function () awful.spawn(browser) end,
        {description = "open a browser", group = "launcher"}),
    awful.key({ modkey,           }, "l" , function () awful.spawn(fm) end,
        {description = "open a file manager", group = "launcher"}),
    awful.key({ modkey         },   "x",      function () awful.spawn("rofi -show drun -display-drun ' Exec ' ") end,
        {description = "rofi-apps", group = "Personal launchers"}),
    --[[--awful.key({ modkey		},   "0",	function () awful.spawn("/home/zg/.config/awesome/rofi/power-menu.sh") end,
        {description = "Rofi power menu", group = "Personal launchers"}),  --need to install rofiPowerMenu ]]--
    --[[--awful.key({ "Shift"         },   "p",      function () awful.spawn("/home/zg/.config/awesome/rofi/srcscript-rofi") end,
        {description = "src-packages", group = "Personal launchers"}), --need to install it ]]--
    --[[--awful.key({ "Alt", "fn"         },   "x",      function () awful.spawn("/home/zg/.config/awesome/rofi/notify/volume+") end,
        {description = "exec volup", group = "Personal launchers"}), --need to install it ]]--
    --[[--awful.key({ "Alt" , "fn"        },   "z",      function () awful.spawn("/home/zg/.config/awesome/rofi/notify/volume-") end,
        {descritipn = "exec voldown", group = "Personal launchers"}), --need to install it ]]--
    --[[--awful.key({ "Shift", "Control"    },   "s",      function () awful.spawn("/home/zg/.config/awesome/rofi//screenshot") end,
        {description = "Screenshot", group = "Personal launchers"}), --need to install it ]]--
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
        {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
            {description="show help", group="awesome"}),

    --Volume Keybidings
	awful.key({ modkey }, "]", function() volume_widget:inc(5) end),
	awful.key({ modkey }, "[", function() volume_widget:dec(5) end),
	awful.key({ modkey }, "\\", function() volume_widget:toggle() end),

   --Brightness Keybidings
   --[[ awful.key({ modkey         }, "Up", function () brightness_widget:inc() end,
		{description = "increase brightness", group = "brightness"}),
	awful.key({ modkey }, "Down", function () brightness_widget:dec() end,
		{description = "decrease brightness", group = "brightness"}), ]]--

    --Menu Keybiding
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
    {description = "show menu", group = "awesome"}),

    --Swap Tags
    awful.key({ "Control",           }, "j",   awful.tag.viewprev,
    {description = "view previous", group = "tag"}),
    awful.key({ "Control",           }, "k",  awful.tag.viewnext,
    {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
    {description = "go back", group = "tag"}),
    awful.key({}, "F9", function() xrandr.xrandr() end),	



    -- Layout Manipulation
        --Monitor Swap
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
        {description = "focus the next screen", group = "screen"}),
    --Clients Place  Swap
    awful.key({ modkey }, "j", function () awful.client.swap.byidx(  1)    end,
        {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey }, "k", function () awful.client.swap.byidx( -1)    end,
        {description = "swap with previous client by index", group = "client"}),
    --Increase/Decrease Master Clients
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
        {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
        {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
    --Increase/Decrease Col
        {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
        {description = "decrease the number of columns", group = "layout"}),
    --Swap Layouts
        awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
        {description = "select next", group = "layout"}),

    --Swap Focus Client: mod4 + tab 
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    --Awesome Quit/Restart Keybidings 
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    
    --Min/Max Keybidings
    --[[awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = false}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),
    ]]--

    --Run Lua Code Keybiding
    --[[awful.key({ modkey }, "r",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    ]]--
              
    -- Menubar Keybiding
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)


--Layout Manipulation 
clientkeys = gears.table.join(
    
-- Close Clients
awful.key({ modkey }, "c",      function (c) c:kill()             end,
          {description = "close", group = "client"}),


-- ScreenMode & Rezise
awful.key({ modkey, "Shift"   }, "f", function (c) c.fullscreen = not c.fullscreen c:raise() end,
             {description = "toggle fullscreen", group = "client"}),
awful.key({ modkey, 	  }, "n",  awful.client.floating.toggle                     ,
          {description = "toggle floating", group = "client"}),
awful.key({ modkey, 	  }, ",", function (c) c:swap(awful.client.getmaster()) end,
          {description = "move to master", group = "client"}),
awful.key({ modkey,           }, "m", function (c) c.maximized = not c.maximized c:raise() end,
          {description = "(un)maximize", group = "client"}),
awful.key({ modkey, "Control"   }, "m",function (c) c.maximized_vertical = not c.maximized_vertical c:raise() end,
          {description = "(un)maximize vertically", group = "client"}),
awful.key({ modkey, "Control"   }, "n",function (c) c.maximized_horizontal = not c.maximized_horizontal c:raise() end,
          {description = "(un)maximize horizontally", group = "client"}),

awful.key({ modkey, "Control" }, "Up", function (c)
  if c.floating then
    c:relative_move( 0, 0, 0, -10)
  else
    awful.client.incwfact(0.025)
  end
end,
{description = "Floating Resize Vertical -", group = "client"}),
awful.key({ modkey, "Control" }, "Down", function (c)
  if c.floating then
    c:relative_move( 0, 0, 0,  10)
  else
    awful.client.incwfact(-0.025)
  end
end,
{description = "Floating Resize Vertical +", group = "client"}),
awful.key({ modkey, "Control" }, "Left", function (c)
  if c.floating then
    c:relative_move( 0, 0, -10, 0)
  else
    awful.tag.incmwfact(-0.025)
  end
end,
{description = "Floating Resize Horizontal -", group = "client"}),
awful.key({ modkey, "Control" }, "Right", function (c)
  if c.floating then
    c:relative_move( 0, 0,  10, 0)
  else
    awful.tag.incmwfact(0.025)
  end
end,
{description = "Floating Resize Horizontal +", group = "client"})

)

-- Bind all key numbers to tags.
-- mod4 + num = change tag  /  mod4 + shift + num = move client to the choosen tag --
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

--Mouse Rezise/Move Clients Settings
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


------------------------------------------------
-------------------- RULES ---------------------
------------------------------------------------

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { --border_width = beautiful.border_width,
                     border_width = 1,
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

 --[[-- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
    }, properties = { titlebars_enabled = true }
    }, ]]--

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-------------------------------------------------
-------------------- SIGNALS --------------------
-------------------------------------------------

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

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus  end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal  end)

-------------------------------------------------
--------------------- GAPS ----------------------
-------------------------------------------------
beautiful.useless_gap = 4
 

------------------------------------------------
-------------------- START ---------------------
------------------------------------------------
awful.spawn.with_shell("nitrogen --restore")
--awful.spawn.with_shell('polkit-xfce-authentication-agent-1') --autorization app to usb and external hdd
awful.spawn.with_shell("xset r rate 300 50") --to not let the screen sleep
awful.spawn.with_shell("xset s off")         --to not let the screen sleep
--awful.spawn.with_shell("xrandr --output eDR --primary --mode 1366x768 --rate 60.00 --output HDMI-A-0 --mode 2560x1080 --rate75.00 --left-of eDP")
--awful.spawn.with_shell("!xrandr --restore")
--awful.spawn.with_shell("xset -dpms")
--awful.spawn.with_shell("picom --experimental-backends") 
