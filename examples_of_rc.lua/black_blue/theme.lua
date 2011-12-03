---------------------------
-- "Need_Aspirin" awesome theme --
---------------------------
--awesome colors
green="#7fb219"
cyan="#7f4de6"
red="#e04613"                             
lblue="#6c9eab"                        
dblue="#00ccff"
black="#000000"
lgrey="#d2d2d2"
dgrey="#333333"
white="#ffffff"

alpha="dd"

--bash colors
--add the following lines in your bashrc

--#color foreground prompt
--BLACK='\[\e[0;30m\]'
--DGRAY='\[\e[1;30m\]'
--BLUE='\[\e[0;34m\]'
--LBLUE='\[\e[1;34m\]'
--GREEN='\[\e[0;32m\]'
--LGREEN='\[\e[1;32m\]'
--CYAN='\[\e[0;36m\]'
--LCYAN='\[\e[1;36m\]'
--RED='\[\e[0;31m\]'
--LRED='\[\e[1;31m\]'
--PURPLE='\[\e[0;35m\]'
--LPURPLE='\[\e[1;35m\]'
--BROWN='\[\e[0;33m\]'
--YELLOW='\[\e[1;33m\]'
--LGRAY='\[\e[0;37m\]'
--WHITE='\[\e[1;37m\]'
--RESET_COLOR='\[\e[0m\]'
--#color background prompt
--BG_BLACK='\[\e[40m\]'       # Black
--BG_RED='\e[41m'         # Red
--BG_GREEN='\e[42m'       # Green
--BG_YELLOW='\e[43m'      # Yellow
--BG_BLUE='\e[44m'        # Blue
--BG_PURPLE='\e[45m'      # Purple
--BG_CYAN='\e[46m'        # Cyan
--BG_WHITE='\e[47m'       # White

--color background prompt
--don't forget to set double\ before \n, \w etc...
PS1='"\\n${DGRAY}╭─[${LBLUE}\\w${DGRAY}]\\n${DGRAY}╰─[${WHITE}\\T${DGRAY}]${DGRAY}>${BLUE}>${LBLUE}> ${RESET_COLOR}"'

my_bash_profile=home .."/.bashrc"
tmp_file="/tmp/bash_lua_test.tmp"
fh,err = io.open(my_bash_profile)
if err then print("OOps"); return; end
-- Open a file for write
fho,err = io.open(tmp_file,"w")
while true do
 line = fh:read()
 if line == nil then break end
    if string.find(line,"^PS1=") then
       fho:write("PS1="..PS1)
       fho:write("\n")
    else 
       fho:write(line) 
       fho:write("\n")
    end
 end
fh:close()
fho:close()
os.remove(my_bash_profile)
os.execute("cp "..tmp_file .." "..my_bash_profile)

theme = {}

theme.font          = "Droid Sans Mono 7"

theme.bg_normal     = black.."00" 
theme.bg_focus      = black 
theme.bg_urgent     = red
theme.bg_minimize   = dgrey 

theme.fg_normal     = lgrey 
theme.fg_focus      = dblue
theme.fg_urgent     = white
theme.fg_minimize   = white

theme.border_width  = "1"
theme.border_normal = black
theme.border_focus  = dblue 
theme.border_marked = red 

-- There are other variable sets
-- overriding the black_blue one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:

theme.taglist_bg_focus = black 
theme.taglist_fg_focus = dblue 

theme.tasklist_bg_focus = black
theme.tasklist_fg_focus = dblue

--font color fort textbox widget used as label in my wibox
theme.textbox_widget_as_label_font_color = white 
theme.textbox_widget_margin_top =1 

--font colors for textbox widget
theme.text_font_color_1 = green
theme.text_font_color_2 = dblue
theme.text_font_color_3 = white

--font colors for naughty popups
theme.notify_font_color_1 = green
theme.notify_font_color_2 = dblue
theme.notify_font_color_3 = black
theme.notify_font_color_4 = white
theme.notify_font= "Droid Sans Mono 7"
theme.notify_fg = theme.fg_normal
theme.notify_bg = theme.bg_normal
theme.notify_border = theme.border_focus
--colors,height for all awfull widgets
theme.awful_widget_bckgrd_color = dgrey 
theme.awful_widget_border_color = dgrey 
theme.awful_widget_color= dblue
theme.awful_widget_gradien_color_1= orange 
theme.awful_widget_gradien_color_2= orange
theme.awful_widget_gradien_color_3= orange
theme.awful_widget_height=14
theme.awful_widget_margin_top=2 

-- Display the taglist squares
theme.taglist_squares_sel   = config_dir .. "/themes/black_blue/taglist/squarefw.png"
theme.taglist_squares_unsel = config_dir .. "/themes/black_blue/taglist/squarew.png"

theme.tasklist_floating_icon = config_dir .. "/themes/black_blue/tasklist/floatingw.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = config_dir .. "/themes/black_blue/submenu.png"
theme.menu_height = "12"
theme.menu_width  = "120"
theme.menu_border_color = dgrey 
theme.menu_border_width = 1

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = 

-- Define the image to load
theme.titlebar_close_button_normal = config_dir .. "/themes/black_blue/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = config_dir .. "/themes/black_blue/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = config_dir .. "/themes/black_blue/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = config_dir .. "/themes/black_blue/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = config_dir .. "/themes/black_blue/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = config_dir .. "/themes/black_blue/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = config_dir .. "/themes/black_blue/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = config_dir .. "/themes/black_blue/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = config_dir .. "/themes/black_blue/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = config_dir .. "/themes/black_blue/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = config_dir .. "/themes/black_blue/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = config_dir .. "/themes/black_blue/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = config_dir .. "/themes/black_blue/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = config_dir .. "/themes/black_blue/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = config_dir .. "/themes/black_blue/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = config_dir .. "/themes/black_blue/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = config_dir .. "/themes/black_blue/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = config_dir .. "/themes/black_blue/titlebar/maximized_focus_active.png"

-- You can use your own command to set your wallpaper
theme.wallpaper_cmd = { "awsetbg ".. config_dir .. "/themes/black_blue/background.jpg" }

-- You can use your own layout icons like this:
theme.layout_fairh = config_dir .. "/themes/black_blue/layouts/fairhw.png"
theme.layout_fairv = config_dir .. "/themes/black_blue/layouts/fairvw.png"
theme.layout_floating  = config_dir .. "/themes/black_blue/layouts/floatingw.png"
theme.layout_magnifier = config_dir .. "/themes/black_blue/layouts/magnifierw.png"
theme.layout_max = config_dir .. "/themes/black_blue/layouts/maxw.png"
theme.layout_fullscreen = config_dir .. "/themes/black_blue/layouts/fullscreenw.png"
theme.layout_tilebottom = config_dir .. "/themes/black_blue/layouts/tilebottomw.png"
theme.layout_tileleft   = config_dir .. "/themes/black_blue/layouts/tileleftw.png"
theme.layout_tile = config_dir .. "/themes/black_blue/layouts/tilew.png"
theme.layout_tiletop = config_dir .. "/themes/black_blue/layouts/tiletopw.png"
theme.layout_spiral  = config_dir .. "/themes/black_blue/layouts/spiralw.png"
theme.layout_dwindle = config_dir .. "/themes/black_blue/layouts/dwindlew.png"

theme.awesome_icon = config_dir .. "/themes/black_blue/awesome.png"
theme.mpdicon = config_dir .. "/themes/black_blue/icons/note-48x48.png"
theme.shortcut = config_dir .. "/themes/black_blue/icons/keyboard_shortcut.png"
theme.shutdown = config_dir .. "/themes/black_blue/icons/shutdown.png"
theme.reboot = config_dir .. "/themes/black_blue/icons/reboot.png"
theme.accept = config_dir .. "/themes/black_blue/icons/accept.png"
theme.cancel = config_dir .. "/themes/black_blue/icons/cancel.png"
theme.calendar = config_dir .. "/themes/black_blue/icons/calendar.png"
theme.task = config_dir .. "/themes/black_blue/icons/task.png"
theme.tasks = config_dir .. "/themes/black_blue/icons/tasks.png"
theme.task_done = config_dir .. "/themes/black_blue/icons/task_done.png"
theme.project = config_dir .. "/themes/black_blue/icons/project.png"
theme.udisks_glue = config_dir .. "/themes/black_blue/icons/udisk-glue.png"
theme.usb = config_dir .. "/themes/black_blue/icons/usb.png"
theme.cdrom = config_dir .. "/themes/black_blue/icons/cdrom.png"
return theme
