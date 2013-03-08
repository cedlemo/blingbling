##Blingbling:

Blingbling is a graphical widget library for Awesome Windows Manager. The goal of the Blingbling library is to provide more fancy, customisable and easy to setup graphical widgets, popups or signals for Awesome WM.

Originally, I have written Blingbling for myself but I share it under the GNU GPL-v2 (http://www.gnu.org/licenses/old-licenses/gpl-2.0.html). Testers and feedbacks are welcome!

The current version is the v2.0 and works with Awesome WM 3.5. There are a lot of changes between the v1.0 and the v2.0 and I don't have finished to adapt all the widgets of the last version yet.

###Version: v2.0

*line_graph
*progress_graph
*triangular_progress_graph
*value_text_box
*volume

####Installation
($XDG_CONFIG_HOME usually ~/.config)

    cd $XDG_CONFIG_HOME/awesome/
    git clone git://github.com/cedlemo/blingbling.git

####Use:
In your rc.lua:
    require("blingbling")

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

Create a triangular progress graph (can be feed with vicious too):

    triangular = blingbling.triangular_progressgraph({height = 18, width = 40, bar = true, v_margin = 2, h_margin = 2})
    triangular:set_value(0.7)

Create a volume widget (triangular progress bar with specific methods):

    volume_master = blingbling.volume({height = 18, width = 40, bar =true, show_text = true, label ="$percent%"})
    volume_master:update_master()
    volume_master:set_master_control()


###Version: v1.0

Blingbling v1.0 works for awesome 3.4.10 and 3.4.11.
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

####Dependencies

Blingbling require oocairo. The address of the website of the project is : http://oocairo.naquadah.org.

Check your package manager to see if you can install an already packaged version of oocairo for your system.

####Installation

($XDG_CONFIG_HOME usually ~/.config)

    cd $XDG_CONFIG_HOME/awesome/
    git clone git://github.com/cedlemo/blingbling.git
    cd blingbling
    git checkout v1.0


Author
-------

cedlemo contact: cedlemo at gmx dot com
