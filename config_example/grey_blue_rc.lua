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
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/home/cedlemo/Projets/Lua/blingbling/config_example/grey_blue/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

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
    tags[s] = awful.tag({ "Web", "Dev", 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
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
local vicious = require('vicious')
vicious.cache(vicious.widgets.cpu)
vicious.cache(vicious.widgets.fs)
local blingbling = require('blingbling')
-- Create a textclock widget
mytextclock = awful.widget.textclock()
mytextclock:set_font("Cantarell Bold 10")
mytextclock:set_align("center")
local calendar = blingbling.calendar(mytextclock)
--calendar:set_link_to_external_calendar(true)
--local system_functions, err = loadfile('./system_functions.lua')
--if system_functions then
--  system_functions()
--end
local function gen_left_panel()
  --build left panel:
  local left_const = wibox.layout.constraint()
  left_const:set_strategy("exact")
  left_const:set_width(400)
  local left_panel = wibox.layout.fixed.vertical()
  left_const:set_widget(left_panel)
  local os_infos = blingbling.helpers.get_os_release_informations()
  
  for _,v in ipairs(os_infos) do
    local tbox = wibox.widget.textbox()    
    tbox:set_markup("<span color=\"white\">"..v.key..": </span><span color=\""..beautiful.bg_focus.."\">"..v.value.."</span>" )
    left_panel:add(tbox)
  end
  local cpu_info = wibox.widget.textbox()
  cpu_info:set_markup("<span color=\"white\">Cpu: </span><span color=\""..beautiful.bg_focus.."\">"..blingbling.helpers.get_cpu_name().."</span>" )  
  left_panel:add(cpu_info)
  local mem_info = wibox.widget.textbox()
  mem_info:set_markup("<span color=\"white\">Ram: </span><span color=\""..beautiful.bg_focus.."\">"..math.ceil(blingbling.helpers.get_total_mem_in_kb()/(1024*1024)).." G</span>" )  
  left_panel:add(mem_info)
  local input_devices = blingbling.helpers.get_input_devices()
  for k,v in pairs(input_devices) do
    local tbox = wibox.widget.textbox()    
    tbox:set_markup("<span color=\"white\">".. k ..": </span><span color=\""..beautiful.bg_focus.."\">"..v.."</span>" )
    left_panel:add(tbox)
  end
  return left_const
end

local function gen_right_panel()
  nb_cores = blingbling.helpers.get_nb_cores()
  local right_panel = wibox.layout.fixed.vertical()
  local cpu_label = wibox.widget.textbox()
  cpu_label:set_text("Cpu Cores Usage :")
  cpu_label:set_align("center")
  right_panel:add(cpu_label)
  local graphs_layout = wibox.layout.fixed.horizontal()
  local cpu_graphs = {}
 
   for i =1, nb_cores do
    cpu_graphs[i]= blingbling.line_graph({ height = 40,
                                    width = math.ceil(600/nb_cores),
                                    show_text = true,
                                    label = "Load: $percent %",
                                    rounded_size = 0.3,
                                    graph_background_color = "#00000033"
                                    })
    graphs_layout:add(cpu_graphs[i])
    vicious.register(cpu_graphs[i], vicious.widgets.cpu,'$' .. i+1,2)
  end
  right_panel:add(graphs_layout)
  local memory_label = wibox.widget.textbox()
  memory_label:set_text("Memory Usage :")
  memory_label:set_align("center")
  right_panel:add(memory_label)
  local memory_graph = blingbling.line_graph({ height = 40,
                                    width = 600,
                                    show_text = true,
                                    label = "Load: $percent %",
                                    rounded_size = 0.3,
                                    graph_background_color = "#00000033"
                                    })
  vicious.register(memory_graph, vicious.widgets.mem,'$1',2)
  right_panel:add(memory_graph)

--Files systems:
  local fs_label = wibox.widget.textbox()
  fs_label:set_text("Mounted File Systems Usage: ")
  fs_label:set_align("center")
  right_panel:add(fs_label)
  local devices = blingbling.helpers.get_mounted_devices()
  local devices_graphs = {}
  local n=0
  for i,v in ipairs(devices) do
    devices_graphs[i] = blingbling.progress_graph({ height = 20,
                                          width = 600,
                                          show_text = true,
                                          label = devices[i].dev .." -> " .. devices[i].mnt .." Usage: $percent %",
                                          horizontal = true,
                                          rounded_size = 0.3,
                                          graph_background_color = "#00000033"
                                          })
    
    vicious.register(devices_graphs[i], vicious.widgets.fs, "${" .. devices[i].mnt .." used_p}",120)
    right_panel:add(devices_graphs[i])
  end
  return right_panel
end
local function gen_sys_monitor()
  
  local width = 1000
  local height = 500

  --build right panel
  local monitor = {}
  monitor.wibox =  wibox({position="top", width=1000, height=350})
  monitor.wibox:geometry({ x=50, y=50})
  local layout = wibox.layout.fixed.vertical()
  local sublayout = wibox.layout.fixed.horizontal()
  local title =  wibox.widget.textbox()
  title:set_text("System Informations: ")
  title:set_align("center")
  title:set_font("Cantarell 12")
  local left_panel = gen_left_panel()
  local right_panel = gen_right_panel()
  sublayout:add(left_panel)
  sublayout:add(right_panel)
  layout:add(title)
  layout:add(sublayout)
  monitor.wibox:set_widget(layout)
  monitor.wibox.visible = true
  monitor.wibox.visible = false
  return monitor
end
local function toggle_visibility(wibox)
  wibox.visible = not wibox.visible 
end
toto = gen_sys_monitor()

local function taglist_wibox()
  local current_screen = mouse.screen
  local screen_geometry = screen[current_screen].workarea
  local mytaglist = {}
  local box={}
  mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
  for s = 1, screen.count() do
    mytaglist[s]=blingbling.tagslist(s,  awful.widget.taglist.filter.all, mytaglist.buttons --[[, { normal = {}, focus ={}, urgent={}, occupied={} }--]])
--    local w,h = mytaglist[s]:fit(screen_geometry.width,screen_geometry.height)
--    box[s] = wibox({height=h , width=w, ontop=true})
    local margin = wibox.layout.margin(mytaglist[s], 4, 4, 4, 4)
    local w,h = margin:fit(screen_geometry.width,screen_geometry.height)
    box[s] = wibox({height=h , width=w, ontop=true})
    local x,y=0
    x = ((screen_geometry.width /2) + screen_geometry.x) - w/2
    y = ((screen_geometry.height /2) + screen_geometry.y) - h/2
    box[s]:geometry({x=x, y=y})
    box[s]:set_widget(margin)
    box[s].visible = false
  end
  return box
end
local box = taglist_wibox()

function taglist_wibox_show_hide(box)
--  mytimer = timer({ timeout = 0 })
--  mytimer:connect_signal("timeout", function () print("show");box.visible=true;mytimer:stop() end)
--  mytimer:start()
  box.visible = true
  mytimer1 = timer({ timeout = 2 })
  mytimer1:connect_signal("timeout", function () 
                                      if box.visible == true then
                                      print("hide")
                                      box.visible=false
                                      mytimer1:stop()
                                      end 
                                    end)
  mytimer1:start()
end
-- Create a wibox for each screen and add it
local tag_indicator= blingbling.text_box({ text = awful.tag.selected(mouse.screen).name, 
                                      width=40, rounded_size=0.3,
                                      background_color="#33333333", 
                                      text_background_color="#00000000", 
                                      text_color=beautiful.bg_focus,
                                      h_margin=4,-- v_margin=2,
                                      font="Cantarell", font_size=11 })
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
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
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
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
for s = 1, screen.count() do
    screen[s]:connect_signal("tag::history::update", function()
      tag_indicator:set_text( awful.tag.selected(s).name )
    --awful.key({ modkey, "Control" },"y",function() taglist_wibox_show_hide(box[mouse.screen]) end),
      taglist_wibox_show_hide(box[s])
    end)
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

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons,nil,blingbling.helpers.icons_only_tasklist)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
      left_layout:add(wibox.layout.margin(tag_indicator, 3, 0, 3, 3))
    --left_layout:add(mylauncher)
--    left_layout:add(mytaglist[s])
--    left_layout:add(mytasklist[s])
    left_layout:add(mypromptbox[s])
--    left_layout:add(x)
    --left_layout:add(y)
    local middle_layout = wibox.layout.flex.horizontal()
    middle_layout:add(calendar)
    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mylayoutbox[s])
    right_layout:add(mytasklist[s])
    -- Now bring it all together (with the tasklist in the middle)
--    local layout = wibox.layout.align.horizontal()
--    layout:set_left(left_layout)
--    layout:set_middle(middle_layout)
--    layout:set_right(right_layout)
    local layout = wibox.layout.flex.horizontal()
    layout:add(left_layout)
    layout:add(middle_layout)
    layout:add(right_layout)

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

    awful.key({ modkey, "Control" },"s",function() toggle_visibility(toto.wibox) end),
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
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
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
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
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

    local titlebars_enabled = false
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
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
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

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
