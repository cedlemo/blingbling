Blingbling:
----------
Blingbling is a graphical widget library for Awesome Windows Manager. Based on oocairo (http://oocairo.naquadah.org/) it was first an attempt to rewrite the graph and progressbar widgets of Awesome WM. The goal of the Blingbling library is to provide more fancy, customisable and easy to setup graphical widgets, popups or signals for Awesome WM.

Originally, I have written Blingbling for myself but I share it under the GNU GPL-v2 (http://www.gnu.org/licenses/old-licenses/gpl-2.0.html). It meens that for this version, I know it works for me but that all. Testers and feedbacks are welcome!

*Value text box
*Classical graph
*Tiled graph
*Progress graph
*Progress bar
*Volume graph
*Mpd widget
*Net widget
*Top popup
*Netstat popup
*System shutdown/Reboot button
*Udisks-glue widget menu
*Menu widget
*Task warrior widget
*Table widget layout
*Calendar

Version: v1.0
--------
Blingbling v1.0 works for awesome 3.4.10 and 3.4.11. The next version (v2.0) will be adapted to the next release of awesome. 

Dependencies
------------
Blingbling require oocairo. The address of the website of the project is : http://oocairo.naquadah.org.

Check your package manager to see if you can install an already packaged version of oocairo for your system.

For example on archlinux:
yaourt -S lua-oocairo-git

If you don't find an already packaged version of oocairo, you can install it from the source:

git clone git://git.naquadah.org/oocairo.git
cd oocairo*
and see the readme file for installation instructions.

Installation
------------
($XDG_CONFIG_HOME usually ~/.config)

cd $XDG_CONFIG_HOME/awesome/
git clone git://github.com/cedlemo/blingbling.git 

Usage
-----------
The following is a basic usage. For a full documentation see the index.html generatate by luadoc.

in your rc.lua (at the top of the file or just before you use blingbling widgets or functions), add:
require("blingbling")

*Value text box:
This is a text box that get a value between 0 and 1 and display it as text (like classical textbox widget in awesome). The difference with this widget, is that user can display a colored background with rounded corner (or not) behind the text. Furthermore user can set different colors to display the value (not all the text) depending on the value. ( 30>value< 70 set text color as green, value > 70% set text color as red for example.

  -Usage:
    --add this before adding the widget in the wibox:
      my_fs_root=blingbling.value_text_box.new()
      my_fs_root:set_height(18)
      my_fs_root:set_width(100)
      my_fs_root:set_v_margin(2)
      my_fs_root:set_filled(true)
      my_fs_root:set_filled_color("#00000099")
      my_fs_root:set_values_text_color({{"#88aa00ff",0},{"#d4aa00ff", 0.5},{"#d45500ff",0.75}})
      my_fs_root:set_default_text_color(beautiful.textbox_widget_as_label_font_color)
      my_fs_root:set_rounded_size(0.4)
      my_fs_root:set_background_color("#00000044")
      my_fs_root:set_label("/root usage:$percent %")
    
    --add the widget in the wibox:

      my_top_wibox[s].widgets = {
            ......,
            my_fs_root.widget,
            .....,
    --reload awesome

  -You can use vicious to feed the graph:
  vicious.register(my_fs_root, vicious.widgets.fs, "${/ used_p}", 120)

*Classical graph: classical_graph.lua
This widget drawn a common graph as the initial graph widget of Awesome but with more possibilities to customize it. (background transparency, displaying text on it). The stack graph is not implemented yet. It takes value in the range (0,1).
  -Create a graph and display it:
    --add this before adding the widget in the wibox

      mycairograph=blingbling.classical_graph.new()
      mycairograph:set_height(18)
      mycairograph:set_width(300)
      mycairograph:add_value(0.5)
    
    --add the widget in the wibox:

      my_top_wibox[s].widgets = {
            ......,
            mycairograph.widget,
            .....,
    --reload awesome

  -You can use vicious to feed the graph:
      mycairograph=blingbling.classical_graph.new()
      mycairograph:set_height(18)
      mycairograph:set_width(300)
      vicious.register(mycairograph, vicious.widgets.cpu, '$1', 2)
  
*Tiled graph
This widget is a graph like the Awesome graph widget but the values are represented with tiles. It takes value in the range (0,1)
  -Create a graph and display it:
    --add this before adding the widget in the wibox

      mytiledgraph=blingbling.classical_graph.new()
      mytiledgraph:set_height(18)
      mytiledgraph:set_width(300)
      mytiledgraph:add_value(0.5)
    
    --add the widget in the wibox:

      my_top_wibox[s].widgets = {
            ......,
            mytiledgraph.widget,
            .....,
    --reload awesome

  -You can use vicious to feed the graph:
      mytiledgraph=blingbling.classical_graph.new()
      mytiledgraph:set_height(18)
      mytiledgraph:set_width(300)
      vicious.register(mytiledgraph, vicious.widgets.cpu, '$1', 2)
  
*Progress graph
This widget drawn a progress bar as the initial bar widget of Awesome but with more possibilities to customize it. (background transparency, displaying text on it). It takes value in the range (0,1).
  -Create a bar and display it:
    --add this before adding the widget in the wibox

      mycairoprogressbar=blingbling.classical_graph.new()
      mycairoprogressbar:set_height(18)
      mycairoprogressbar:set_width(300)
      mycairoprogressbar:add_value(0.5)
      mycairoprogressbar:set_horizontal(true)
    
    --add the widget in the wibox:

      my_top_wibox[s].widgets = {
            ......,
            mycairoprogressbar.widget,
            .....,
    --reload awesome

  -You can use vicious to feed the graph:
      mycairoprogressbar=blingbling.classical_graph.new()
      mycairoprogressbar:set_height(18)
      mycairoprogressbar:set_width(300)
      vicious.register(mycairoprogressbar, vicious.widgets.mem, '$1', 2)
  
*Progress bar
This widget drawn a progress bar as the initial bar widget of Awesome but it looks like a cylinder. It supports transparency, displaying text. User can set horizontal or vertical and make the graph increase/decrease from bottom to top, top to bottom, left to right and right to left. It takes value in the range (0,1).

  -Create the bar  widget and display it:
    
    --add this before adding the widget in the wibox
      
      mybar:blingbling.progress_bar.new()
      mybar:set_height(18)
      mybar:set_width(60)
    
    --add the widget in the wibox:
      my_top_wibox[s].widgets = {
             ......,
             mybar.widget,
            .....,
     --reload awesome
  
  -You can use vicious to feed the graph or create a timer that feeds it using mybar:add_value( a_value):
      mybar=blingbling.classical_graph.new()
      mybar:set_height(18)
      mybar:set_width(60)
      vicious.register(mybar, vicious.widgets.mem, '$1', 2)

*Volume widget
This graphical widget represent a value between 0 and 1 with a triangle or with bars. Lot of parameters can be customized and there are functions to get data from master or set commands for managing the sound.
  -Create the volume widget and display it:
    
    --add this before adding the widget in the wibox
      
      myvolume:blingbling.volume.new()
      myvolume:set_height(18)
      myvolume:set_width(30)
    
    --add the widget in the wibox:
      my_top_wibox[s].widgets = {
             ......,
             myvolume.widget,
            .....,
     --reload awesome
  
  -You can use vicious to feed the graph or create a timer that feeds it using myvolume:add_value( a_value) or you can use one of the method that get the sound value from:
  amixer
    myvolume:update_master()
  mpc
    myvolume:update_mpd()

  -You can link to the widget some commands to manage the sound:
    myvolume:set_master_control()
      a left clic toggle mute/unmute
      wheel up increase the volume 
      wheel down decrease the volume

*Mpd widget
The most useless widget, but my favorite. This widget reads from the fifo of a local mpd server and display the raw data as a graph which evolves with the music played. There is method a to bind on it mpd commands ( play/stop, next/prev song, increase/decrease volume ) and displaying state and current song informations.

  -Create the mpd widget and display it:
    
    --add this before adding the widget in the wibox
      
      mympd:blingbling.mpd.new()
      mympd:set_height(18)
      mympd:set_width(200)
      mympd:update() 

    --add the widget in the wibox:
      my_top_wibox[s].widgets = {
             ......,
             mympd.widget,
            .....,
     --reload awesome
  
  -Here, the only way to feed the graph is to use:
  
    mympd:update()
  
  -You can link to the widget some commands to manage mpd:
    mympd:set_mpc_commands()
      a left clic toggle stop/start
      a right clic launch an mpd client in a console (xterm -e ncmpcpp by default can be customize with set_launch_mpd_client)
      wheel up increase the mpd volume
      wheel down decrease the mpd volume
      ctrl + wheel up to play the next song
      ctrl + wheel down to play the prev
  
*Net widget
The net widget display two arrows (up and down). Colors of the arrows change with net activity. User can display text with current upload and download informations. User can define the interface (eth0, eth1...)

  -Create a net widget and display it:
    --add this before adding the widget in the wibox

      mynet=blingbling.classical_graph.new()
      mynet:set_height(18)
      mynet:set_interface("eth0")
      (no need to set the width, the widget adapt it from the font size)
    --add the widget in the wibox:

      my_top_wibox[s].widgets = {
            ......,
            mynet.widget,
            .....,
    --reload awesome

    --The widget get the net information alone, no need to use vicious or a timer.
    --You can add a popup that display informations:
      local ip address
      routeur address
      external ip address
      external tor ip address (if tor is running).
      my_net:set_ippopup()

*Top popup
The top popup is a popup created with naugthy that displays a top formated and colorized output. You can bind it to a widget (textbox or image or graph from blingbling). It adds a button fonctionnality to the widget, left click launch htop in a terminal. Furthermore wheel down/up refresh the popup with less or more lines.
  -Usage:
    
    (with mycairograph -> a blingbling classical graph widget)
    
    blingbling.popups.htop(mycairograph,{ title_color = "#rrggbbaa", user_color= "#rrggbbaa", root_color="#rrggbbaa", terminal = "urxvt"})
      
    mandatory arguments:
    title_color define the color of the title's columns.
    user_color display the name of the current user with this color in the top output.
    root_color display the root name with this color in the top output

    optional arguments:
    terminal let you define the terminal used to launch htop. By default it's xterm

*Netstat popup
The  netstat popup is a popup created with naugthy that displays a netstat formated and colorized output. You can bind it to a widget (textbox or image or graph from blingbling).
  -Usage:
    
    (with net -> a textbox widget)
    
    blingbling.popups.netstat(net,{ title_color = "#rrggbbaa", established_color= "#rrggbbaa", listen_color="#rrggbbaa"})
      
    mandatory arguments:
    widget (if blinbling widget add .widget ex: cpu.widget, if textbox or imagebox just put the widget name)
    title_color define the color of the title's columns.
    established_color display the state "ESTABLISHED" the connexion  with this color in the netstat output.
    listen_color display the state "LISTEN" with this color in the netstat output.


*System shutdown/Reboot buttons
The module system provide two buttons linked with a dialog menu for accept or cancel the action (reboot or shutdown). The commands to reboot/shutdown use dbus, and consolekit. You need to have a valid session to make buttons works.(check commands ck-launch-session / ck-list-sessions)

  -Usage:
    --add this before adding the widget in the wibox

      reboot=blingbling.system.rebootmenu(launcher_image, menu_dialog_image_ok, menu_dialog_image_cancel)
      shutdown=blingbling.system.shutdownmenu(launcher_image, menu_dialog_image_ok, menu_.dialog_image_cancel)
    
    --add the widget in the wibox:

      my_top_wibox[s].widgets = {
            ......,
            reboot,
            shutdown,
            .....,
    --reload awesome
    
*Udisks-glue widget menu
This widget is an icon linked to a menu. The menu entries are dynamically added or removed by udisks-glue when cdrom or usb disks are mounted, unmounted or removed. Each action display a popup via naughty.notify.

  -Usage:
    --add this before adding the widget in the wibox:

      ud_glue=blingbling.udisks_glue.new(an_image_file_name)

    --add the widget in the wibox:
    
      my_top_wibox[s].widgets = {
            ......,
            ud_glue.widget,
            .....,
    
    --Make sur that you launch udisks-glue at the begining of your session with the configuration file .udisks-glue.conf that I have created: 
      Just modify this file according to the widget name you put in your rc.lua for the udisks-glue widget:
      match optical {
          automount = true
          automount_options = ro
          post_mount_command = "echo \'ud_glue:mount_device(\"%device_file\",\"%mount_point\",\"Cdrom\")\' | awesome-client"
          post_unmount_command = "echo \'ud_glue:unmount_device(\"%device_file\",\"%mount_point\",\"Cdrom\")\' | awesome-client"
          post_removal_command = "echo \'ud_glue:remove_device(\"%device_file\",\"%mount_point\",\"Cdrom\")\' | awesome-client"
}
    --reload awesome
  
  -Customize:
    you can add icons in the menu for device types and actions like mount,unmount,detach and eject:
     ud_glue:set_mount_icon(an_image_file_name)
     ud_glue:set_umount_icon(an_image_file_name)
     ud_glue:set_detach_icon(an_image_file_name)
     ud_glue:set_eject_icon(an_image_file_name)
     ud_glue:set_Usb_icon(an_image_file_name)
     ud_glue:set_Cdrom_icon(an_image_file_name)

*Menu widget
This widget is the original menu widget from awful that I have modified. With this menu, width of menus and submenus is auto-adjusted to the longer 
label of the menu. There is no fixed width. Usage is the same as awful.menu.

  -Usage:

  my_menu=blingbling.menu({items={})
  with items a table of entries where each entrie is a table like this:
    entrie={label, command or another table of entries for a submenu, an icon}

*Task warrior widget
Task warrior widget is an interface for task warrior (http://taskwarrior.org/projects/show/taskwarrior). The goal is to provide a quick way to see projects and tasks and to provide basic management of tasks or project (just set task done for now). 
  
  -Usage:
    --add this before adding the widget in the wibox:

      my_tasks=blingbling.task_warrior.new(an_image_file_name)

    --add the widget in the wibox:
    
      my_top_wibox[s].widgets = {
            ......,
            my_tasks.widget,
            .....,

  -Customize:
    you can add custom icons for project menu entries, task menu entrie, and task done action.
      my_tasks:set_task_done_icon(an_image_file_name)
      my_tasks:set_task_icon(an_image_file_name)
      my_tasks:set_project_icon(an_image_file_name)

*Table widget layout
This layout can be used in a wibox and offert the possibility to display it's widgets on stacked lines. 
  
  -Usage:
    
    my_wibox.widgets={{widget1, widget2, layout = blingbling.layout.array.line_center},
                      {widget1, widget2, layout = blingbling.layout.array.line_center},
                      layout = blingbling.layout.array.stack_lines
                      }
  -Customize:
    There are 3 layouts for lines of your table:
    blingbling.layout.array.leftright : like leftright layout for awesome
    blingbling.layout.array.rightleft : like rightleft layout for awesome
    blingbling.layout.array.center : all line width is used and each widget is centered. (This layout check bottom and top margins of your widgets)

*Calendar
It's a wibox that display a calendar of the current month with widgets. By default, you have two buttons for displaying next and previous month. Furthermore, You can link the calendar to external agenda.  
    --add this before adding the widget in the wibox:

      my_cal =blingbling.calendar.new({type = "imagebox", image = beautiful.calendar_icon})
      --you can set blingbling.calendar.new({type = "textbox", text = "calendar"}) if you prefer a textbox      
      my_cal:set_cell_padding(4)
      my_cal:set_columns_lines_titles_text_color(beautiful.text_font_color_2)
      my_cal:set_title_text_color(beautiful.bg_focus)


    --add the widget in the wibox:
    
      my_top_wibox[s].widgets = {
            ......,
            my_cal.widget,
            .....,
  -Link to external agenda. By default I have write 2 functions that get informations on remind and taskwarrior. You can activate this fonctionnality with:
    my_cal:set_link_to_external_calendar(true)
      Now when your mouse curser pass on a day widget, it's color change and a menu is displaying remind events for this day. If you scroll up, the menu display task warrior events for the day.

    You have the possibility to had functions for getting data from another application. Here is an example:
    my_cal:append_function_get_events_from(function(day, month, year)
       s="third function ".. " " .. day .. " " .. month .." " ..year
       return s
       end)
    This  function display in the menu the string "third function 26 11 2011" for example.
    If you don't like my two functions for taskwarrior and remind, you can remove them and add your own:
    my_cal:clear_and_add_function_get_events_from(function(day, month, year)
       s="third function ".. " " .. day .. " " .. month .." " ..year
       return s
       end)

Author
-------

cedlemo contact: cedlemo at gmx dot com
