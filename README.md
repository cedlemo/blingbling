##Blingbling:

Blingbling is a graphical widget library for Awesome Windows Manager. The goal of the Blingbling library is to provide more fancy, customisable and easy to setup graphical widgets, popups or signals for Awesome WM.

Originally, I have written Blingbling for myself but I share it under the GNU GPL-v2 (http://www.gnu.org/licenses/old-licenses/gpl-2.0.html). Testers and feedbacks are welcome!

The current version is the v2.0 and works with Awesome WM 3.5. There are a lot of changes between the v1.0 and the v2.0 and I don't have finished to adapt all the widgets of the last version yet.

###Version: v2.0

*  line_graph
*  progress_graph
*  triangular_progress_graph
*  value_text_box
*  volume
*  popups
*  net
*  task_warrior
*  udisks_glue
*  system

This part is an adaptation of some of the wlourf awesome stuff : http://wlourf.deviantart.com/art/widgets-for-awesome-wm-v1-3-269061228.
*  wlourf circle

####Installation
($XDG_CONFIG_HOME usually ~/.config)

    cd $XDG_CONFIG_HOME/awesome/
    git clone git://github.com/cedlemo/blingbling.git

####Use:
In your rc.lua:

    require("blingbling")

#####line_graph
Create a line graph and fill it with vicious for example (you can configure the widget with a table or with the related methods ):

    cpu_graph = blingbling.line_graph({ height = 18,
                                            width = 200,
                                            show_text = true,
                                            label = "Load: $percent %",
                                            rounded_size = 0.3,
                                            graph_background_color = "#00000033"
                                          })
    --cpu_graph:set_height(18)
    --cpu_graph:set_width(200)
    --cpu_graph:set_show_text(true)
    --cpu_graph:set_label("Load: $percent %")
    --cpu_graph:set_rounded_size(0.3)
    --cpu_graph:set_graph_background_color("#00000033")
    vicious.register(cpu_graph, vicious.widgets.cpu,'$1',2)

#####progress_graph
Create some progress graphs :

    cores_graph_conf ={height = 18, width = 8, rounded_size = 0.3}
    cores_graphs = {}
    for i=1,4 do
      cores_graphs[i] = blingbling.progress_graph( cores_graph_conf)
      vicious.register(cores_graphs[i], vicious.widgets.cpu, "$"..(i+1).."",1)
    end

Add those widgets to your wibox:

    for i=1,4 do
      left_layout:add(cores_graphs[i])
    end

#####value_text_box
Create a value text box:

    home_fs_usage=blingbling.value_text_box({height = 18, width = 40, v_margin = 4})
    --home_fs_usage:set_height(16)
    --home_fs_usage:set_width(40)
    --home_fs_usage:set_v_margin(2)
    home_fs_usage:set_text_background_color("#00000099")
    home_fs_usage:set_values_text_color({{"#88aa00ff",0}, --all value > 0 will be displaying using this color
                              {"#d4aa00ff", 0.75},
                              {"#d45500ff",0.77}})
    --There is no maximum number of color that users can set, just put the lower values at first. 
    home_fs_usage:set_text_color(beautiful.textbox_widget_as_label_font_color)
    home_fs_usage:set_rounded_size(0.4)
    home_fs_usage:set_font_size(8)
    home_fs_usage:set_background_color("#00000044")
    home_fs_usage:set_label("usage: $percent %")
    
    vicious.register(home_fs_usage, vicious.widgets.fs, "${/home used_p}", 120 )

#####triangular_progress_graph
Create a triangular progress graph (can be feed with vicious too):

    triangular = blingbling.triangular_progressgraph({height = 18, width = 40, bar = true, v_margin = 2, h_margin = 2})
    triangular:set_value(0.7)

#####volume
Create a volume widget (triangular progress bar with specific methods):

    volume_master = blingbling.volume({height = 18, width = 40, bar =true, show_text = true, label ="$percent%"})
    volume_master:update_master()
    volume_master:set_master_control()

#####popups
Add popups to one or more widget with blinbling.popups module:

    --Example with cpu_graph created previously with default color :
    blingbling.popups.htop(cpu_graph, { terminal =  terminal })

    --Example with custom colors:
    blingbling.popups.htop(cpu_graph, { title_color = beautiful.notify_font_color_1 , user_color = beautiful.notify_font_color_2 , root_color = beautiful.notify_font_color_3 , terminal =  terminal })

#####net
Create a net widget with a popup that display connection informations:

    netwidget = blingbling.net({interface = "eth0", show_text = true})
    netwidget:set_ippopup()

#####task_warrior
Create a new task_warrior menu:

    task_w = blingbling.task_warrior({ menu_icon = file_path, project_icon = file_path, task_icon = file_path ,task_done_icon = file_path, width})
    task_w:set_project_icon(themes_dir .. "/test/titlebar/maximized_focus_active.png")

#####udisks_glue
Create a menu which displaying mounted media with actions like mount/unmount/detach/eject. Must be used with .udisks-glue.conf that I created. ( The name of the variable containing the widget must be the same in your rc.lua and in the .udisks-glue.conf).

    udisks_glue=blingbling.udisks_glue.new({ menu_icon = themes_dir .. "/test/titlebar/maximized_focus_active.png"})

note: udisks-glue have not been updated since one or 2 years. Furthermore it doesn't work with logind which is used in a lot of distributions. So I think that I have to find another way to manage external media.

#####system
Provide buttons with menu in order to reboot or shutdown the system. User can set icon for menu, accept and cancel actions.

    shutdown=blingbling.system.shutdownmenu(beautiful.shutdown,
                                            beautiful.accept,
                                            beautiful.cancel)

    reboot=blingbling.system.rebootmenu(beautiful.reboot,
                                        beautiful.accept,
                                        beautiful.cancel)

#####wlourf circle graph
This is the circle graph of wlourf that you can feed with vicious.

    circle = blingbling.wlourf_circle_graph({radius= 5, height = 18, width = 36, show_text = true, label = "cpu", h_margin = 2, v_margin = 0 --[[, font = {family = "Times New Roman", slang = "italic", weight = "bold"}]]})
    circle:set_graph_colors({{"#88aa00ff",0}, --all value > 0 will be displaying using this color
                           {"#d4aa00ff", 0.5},
                           {"#d45500ff",0.77}})
    --set the value directly
    --circle:add_value(0.5)
    --or use vicious
    vicious.register(circle, vicious.widgets.cpu,'$1',2)


#####Global theming for blingbling.

You can provide default theme for blingbling instead of configuring colors for each widgets. You just need to create a blingbling table in your theme.lua file and override values that can be find in superproperties.lua:

    theme.blingbling = {
    htop_title_color = "#ff0000",
    htop_user_color = "#00ff00"
    }

Values that can be modified are:

Theme values for graph or value_text_box objects: 

*  h_margin
*  v_margin
*  background_border
*  background_color
*  graph_background_color
*  graph_background_border
*  rounded_size
*  graph_color
*  graph_line_color
*  text_color
*  font_size
*  background_text_color

Theme values for popups module:

*  htop_title_color
*  htop_user_color
*  htop_root_color
*  netstat_title_color
*  nestat_established_color
*  netstat_listen_color

Theme value for taskwarrior:

*  menu_width


###Version: v1.0

Blingbling v1.0 works for awesome 3.4.10 and 3.4.11.
*  Value text box
*  Classical graph
*  Tiled graph
*  Progress graph
*  Progress bar
*  Volume graph
*  Mpd widget
*  Net widget
*  Top popup
*  Netstat popup
*  System shutdown/Reboot button
*  Udisks-glue widget menu
*  Menu widget
*  Task warrior widget
*  Table widget layout
*  Calendar

####Dependencies

Blingbling require oocairo. The address of the website of the project is : http://oocairo.naquadah.org.

Check your package manager to see if you can install an already packaged version of oocairo for your system.

####Installation

($XDG_CONFIG_HOME usually ~/.config)

    cd $XDG_CONFIG_HOME/awesome/
    git clone git://github.com/cedlemo/blingbling.git
    cd blingbling
    git checkout v1.0


Author:
-------

cedlemo contact: cedlemo at gmx dot com

Contributors
-------

quizzmaster

mykhaylo-
