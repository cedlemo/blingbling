-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("vicious")

function run_once(prg, args)
  if not prg then
    do return nil end
  end
  if not args then
    args=""
  end
  awful.util.spawn_with_shell('pgrep -f -u $USER -x ' .. prg .. ' || (' .. prg .. ' ' .. args ..')')
end
                
-- {{{ Variable definitions
--get $HOME from the environement system
home   = os.getenv("HOME")
--get XDG_CONFIG
config_dir = awful.util.getdir("config")
-- Themes define colours, icons, and wallpapers
beautiful.init( config_dir .. "/current_theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "terminal"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
browser="luakit"
-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

--Lancement d'applications
run_once("nm-applet")
run_once("xcompmgr",'xcompmgr -CcfF -I "20" -O "10" -D "1" -t "-5" -l "-5" -r "4.2" -o ".82" &')
run_once("mpd")
run_once("udisks-glue")
---- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile,
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

-- {{{ naughty theme
naughty.config.default_preset.font             = beautiful.notify_font 
naughty.config.default_preset.fg               = beautiful.notify_fg
naughty.config.default_preset.bg               = beautiful.notify_bg
naughty.config.presets.normal.border_color     = beautiful.notify_border
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "1⇋ Main", "2⇋ Admin.", "3⇋ www/Web", "4⇋ Mails/Com.", "5⇋ Multimedia"}, s, layouts[1])
end

-- {{{ Menu
--Menu for choose between all your theme
mythememenu = {}
function theme_load(theme)
  local cfg_path = awful.util.getdir("config")
  -- Create a symlink from the given theme to /home/user/.config/awesome/current_theme
  awful.util.spawn("ln -sfn " .. cfg_path .. "/themes/" .. theme .. " " .. cfg_path .. "/current_theme")
  awesome.restart()
end
function theme_menu()
-- List your theme files and feed the menu table
  local cmd = "ls -1 " .. awful.util.getdir("config") .. "/themes/"
  local f = io.popen(cmd)
  for l in f:lines() do
    local item = { l, function () theme_load(l) end }
    table.insert(mythememenu, item)
  end
  f:close()
end
-- Generate your table at startup or restart
theme_menu()
-- applications menu
   require('freedesktop.utils')
   freedesktop.utils.terminal = terminal  -- default: "xterm"
   freedesktop.utils.icon_theme = 'gnome' -- look inside /usr/share/icons/, default: nil (don't use icon theme)
   require('freedesktop.menu')
   menu_items = freedesktop.menu.new()
   myawesomemenu = {
       { "manual", terminal .. " -e man awesome", freedesktop.utils.lookup_icon({ icon = 'help' }) },
    	 { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
    	 { "themes", mythememenu },
       { "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
    	 { "quit", awesome.quit, freedesktop.utils.lookup_icon({ icon = 'gtk-quit' }) }
      }
   table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
   table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })

   mymainmenu = awful.menu.new({ items = menu_items, width = 150 })
   mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,	 menu = mymainmenu })
-- desktop icons
   require('freedesktop.desktop')
   for s = 1, screen.count() do
	freedesktop.desktop.add_applications_icons({screen = s, showlabels = true})
	freedesktop.desktop.add_dirs_and_files_icons({screen = s, showlabels = true})
   end
-- }}}

-- {{{ Wibox
--widget separator
separator = widget({ type = "textbox", name = "separator"})
separator.text = " "

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
my_top_wibox = {}
my_bottom_wibox ={}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
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

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

--- {{ Section des Widgets
--pango
    pango_small="size=\"small\""
    pango_x_small="size=\"x-small\""
    pango_xx_small="size=\"xx-small\""
    pango_bold="weight=\"bold\""
--test oocairo
require("blingbling")

--shutdown widget
    shutdown=blingbling.system.shutdownmenu(beautiful.shutdown, 
                                            beautiful.accept, 
                                            beautiful.cancel)
    shutdown.resize= false
    awful.widget.layout.margins[shutdown]={top=4}
--reboot widget
    reboot=blingbling.system.rebootmenu(beautiful.reboot, 
                                        beautiful.accept, 
                                        beautiful.cancel)
    reboot.resize = false
    awful.widget.layout.margins[reboot]={top=4}
    -- Date
    datewidget = widget({ type = "textbox" })
    vicious.register(datewidget, vicious.widgets.date, "<span color=\""..beautiful.text_font_color_1.."\" "..pango_small..">%b %d, %R</span>", 60)

 --Cpu widget 
  cpulabel= widget({ type = "textbox" })
  cpulabel.text='<span color="'..beautiful.textbox_widget_as_label_font_color..'" '..pango_small..' '..pango_bold..'>CPU: </span>'
  cpu=blingbling.classical_graph.new()
  cpu:set_font_size(8)
  cpu:set_height(16)
  cpu:set_width(150)
  cpu:set_show_text(true)
  cpu:set_label("Load: $percent %")
  cpu:set_graph_color("#00ccff00")
  --Use transparency on graph line color to reduce the width of line with low resolution screen
  cpu:set_graph_line_color("#ff330088")
  cpu:set_filled(true)
  cpu:set_h_margin(2)
  cpu:set_background_color("#00000044")
  cpu:set_filled_color("#00000099")
  cpu:set_rounded_size(0.6)
  vicious.register(cpu, vicious.widgets.cpu, '$1',2)
 
--Cores Widgets
  corelabel=widget({ type = "textbox" })
  corelabel.text="<span color=\""..beautiful.textbox_widget_as_label_font_color.."\" "..pango_small..">Cores:</span>"
  mycore1 = blingbling.value_text_box.new()
  mycore1:set_width(25)
  mycore1:set_height(16)
  mycore1:set_filled(true)
  mycore1:set_filled_color("#00000099")
  mycore1:set_rounded_size(0.6)
  mycore1:set_values_text_color({{"#88aa00ff",0},{"#d4aa00ff", 0.5},{"#d45500ff",0.75}})
  mycore1:set_font_size(8)
  mycore1:set_background_color("#00000044")
  mycore1:set_label("$percent%")
  vicious.register(mycore1, vicious.widgets.cpu, "$2")
  
  mycore2 = blingbling.value_text_box.new()
  mycore2:set_width(25)
  mycore2:set_height(16)
  mycore2:set_filled(true)
  mycore2:set_filled_color("#00000099")
  mycore2:set_rounded_size(0.6)
  mycore2:set_values_text_color({{"#88aa00ff",0},{"#d4aa00ff", 0.5},{"#d45500ff",0.75}})
  mycore2:set_font_size(8)
  mycore2:set_background_color("#00000044")
  mycore2:set_label("$percent%")
  vicious.register(mycore2, vicious.widgets.cpu, "$3")
-- Mem Widget
  memlabel= widget({ type = "textbox" })
  memlabel.text='<span color="'..beautiful.textbox_widget_as_label_font_color..'" '..pango_small..'>MEM: </span>'
  
  memwidget = blingbling.classical_graph.new()
  memwidget:set_font_size(8)
  memwidget:set_height(16)
  memwidget:set_h_margin(2)
  memwidget:set_width(150)
  memwidget:set_filled(true)
  memwidget:set_show_text(true)
  memwidget:set_filled_color("#00000099")
  memwidget:set_rounded_size(0.6)
  --We just want the line of the graph
  memwidget:set_graph_color("#00ccff00")
  --Use transparency on graph line color to reduce the width of line with low resolution screen
  memwidget:set_graph_line_color("#00ccff88")
  memwidget:set_background_color("#00000044")
  vicious.register(memwidget, vicious.widgets.mem, "$1", 5)

--task_warrior menu
 task_warrior=blingbling.task_warrior.new(beautiful.tasks)
 task_warrior:set_task_done_icon(beautiful.task_done)
 task_warrior:set_task_icon(beautiful.task)
 task_warrior:set_project_icon(beautiful.project)

--Mpd widgets
 mpdlabel= widget({ type = "textbox" })
 mpdlabel.text='<span color="'..beautiful.textbox_widget_as_label_font_color..'" '..pango_small..'>MPD: </span>'

  my_mpd=blingbling.mpd_visualizer.new()
  my_mpd:set_height(16)
  my_mpd:set_width(340)
  my_mpd:update()
  my_mpd:set_line(true)
  my_mpd:set_h_margin(2)
  my_mpd:set_mpc_commands()
  my_mpd:set_launch_mpd_client(terminal .. " -e ncmpcpp")
  my_mpd:set_show_text(true)
  my_mpd:set_font_size(8)
  my_mpd:set_graph_color("#d4aa00ff")
  my_mpd:set_label("$artist > $title")
   
  my_mpd_volume=blingbling.volume.new()
  my_mpd_volume:set_height(16)
  my_mpd_volume:set_width(20)
  my_mpd_volume:set_v_margin(3)
  my_mpd_volume:update_mpd()
  my_mpd_volume:set_bar(true)

--udisks-glue menu
  udisks_glue=blingbling.udisks_glue.new(beautiful.udisks_glue)
  udisks_glue:set_mount_icon(beautiful.accept)
  udisks_glue:set_umount_icon(beautiful.cancel)
  udisks_glue:set_detach_icon(beautiful.cancel)
  udisks_glue:set_Usb_icon(beautiful.usb)
  udisks_glue:set_Cdrom_icon(beautiful.cdrom)
  awful.widget.layout.margins[udisks_glue.widget]= { top = 4}
  udisks_glue.widget.resize= false
--Calendar widget
  my_cal =blingbling.calendar.new({type = "imagebox", image = beautiful.calendar})
  my_cal:set_cell_padding(2)
  my_cal:set_title_font_size(9)
  my_cal:set_font_size(8)
  my_cal:set_inter_margin(1)
  my_cal:set_columns_lines_titles_font_size(8)
  my_cal:set_columns_lines_titles_text_color("#d4aa00ff")

-- Net Widget
  netwidget = widget({ type = "textbox", name = "netwidget" })
  netwidget.text='<span '..pango_small..'><span color="'..beautiful.textbox_widget_as_label_font_color..'">NET:</span></span>'
  my_net=blingbling.net.new()
  my_net:set_height(18)
  my_net:set_width(88)
  my_net:set_v_margin(3)
  my_net:set_graph_line_color("#00ccff00")
  my_net:set_graph_color("#00ccffff")
  my_net:set_filled_color("#00000055")
-- FS Widget
  fshomelabel= widget({ type = "textbox", name = "fshomelabel" })
  fshomelabel.text='<span color="'..beautiful.textbox_widget_as_label_font_color..'" '..pango_small..'>/home: </span>'
  fshome = blingbling.value_text_box.new()
  fshome:set_width(25)
  fshome:set_height(16)
  fshome:set_filled(true)
  fshome:set_filled_color("#00000099")
  fshome:set_rounded_size(0.6)
  fshome:set_values_text_color({{"#88aa00ff",0},{"#d4aa00ff", 0.5},{"#d45500ff",0.75}})
  fshome:set_font_size(8)
  fshome:set_background_color("#00000044")
  fshome:set_label("$percent%")
  vicious.register(fshome, vicious.widgets.fs, "${/home used_p}", 120 )

  fsrootlabel= widget({ type = "textbox", name = "fsrootlabel" })
  fsrootlabel.text='<span color="'..beautiful.textbox_widget_as_label_font_color..'" '..pango_small..'>root: </span>'
  fsroot = blingbling.value_text_box.new()
  fsroot:set_width(25)
  fsroot:set_height(16)
  fsroot:set_filled(true)
  fsroot:set_filled_color("#00000099")
  fsroot:set_rounded_size(0.6)
  fsroot:set_values_text_color({{"#88aa00ff",0},{"#d4aa00ff", 0.5},{"#d45500ff",0.75}})
  fsroot:set_font_size(8)
  fsroot:set_background_color("#00000044")
  fsroot:set_label("$percent%")
  vicious.register(fsroot, vicious.widgets.fs, "${/ used_p}", 120 )

--Volume
  volume_label = widget({ type = "textbox"})
  volume_label.text='<span '..pango_small..'><span color="'..beautiful.textbox_widget_as_label_font_color..'">Vol.: </span></span>'
  my_volume=blingbling.volume.new()
  my_volume:set_height(16)
  my_volume:set_v_margin(3)
  my_volume:set_width(20)
  my_volume:update_master()
  my_volume:set_master_control()
  my_volume:set_bar(true)
  my_volume:set_background_graph_color("#00000099")
  my_volume:set_graph_color("#00ccffaa")
-- wiboxs
    my_top_wibox[s] = awful.wibox({ position = "top", screen = s, height=16 })
    
    -- Add widgets to the wibox - order matters
    my_top_wibox[s].widgets = {
              {
                separator,
	              cpulabel,
                cpu.widget,
                separator,
	              corelabel,
	              mycore1.widget,
	              mycore2.widget,
                separator,
	              memlabel,
                memwidget.widget,
	              separator,
	              udisks_glue.widget,
                separator,
                fshomelabel,
                fshome.widget,
	              separator,
                fsrootlabel,
                fsroot.widget,
                separator,
                mpdlabel,
                separator,
                my_mpd_volume,
                separator,
                my_mpd.widget,
                separator,
                layout = awful.widget.layout.horizontal.leftright
	            },
              separator,
              mylayoutbox[s],
	            separator,
	            datewidget, 
              separator,
              my_cal.widget,
              separator,
              task_warrior.widget,        separator,
	            s == 1 and mysystray or nil,
              separator,
              my_net.widget,
              netwidget,
              separator,
              my_volume.widget,
              volume_label,
              layout = awful.widget.layout.horizontal.rightleft
    }

    my_bottom_wibox[s] = awful.wibox({ position= "top",screen = s, height = 16 })
    awful.screen.padding(screen[s],{top = 24})
    my_bottom_wibox[s].x=0
    my_bottom_wibox[s].y=20
    my_bottom_wibox[s].widgets = {
        {
	          separator,
            mytaglist[s],
	          separator,
            mypromptbox[s],
	          separator,
            layout = awful.widget.layout.horizontal.leftright
        },
	      separator,
        shutdown,
        separator,
        reboot,
        separator,

        separator,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
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
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

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
    awful.key({ modkey, "a"       }, "c",     function () awful.util.spawn(browser)     end),
    awful.key({ modkey, "a"       }, "t",     function () awful.util.spawn("thunderbird") end),
    awful.key({ modkey, "a"       }, "i",     function () awful.util.spawn("inkscape")  end),
    awful.key({ modkey, "a"       }, "g",     function () awful.util.spawn("gimp")      end),
    awful.key({ modkey, "a"       }, "v",     function () awful.util.spawn("VirtualBox") end),
    awful.key({ modkey, "a"       }, "u",     function () awful.util.spawn("/home/silkmoth/bin/UrbanTerror/ioq3-urt") end),
    
    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
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

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
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
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "Firefox"},
      properties = { tag = tags[1][3], switchtotag = true } },
    { rule = { class = "Chromium"},
      properties = { tag = tags[1][3], switchtotag = true } },
    { rule = { name = "luakit"},
      properties = { tag = tags[1][3], switchtotag = true } },
    { rule = { class = "Eclipse" },
      properties = { tag = tags[1][2], switchtotag = true } },
    { rule = { class = "Bluefish" },
      properties = { tag = tags[1][2], switchtotag = true } },
    { rule = { class = "Geany" },
      properties = { tag = tags[1][2], switchtotag = true } },
    { rule = { class = "gimp" },
      properties = { tag = tags[1][8], switchtotag = true , floating = true} },
    { rule = { class = "Ncmpc++" , instance = "gnome-terminal"},
      properties = { tag = tags[1][5], switchtotag = true } },
    { rule = { class = "Inkscape" },
      properties = { tag = tags[1][7], switchtotag = true, maximized_vertical = true, maximized_horizontal = true } },
    { rule = { class = "VirtualBox" },
      properties = { tag = tags[1][6], switchtotag = true } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][4], switchtotag = false } },
    { rule = { class = "Apache Directory Studio" },
      properties = { tag = tags[1][2], switchtotag = true } },
}	
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
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
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
