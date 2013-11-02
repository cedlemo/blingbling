-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

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
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
local home_dir   = os.getenv("HOME")
local themes_dir = home_dir .. "/.config/awesome/themes"
local theme_dir = themes_dir .. "/japanese2"
beautiful.init(theme_dir .. "/theme.lua")

-- This is used later as the default terminal and editor to run.
--terminal = "tortosa -c \"" .. home_dir .. "/.config/tortosa/tortosa_awesome.rc\""
terminal = "tortosa"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " 

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "  一⇋ Main   ", "  二⇋ Devel.   ", "  三⇋  Admin.  ", "  四⇋  www/Web  ", "  五⇋ Misc  ", "  六  " }, s, layouts[1])
    --tags[s] = awful.tag({ " [[ ⇋  Main ]]", " [[ ⇋ 四 Devel. ]]", " [[ ⇋  Admin. ]]", " [[ ⇋  www/Web ]]", " [[ ⇋ Misc ]] "}, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e \"man awesome\"" },
   { "edit config", terminal .. " -e \"vim " .. awesome.conffile .."\"" },
   { "edit theme", terminal .. " -e \"vim ".. theme_dir .. "/theme.lua" .."\"" },
	 { "restart", awesome.restart },
   { "quit", awesome.quit }
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

-- {{{ Wibox
-- Create a textclock widget

--local function japanese_date()
--	local hour = os.date("<span color=\"#999999\">%H<span color=\"#000000\">時</span>%M<span color=\"#000000\">分</span> </span>")
--	week_day = {"}
local blingbling = require("blingbling")
--mytextclock = awful.widget.textclock(" %a %b %d, <span color=\"#999999\">%H<span color=\""..blingbling.helpers.rgb(20,31,82).."\">時</span>%M<span color=\""..blingbling.helpers.rgb(20,31,82).."\">分</span> </span>")
mytextclock = blingbling.clock.japanese(" %m、%d、%w、<span color=\"#999999\">%H<span color=\""..blingbling.helpers.rgb(20,31,82).."\">時</span>%M<span color=\""..blingbling.helpers.rgb(20,31,82).."\">分</span> </span>")
calendar = blingbling.calendar()
calendar:set_link_to_external_calendar(true)
-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
  local vicious = require("vicious")
  -- Top widgets:
				  
  --cpu_label_text='<span size="small" color="'..beautiful.textbox_widget_as_label_font_color..'" >CPU:</span>'
  --cpu_label= wibox.widget.textbox(cpu_label_text, false)

  cpu_graph = blingbling.line_graph({ height = 18,
                                      width = 160,
                                      show_text = true,
                                      label = "Cpu: $percent %",
                                      rounded_size = 0.3,
																			background_color = blingbling.helpers.rgba(47,28,28,0.0),
                                      graph_background_color = blingbling.helpers.rgba(47,28,28,0.0),
                                      font = "Droid Sans Mono"
                                     })
  --cpu_graph:set_graph_background_color("#00000033")
  --cpu_graph:set_font("Droid Sans Mono")
  --cpu_graph:set_font({family = "Droid Sans Mono", slang = "italic", weight = "bold"})
  vicious.register(cpu_graph, vicious.widgets.cpu,'$1',2)

  mem_graph = blingbling.line_graph({ height = 18,
                                      width = 160,
                                      show_text = true,
                                      label = "Mem: $percent %",
                                      rounded_size = 0.3,
                                      graph_background_color = "#30303000",--blingbling.helpers.rgba(9,15,43,0.0),
                                      text_background_color = "#000000",
																			font = "Droid Sans Mono"
                                     })

	vicious.register(mem_graph, vicious.widgets.mem, '$1', 2)
	
	volume_bar = blingbling.volume({height = 18, width = 30, bar =true, show_text = false, label ="Vol", graph_background_color = "#77777700" ,graph_color=blingbling.helpers.rgba(47,28,28,0.7)})
	volume_bar:update_master()
	--volume_bar:set_master_control()

	home_fs_usage=blingbling.value_text_box({height = 14, width = 40, v_margin = 4})
	--home_fs_usage:set_height(16)
	--home_fs_usage:set_width(40)
	--home_fs_usage:set_v_margin(2)
	home_fs_usage:set_text_background_color("#222222")
	home_fs_usage:set_values_text_color({{blingbling.helpers.rgb(59,162,117),0}, --all value > 0 will be displaying using this color
	                          {blingbling.helpers.rgb(96,149,197), 0.5},
														{blingbling.helpers.rgb(181,136,88),0.77}})
	home_fs_usage:set_text_color("#999999")
	--There is no maximum number of color that users can set, just put the lower values at first. 
	home_fs_usage:set_text_color(beautiful.textbox_widget_as_label_font_color)
	home_fs_usage:set_rounded_size(0.4)
	home_fs_usage:set_font_size(8)
	home_fs_usage:set_background_color("#00000000")
	home_fs_usage:set_label("home: $percent %")

	vicious.register(home_fs_usage, vicious.widgets.fs, "${/home used_p}", 120 )
	
	root_fs_usage=blingbling.value_text_box({height = 14, width = 40, v_margin = 4})
	--root_fs_usage:set_height(16)
	--root_fs_usage:set_width(40)
	--root_fs_usage:set_v_margin(2)
	root_fs_usage:set_text_background_color("#222222")
	root_fs_usage:set_values_text_color({{blingbling.helpers.rgb(59,162,117),0}, --all value > 0 will be displaying using this color
	                          {blingbling.helpers.rgb(96,149,197), 0.5},
														{blingbling.helpers.rgb(181,136,88),0.77}})
	--There is no maximum number of color that users can set, just put the lower values at first. 
	root_fs_usage:set_text_color(beautiful.textbox_widget_as_label_font_color)
	root_fs_usage:set_rounded_size(0.4)
	root_fs_usage:set_font_size(8)
	root_fs_usage:set_background_color("#00000000")
	root_fs_usage:set_label("root: $percent %")

	vicious.register(root_fs_usage, vicious.widgets.fs, "${/ used_p}", 120 )
	
	data0_fs_usage=blingbling.value_text_box({height = 14, width = 40, v_margin = 4})
	--data0_fs_usage:set_height(16)
	--data0_fs_usage:set_width(40)
	--data0_fs_usage:set_v_margin(2)
	data0_fs_usage:set_text_background_color("#222222")
	data0_fs_usage:set_values_text_color({{blingbling.helpers.rgb(59,162,117),0}, --all value > 0 will be displaying using this color
	                          {blingbling.helpers.rgb(96,149,197), 0.5},
														{blingbling.helpers.rgb(181,136,88),0.77}})	--There is no maximum number of color that users can set, just put the lower values at first. 
	data0_fs_usage:set_text_color(beautiful.textbox_widget_as_label_font_color)
	data0_fs_usage:set_rounded_size(0.4)
	data0_fs_usage:set_font_size(8)
	data0_fs_usage:set_background_color("#00000000")
	data0_fs_usage:set_label("data0: $percent %")

	vicious.register(data0_fs_usage, vicious.widgets.fs, "${/mnt/data_0 used_p}", 120 )
	
	data1_fs_usage=blingbling.value_text_box({height = 14, width = 40, v_margin = 4})
	--data1_fs_usage:set_height(16)
	--data1_fs_usage:set_width(40)
	--data1_fs_usage:set_v_margin(2)
	data1_fs_usage:set_text_background_color("#222222")
	data1_fs_usage:set_values_text_color({{blingbling.helpers.rgb(59,162,117),0}, --all value > 0 will be displaying using this color
	                          {blingbling.helpers.rgb(96,149,197), 0.5},
														{blingbling.helpers.rgb(181,136,88),0.77}})	--	--There is no maximum number of color that users can set, just put the lower values at first. 
	data1_fs_usage:set_text_color(beautiful.textbox_widget_as_label_font_color)
	data1_fs_usage:set_rounded_size(0.4)
	data1_fs_usage:set_font_size(8)
	data1_fs_usage:set_background_color("#00000000")
	data1_fs_usage:set_label("data1: $percent %")

	vicious.register(data1_fs_usage, vicious.widgets.fs, "${/mnt/data_1 used_p}", 120 )
	shutdown=blingbling.system.shutdownmenu() --icons have been set in theme
	reboot=blingbling.system.rebootmenu() --icons have been set in theme
	lock=blingbling.system.lockmenu() --icons have been set in theme
	logout=blingbling.system.logoutmenu()
	mytag={}
	--test = blingbling.text_box()
for s = 1, screen.count() do
	mytag[s]=blingbling.tagslist(s,  awful.widget.taglist.filter.all, mytaglist.buttons--, {--height = 16, width = 30,
																																												--[[background_border="#00000033",--]] --background_color = "#00000055", 
																																												--rounded_size = {0, 0.4,0,0.4},--[[rounded_size=0.4,--]] 
																																												--h_margin =1, v_margin = 1}
																																												)
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    --mytag[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ height = 18, position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(wibox.layout.margin(mytag[s],0,0,2,2))
		--left_layout:add(wibox.layout.margin(mytaglist[s],0,0,1,1))
    left_layout:add(mypromptbox[s])
		left_layout:add(cpu_graph)
		left_layout:add(mem_graph)
    left_layout:add(home_fs_usage)
    left_layout:add(root_fs_usage)
    left_layout:add(data0_fs_usage)
    left_layout:add(data1_fs_usage)
		--left_layout:add(mytags)
		-- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
		right_layout:add(volume_bar)
		right_layout:add(mytextclock)
		right_layout:add(calendar)
    right_layout:add(mylayoutbox[s])
		right_layout:add(reboot)
		right_layout:add(shutdown)
		right_layout:add(logout)
		right_layout:add(lock)
    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(wibox.layout.margin(mytasklist[s],0,0,2,2))
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
     { rule_any = { class = {"Navigator","Firefox", "Chromium" },
       properties = { tag = tags[1][2] } }},
     { rule = { class = "Thunderbird" },
       properties = { tag = tags[1][3] } },
     { rule = { class = "Tuxguitar" },
       properties = { tag = tags[1][6] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        --right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        --right_layout:add(awful.titlebar.widget.stickybutton(c))
        --right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c, {size =12} ):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{
function run_once(cmd)
  local findme = cmd
  local firstspace = cmd:find(" ")
  if firstspace then
		findme = cmd:sub(0, firstspace-1)
	end
	awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end
--run_once("qjackctl")
run_once("volti")
-- }}}
