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
local light_bordeaux = rgb(191,64,64)
local grey = "#444444ff"
local light_grey = "#555555"
local white = "#ffffff"
local light_white = "#999999"
local black = "#000000"
local light_black = "#222222"

theme = {}

theme.font          = "Droid Sans 8"

theme.bg_normal     = grey
theme.bg_focus      = bordeaux
theme.bg_urgent     = light_bordeaux
theme.bg_minimize   = light_grey
theme.bg_systray    = theme.bg_normal 

theme.fg_normal     = light_black
theme.fg_focus      = white
theme.fg_urgent     = white
theme.fg_minimize   = light_white

theme.border_width  = 0 
theme.border_normal = theme.bg_normal
theme.border_focus  = theme.bg_normal
theme.border_marked = theme.bg_normal

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
theme.tasklist_bg_focus = theme.bg_normal
theme.tasklist_fg_focus = light_white
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
    graph_background_color = bordeaux,
    graph_color = light_white,
    graph_line_color = light_white,
    reboot = theme_dir .. "/reboot.png",
    shutdown = theme_dir .. "/shutdown.png",
    logout = theme_dir .. "/logout.png",
    accept = theme_dir .. "/ok.png",
    cancel = theme_dir .. "/cancel.png",
    lock = theme_dir .. "/lock.png",
    tagslist = {    normal ={   background_color = "#00000055",
                                background_text_color = "#00000000", --no color
                                rounded_size = { 0, 0.4,0,0.4 },
                                text_color = theme.fg_normal,
                                font = "Droid Sans"
                            },
                    focus ={    background_color = "#00000055",
                                background_text_color = theme.bg_focus,
                                rounded_size = { 0, 0.4,0,0.4 },
                                font = "Droid Sans"
                            }
    }
}
theme.blingbling.tagslist.urgent = theme.blingbling.tagslist.focus
theme.blingbling.tagslist.occupied = theme.blingbling.tagslist.normal

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
