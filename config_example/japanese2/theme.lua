---------------------------
-- japanese2 awesome theme --
---------------------------

local theme_dir="/home/cedlemo/.config/awesome/themes/japanese2"

local function rgb(red, green, blue)
  if type(red) == "number" or type(green) == "number" or type(blue) == "number" then
    return "#"..string.format("%02x",red)..string.format("%02x",green)..string.format("%02x",blue)
  else    
    return nil
  end
end

local function rgba(red, green, blue, alpha) 
  if type(red) == "number" or type(green) == "number" or type(blue) == "number" or type(alpha) == "number" then
    return "#"..string.format("%02x",red)..string.format("%02x",green)..string.format("%02x",blue)..string.format("%02x",alpha * 255)
  else
    return nil
  end
end

--colors
local bordeaux= rgb(47,28,28)
local light_bordeaux = rgba(191,64,64,0.6)
local dark_grey = "#121212"
local grey = "#444444ff"
local light_grey = "#555555"
local white = "#ffffff"
local light_white = "#999999"
local light_black = "#232323"
local red = "#b9214f"
local bright_red = "#ff5c8d"
local yellow = "#ff9800"
local bright_yellow = "#ffff00"
local black = "#000000"
local bright_black = "#5D5D5D"
local green = "#A6E22E"
local bright_green = "#CDEE69"
local blue = "#3399ff"
local bright_blue = "#9CD9F0"
local magenta = "#8e33ff"
local bright_magenta = "#FBB1F9"
local cyan = "#06a2dc"
local bright_cyan = "#77DFD8"
local widget_background = "#303030"
--local white = "#B0B0B0"
local bright_white = "#F7F7F7"
local transparent = "#00000000"
--background=#121212
--foreground=#aeafad


theme = {}
theme.grey = grey
theme.light_grey = light_grey
theme.white = white
theme.black = black
theme.light_black = light_black
theme.red = red
theme.bright_red = bright_red
theme.yellow = yellow
theme.bright_yellow = bright_yellow
theme.bright_black = bright_black
theme.green = green
theme.bright_green =bright_green
theme.blue = blue
theme.bright_blue = bright_blue
theme.magenta = magenta
theme.bright_magenta = bright_magenta
theme.cyan = cyan
theme.bright_cyan = bright_cyan
theme.widget_background = widget_background
theme.transparent = transparent
theme.font          = "Droid Sans 8"

theme.bg_normal     = light_black 
theme.bg_focus      = red 
theme.bg_urgent     = bright_red
theme.bg_minimize   = light_black
theme.bg_systray    = theme.bg_normal 

theme.fg_normal     = light_white
theme.fg_focus      = white 
theme.fg_urgent     = white
theme.fg_minimize   = black

theme.border_width  = 0 
theme.border_normal = "#232323"
theme.border_focus  = "#999999"
theme.border_marked = theme.bg_normal

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
theme.tasklist_bg_focus = light_black 
theme.tasklist_fg_focus = yellow 
theme.titlebar_bg_normal = light_black
theme.titlebar_bg_focus  = light_black 

--theme.taglist_bg_normal= "#333333"
--theme.titlebar_bg_normal =
--theme.titlebar_bg_focus =
-- Display the taglist squares
theme.taglist_squares_sel   = theme_dir.."/taglist/squaref.png"
theme.taglist_squares_unsel = theme_dir.."/taglist/square.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = theme_dir.."/submenu.png"
theme.menu_border_width = 3
theme.menu_border_color = theme.bg_normal
theme.menu_height = 14
theme.menu_width  = 100
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = theme_dir.."/titlebar/close.png"
theme.titlebar_close_button_focus  = theme_dir.."/titlebar/close.png"

theme.titlebar_ontop_button_normal_inactive = theme_dir.."/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = theme_dir.."/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = theme_dir.."/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = theme_dir.."/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = theme_dir.."/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = theme_dir.."/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = theme_dir.."/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = theme_dir.."/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = theme_dir.."/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = theme_dir.."/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = theme_dir.."/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = theme_dir.."/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = theme_dir.."/titlebar/maximize.png"
theme.titlebar_maximized_button_focus_inactive  = theme_dir.."/titlebar/maximize.png"
theme.titlebar_maximized_button_normal_active = theme_dir.."/titlebar/maximize.png"
theme.titlebar_maximized_button_focus_active  = theme_dir.."/titlebar/maximize.png"

theme.wallpaper = theme_dir.."/wallpaper-なかの-まんが.jpg"

-- You can use your own layout icons like this:
theme.layout_fairh = theme_dir.."/layouts/fairh.png"
theme.layout_fairv = theme_dir.."/layouts/fairv.png"
theme.layout_floating  = theme_dir.."/layouts/floating.png"
theme.layout_magnifier = theme_dir.."/layouts/magnifier.png"
theme.layout_max = theme_dir.."/layouts/max.png"
theme.layout_fullscreen = theme_dir.."/layouts/fullscreen.png"
theme.layout_tilebottom = theme_dir.."/layouts/tilebottom.png"
theme.layout_tileleft   = theme_dir.."/layouts/tileleft.png"
theme.layout_tile = theme_dir.."/layouts/tile.png"
theme.layout_tiletop = theme_dir.."/layouts/tiletop.png"
theme.layout_spiral  = theme_dir.."/layouts/spiral.png"
theme.layout_dwindle = theme_dir.."/layouts/dwindle.png"

theme.awesome_icon = theme_dir .. "/awesome.png"

-- Define the icon theme for application icons. If not set then the icons 
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "/home/cedlemo/.icons/AwOkenDark" 
theme.blingbling = {
    background_color = "#00000000",
    graph_background_color = widget_background,
    graph_color = bright_magenta,
    graph_line_color = magenta,
    rounded_size = 0.3,        
    text_color = light_white,
    reboot = theme_dir .. "/reboot.png",
    shutdown = theme_dir .. "/shutdown.png",
    logout = theme_dir .. "/logout.png",
    accept = theme_dir .. "/ok.png",
    cancel = theme_dir .. "/cancel.png",
    lock = theme_dir .. "/lock.png",
    font = "Droid Sans Mono",
    font_size = 9 
}
theme.blingbling.tagslist = {}
theme.blingbling.tagslist.normal ={ background_color = widget_background,--rgb(26,26,26),
                                    text_background_color = "#00000000", --no color
                                    rounded_size = { 0, 0.4,0,0.4 },
                                    text_color = theme.fg_normal,
                                    font = "Droid Sans",
                                    font_size = 7 
                                  }
theme.blingbling.tagslist.focus = { h_margin = 1,
                                    v_margin = 1,
                                    background_color = red, 
                                    text_background_color = widget_background,
                                    text_color = theme.fg_normal,
                                    rounded_size = { 0, 0.4,0,0.4 },
                                    font = "Droid Sans italic",
                                    font_size = 8
                                  }

theme.blingbling.tagslist.urgent = theme.blingbling.tagslist.focus
theme.blingbling.tagslist.occupied = theme.blingbling.tagslist.normal

local cal_common_style = {  h_margin = 0, 
                            v_margin = 0, 
                            rounded_size = 0.3, 
                            background_color = widget_background, 
                            text_background_color = "#00000000",
                            text_color = white, 
                            font ="Droid Sans"
                          }
theme.blingbling.calendar = {}
local util = require('awful.util')
theme.blingbling.calendar.prev_next_widget_style =
util.table.clone(cal_common_style)    
theme.blingbling.calendar.current_date_widget_style =
util.table.clone(cal_common_style)
theme.blingbling.calendar.days_of_week_widget_style =
util.table.clone(cal_common_style)
theme.blingbling.calendar.days_of_month_widget_style =
util.table.clone(cal_common_style)
theme.blingbling.calendar.weeks_number_widget_style =
util.table.clone(cal_common_style)
theme.blingbling.calendar.corner_widget_style =
util.table.clone(cal_common_style)
theme.blingbling.calendar.current_day_widget_style =
util.table.clone(cal_common_style)
theme.blingbling.calendar.focus_widget_style =
util.table.clone(cal_common_style)
theme.blingbling.calendar.info_cell_style = util.table.clone(cal_common_style)
theme.blingbling.calendar.info_cell_style.background_color = transparent
theme.blingbling.calendar.current_day_widget_style.background_color = green
theme.blingbling.calendar.current_day_widget_style.text_color = dark_grey
theme.blingbling.calendar.current_day_widget_style.rounded_size = {0.5,0,0.5,0}
theme.blingbling.calendar.focus_widget_style.background_color = yellow
theme.blingbling.calendar.focus_widget_style.rounded_size = {0,0.5,0,0.5}
theme.blingbling.calendar.days_of_week_widget_style.text_color = light_grey
theme.blingbling.calendar.corner_widget_style.text_color = light_grey
theme.blingbling.calendar.weeks_number_widget_style.text_color = light_grey 
--[[theme.blingbling.calendar = {
        prev_next_widget_style = {  h_margin = 0, 
                                    v_margin = 0, 
                                    rounded_size = 0.4, 
                                    background_color = red, --"#330033", 
                                    text_background_color = "#00000000",
                                    text_color = "#ffffff", 
                                    font ="Droid Sans"},
	current_date_widget_style = { h_margin = 0, 
                                    v_margin = 0,
                                    rounded_size = 0.4,  
                                    background_color = red, --"#330033", 
                                    text_background_color = "#00000000",
                                    text_color = "#ffffff", 
                                    font ="Droid Sans"},
	days_of_week_widget_style = { h_margin = 0, 
                                    v_margin = 0,
                                    rounded_size = 0.4,  
                                    background_color = "#666666", 
                                    text_background_color = "#00000000",
                                    text_color = "#333333", 
                                    font ="Droid Sans"},
	days_of_month_widget_style = { h_margin = 0, 
                                    v_margin = 0, 
                                    rounded_size = 0.4, 
                                    background_color = red,--"#330033", 
                                    text_background_color = "#00000000",
                                    text_color = "#ffffff", 
                                    font ="Droid Sans"},
	weeks_number_widget_style = { h_margin = 0, 
                                    v_margin = 0, 
                                    rounded_size = 0.4, 
                                    background_color = "#111111", 
                                    text_background_color = "#00000000",
                                    text_color = "#ffffff", 
                                    font ="Droid Sans"},
	corner_widget_style =       { h_margin = 0, 
                                    v_margin = 0, 
                                    rounded_size = 0.4, 
                                    text_background_color = "#00000000",
                                    background_color = "#111111", 
                                    text_color = "#ffffff", 
                                    font ="Droid Sans"},
	current_day_widget_style =  { h_margin = 0, 
                                    v_margin = 0,
                                    rounded_size = {0.5,0,0.5,0},  
                                    background_color = "#338833", 
                                    text_background_color = "#00000000",
                                    text_color = "#999999", 
                                    font ="Droid Sans"},
	focus_widget_style =        { h_margin = 0, 
                                    v_margin = 0, 
                                    rounded_size = 0, 
                                    background_color = "#999999", 
                                    text_background_color = "#00000000",
                                    text_color = "#330033", 
                                    font ="Droid Sans"},
	info_cell_style =           { h_margin = 0, 
                                    v_margin = 0, 
                                    rounded_size = 0, 
                                    background_color = "#66666600", 
                                    text_background_color = "#00000000",
                                    text_color = "#888888", 
                                    font ="Droid Sans"},
        }
--]]

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
