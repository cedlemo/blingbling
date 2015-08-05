---------------------------
-- Default awesome theme --
---------------------------
local home_dir = os.getenv("HOME")
local config_dir = home_dir .. "/.config/awesome"
local themes_dir = config_dir .. "/themes"
local current_theme = themes_dir .. "/default"

theme = {}

theme.font          = "Cantarell 9"
alpha = "55"
theme.bg_normal     = "#333333" .. alpha
theme.bg_focus      = "#ff9800"--#2099d6"--"#535d6c"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#ffffff"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = 0
theme.border_normal = "#00000000"
theme.border_focus  = "#535d6c"
theme.border_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel   = current_theme .. "/taglist/squarefw.png"
theme.taglist_squares_unsel = current_theme .. "/taglist/squarew.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = current_theme .. "/submenu.png"
theme.menu_height = 15
theme.menu_width  = 100

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = current_theme .. "/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = current_theme .. "/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = current_theme .. "/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = current_theme .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = current_theme .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = current_theme .. "/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = current_theme .. "/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = current_theme .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = current_theme .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = current_theme .. "/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = current_theme .. "/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = current_theme .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = current_theme .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = current_theme .. "/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = current_theme .. "/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = current_theme .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = current_theme .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = current_theme .. "/titlebar/maximized_focus_active.png"

theme.wallpaper = "/mnt/data_0/Images/tiles_grey.png"--current_theme .. "/background.png"

-- You can use your own layout icons like this:
theme.layout_fairh = current_theme .. "/layouts/fairhw.png"
theme.layout_fairv = current_theme .. "/layouts/fairvw.png"
theme.layout_floating  = current_theme .. "/layouts/floatingw.png"
theme.layout_magnifier = current_theme .. "/layouts/magnifierw.png"
theme.layout_max = current_theme .. "/layouts/maxw.png"
theme.layout_fullscreen = current_theme .. "/layouts/fullscreenw.png"
theme.layout_tilebottom = current_theme .. "/layouts/tilebottomw.png"
theme.layout_tileleft   = current_theme .. "/layouts/tileleftw.png"
theme.layout_tile = current_theme .. "/layouts/tilew.png"
theme.layout_tiletop = current_theme .. "/layouts/tiletopw.png"
theme.layout_spiral  = current_theme .. "/layouts/spiralw.png"
theme.layout_dwindle = current_theme .. "/layouts/dwindlew.png"

theme.awesome_icon = "/usr/share/awesome/icons/awesome16.png"

-- Define the icon theme for application icons. If not set then the icons 
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil
theme.blingbling = {
    graph_background_color = "#00000033",
    graph_color = theme.bg_focus .."99",
    graph_line_color = theme.bg_focus,
    h_margin = 6,
    v_margin = 4
}
theme.blingbling.tagslist = {}
theme.blingbling.tagslist.normal ={-- background_color =
--widget_background,--rgb(26,26,26),
                                    background_color = "#30303055", --no color
                                    rounded_size = { 0, 0.4,0,0.4 },
                                    text_color = theme.fg_normal,
                                    font = "Cantarell",
                                    font_size = 11, 
                                    h_margin = 2,
                                    v_margin = 2
                                  }
theme.blingbling.tagslist.focus = { h_margin = 2,
                                    v_margin = 2,
                                    --text_background_color = "#00000022",
                                    text_color = theme.fg_focus,
                                    rounded_size = { 0, 0.4,0,0.4 },
                                    font = "Cantarell",
                                    font_size = 11 
                                  }

local cal_common_style = {  h_margin = 0, 
                            v_margin = 0, 
                            rounded_size = 0.3, 
                            background_color = "#00000066", 
                            text_background_color = "#00000000",
                            text_color = "#ffffff", 
                            font ="Cantarell"
                          }
theme.blingbling.calendar = {}
local util = require('awful.util')
theme.blingbling.calendar.prev_next_widget_style = util.table.clone(cal_common_style)    
theme.blingbling.calendar.current_date_widget_style = util.table.clone(cal_common_style)
theme.blingbling.calendar.days_of_week_widget_style = util.table.clone(cal_common_style)
theme.blingbling.calendar.days_of_month_widget_style = util.table.clone(cal_common_style)
theme.blingbling.calendar.weeks_number_widget_style = util.table.clone(cal_common_style)
theme.blingbling.calendar.corner_widget_style = util.table.clone(cal_common_style)
theme.blingbling.calendar.current_day_widget_style = util.table.clone(cal_common_style)
theme.blingbling.calendar.focus_widget_style = util.table.clone(cal_common_style)
theme.blingbling.calendar.info_cell_style = util.table.clone(cal_common_style)
theme.blingbling.calendar.info_cell_style.background_color = transparent
theme.blingbling.calendar.current_day_widget_style.background_color = theme.bg_focus 
theme.blingbling.calendar.current_day_widget_style.text_color = "#000000"
theme.blingbling.calendar.current_day_widget_style.rounded_size = {0.5,0,0.5,0}
theme.blingbling.calendar.focus_widget_style.background_color = "#888888"
theme.blingbling.calendar.focus_widget_style.rounded_size = {0,0.5,0,0.5}
theme.blingbling.calendar.days_of_week_widget_style.text_color = "#bbbbbb"
theme.blingbling.calendar.days_of_week_widget_style.background_color ="#00000022"
theme.blingbling.calendar.corner_widget_style.text_color = "#bbbbbb"
theme.blingbling.calendar.corner_widget_style.background_color = "#00000022"
theme.blingbling.calendar.weeks_number_widget_style.text_color = "#bbbbbb" 
theme.blingbling.calendar.weeks_number_widget_style.background_color = "#00000022" 
return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
