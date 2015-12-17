--@author cedlemo
---Centralize theming values for blingbling widgets
--Users can create a theme.blingbling table in theirs theme.lua and defines some values for theirs widgets.
--@module blingbling.superproperties
local beautiful = require("beautiful")
local function init(path)
  beautiful.init(path)
end
local blingbling_theme= (type(beautiful.blingbling) == "table") and beautiful.blingbling  or {}
local tagslist_theme = blingbling_theme.tagslist or {}
local tagslist_theme_normal = tagslist_theme.normal or {}
local tagslist_theme_focus = tagslist_theme.focus or {}
local tagslist_theme_urgent = tagslist_theme.urgent or {}
local tagslist_theme_occupied = tagslist_theme.occupied or {}
local calendar_theme = blingbling_theme.calendar or {}
local calendar_theme_prev_next_widget_style = calendar_theme.prev_next_widget_style or {}
local calendar_theme_current_date_widget_style = calendar_theme.current_date_widget_style or {}
local calendar_theme_days_of_week_widget_style = calendar_theme.days_of_week_widget_style or {}
local calendar_theme_days_of_month_widget_style = calendar_theme.days_of_month_widget_style or {}
local calendar_theme_weeks_number_widget_style = calendar_theme.weeks_number_widget_style or {}
local calendar_theme_corner_widget_style = calendar_theme.corner_widget_style or {}
local calendar_theme_current_day_widget_style = calendar_theme.current_day_widget_style or {}
local calendar_theme_focus_widget_style = calendar_theme.focus_widget_style or {}
local calendar_theme_info_cell_style = calendar_theme.info_cell_style or {}
return {
  h_margin = blingbling_theme.h_margin or 2 ;
  v_margin = blingbling_theme.v_margin or 2 ;
  background_border = blingbling_theme.background_border or nil ;
  background_color = blingbling_theme.background_color or "#00000000" ;
  graph_background_color = blingbling_theme.graph_background_color or "#00000066" ;
  graph_background_border= blingbling_theme.graph_background_border or "#00000000" ;
  rounded_size= blingbling_theme.rounded_size or 0 ;
  graph_color= blingbling_theme.graph_color or "#7fb21966" ;
  graph_line_color= blingbling_theme.graph_line_color or "#7fb219" ;
  text_color= blingbling_theme.text_color or "#ffffff" ;
  font_size= blingbling_theme.font_size or 9 ;
  font = blingbling_theme.font or "sans";
  value_format = blingbling_theme.value_format or "%2.f";
  text_background_color = blingbling_theme.text_background_color or "#00000066" ;
  background_text_border = blingbling_theme.background_text_border or "#ffffff";
--theme values for popups module:
  htop_title_color = blingbling_theme.htop_title_color or "#7fb219";
  htop_user_color = blingbling_theme.htop_user_color or "#7fb219";
  htop_root_color = blingbling_theme.htop_root_color or "#000000";
  netstat_title_color = blingbling_theme.netstat_title_color or "#7fb219";
  nestat_established_color = blingbling_theme.nestat_established_color or "#7fb219";
  netstat_listen_color = blingbling_theme.netstat_listen_color or "#f38915";
--theme values for value_text_box
  padding = blingbling_theme.padding or 2;
  menu_width = blingbling_theme.menu_width or 300;
--theme values for system menus
	reboot = blingbling_theme.reboot or nil;
	shutdown = blingbling_theme.shutdown or nil;
	logout = blingbling_theme.logout or nil;
	accept = blingbling_theme.accept or nil;
	cancel = blingbling_theme.cancel or nil;
	lock = blingbling_theme.lock or nil;
  values_text_color = { {"#00ff00", 0},
                        {"#0000ff", 0.5},
                        {"#ff0000", .75}};
  --theme values for tagslist	
	tagslist=	{
						normal ={ background_color = tagslist_theme_normal.background_color or beautiful.bg_normal,
											text_background_color = tagslist_theme_normal.text_background_color or "#000000",
											text_color = tagslist_theme_normal.text_color or beautiful.fg_normal,
											h_margin = tagslist_theme_normal.h_margin or blingbling_theme.h_margin or 2, 
											v_margin = tagslist_theme_normal.v_margin or blingbling_theme.v_margin or 2,
											rounded_size = tagslist_theme_normal.rounded_size or blingbling_theme.rounded_size or 0,
											font_size= tagslist_theme_normal.font_size or 9,
											font = tagslist_theme_normal.font or "sans"
											},
						focus = { background_color = tagslist_theme_focus.background_color or beautiful.taglist_bg_focus or beautiful.bg_focus,
											text_background_color = tagslist_theme_focus.text_background_color or "#000000",
											text_color = tagslist_theme_focus.text_color or beautiful.taglist_fg_focus or beautiful.fg_focus,
											h_margin = tagslist_theme_focus.h_margin or blingbling_theme.h_margin or 2 ,
											v_margin = tagslist_theme_focus.v_margin or blingbling_theme.v_margin or 2,
											rounded_size = tagslist_theme_focus.rounded_size or blingbling_theme.rounded_size or 0,
											font_size= tagslist_theme_focus.font_size or  9,
											font = tagslist_theme_focus.font or "sans"
											},
						urgent = { background_color = tagslist_theme_urgent.background_color or  beautiful.taglist_bg_urgent or beautiful.bg_urgent or beautiful.taglist_bg_focus or beautiful.bg_focus,
											text_background_color = tagslist_theme_urgent.text_background_color or  "#00000000",
											text_color = tagslist_theme_urgent.text_color or  beautiful.taglist_fg_urgent or beautiful.fg_urgent or beautiful.taglist_fg_focus or beautiful.fg_focus,
											h_margin = blingbling_theme.h_margin or 2 ,
											v_margin = blingbling_theme.v_margin or 2,
											rounded_size = tagslist_theme_urgent.rounded_size or  blingbling_theme.rounded_size or 0,
											font_size= tagslist_theme_urgent.font_size or   9,
											font = tagslist_theme_urgent.font or  "sans"
											},
						occupied={background_color = tagslist_theme_occupied.background_color or  beautiful.taglist_bg_occupied or beautiful.bg_occupied or beautiful.taglist_bg_focus or beautiful.bg_focus,
											text_background_color = tagslist_theme_occupied.text_background_color or "#00000000",
											text_color = tagslist_theme_occupied.text_color or beautiful.fg_occupied or beautiful.fg_occupied or beautiful.taglist_fg_focus or beautiful.fg_focus,
											h_margin = blingbling_theme.h_margin or 2 ,
											v_margin = blingbling_theme.v_margin or 2,
											rounded_size = tagslist_theme_occupied.rounded_size or blingbling_theme.rounded_size or 0,
											font_size= tagslist_theme_occupied.font_size or 9,
											font = tagslist_theme_occupied.font or "sans"
											}
						};
	--theme values for calendar
	calendar = {
							days_of_month_widget_style = {
								background_color = calendar_theme_days_of_month_widget_style.background_color or beautiful.bg_normal,
								text_background_color = calendar_theme_days_of_month_widget_style.text_background_color or beautiful.bg_normal,
								text_color = calendar_theme_days_of_month_widget_style.text_color or beautiful.fg_normal,
								h_margin = calendar_theme_days_of_month_widget_style.h_margin or blingbling_theme.h_margin or 2, 
								v_margin = calendar_theme_days_of_month_widget_style.v_margin or blingbling_theme.v_margin or 2,
								rounded_size = calendar_theme_days_of_month_widget_style.rounded_size or blingbling_theme.rounded_size or 0,
								font_size= calendar_theme_days_of_month_widget_style.font_size or 9,
								font = calendar_theme_days_of_month_widget_style.font or "sans"
							},
							prev_next_widget_style = {
								background_color = calendar_theme_prev_next_widget_style.background_color or beautiful.bg_normal,
								text_background_color = calendar_theme_prev_next_widget_style.text_background_color or beautiful.bg_normal,
								text_color = calendar_theme_prev_next_widget_style.text_color or beautiful.fg_normal,
								h_margin = calendar_theme_prev_next_widget_style.h_margin or blingbling_theme.h_margin or 2, 
								v_margin = calendar_theme_prev_next_widget_style.v_margin or blingbling_theme.v_margin or 2,
								rounded_size = calendar_theme_prev_next_widget_style.rounded_size or blingbling_theme.rounded_size or 0,
								font_size= calendar_theme_prev_next_widget_style.font_size or 9,
								font = calendar_theme_prev_next_widget_style.font or "sans"
							},
							current_date_widget_style = {
								background_color = calendar_theme_current_date_widget_style.background_color or beautiful.bg_normal,
								text_background_color = calendar_theme_current_date_widget_style.text_background_color or beautiful.bg_normal,
								text_color = calendar_theme_current_date_widget_style.text_color or beautiful.fg_normal,
								h_margin = calendar_theme_current_date_widget_style.h_margin or blingbling_theme.h_margin or 2, 
								v_margin = calendar_theme_current_date_widget_style.v_margin or blingbling_theme.v_margin or 2,
								rounded_size = calendar_theme_current_date_widget_style.rounded_size or blingbling_theme.rounded_size or 0,
								font_size= calendar_theme_current_date_widget_style.font_size or 9,
								font = calendar_theme_current_date_widget_style.font or "sans"
							},
							days_of_week_widget_style = {
								background_color = calendar_theme_days_of_week_widget_style.background_color or beautiful.bg_normal,
								text_background_color = calendar_theme_days_of_week_widget_style.text_background_color or beautiful.bg_normal,
								text_color = calendar_theme_days_of_week_widget_style.text_color or beautiful.fg_normal,
								h_margin = calendar_theme_days_of_week_widget_style.h_margin or blingbling_theme.h_margin or 2, 
								v_margin = calendar_theme_days_of_week_widget_style.v_margin or blingbling_theme.v_margin or 2,
								rounded_size = calendar_theme_days_of_week_widget_style.rounded_size or blingbling_theme.rounded_size or 0,
								font_size= calendar_theme_days_of_week_widget_style.font_size or 9,
								font = calendar_theme_days_of_week_widget_style.font or "sans"
							},
							weeks_number_widget_style = {
								background_color = calendar_theme_weeks_number_widget_style.background_color or beautiful.bg_normal,
								text_background_color = calendar_theme_weeks_number_widget_style.text_background_color or beautiful.bg_normal,
								text_color = calendar_theme_weeks_number_widget_style.text_color or beautiful.fg_normal,
								h_margin = calendar_theme_weeks_number_widget_style.h_margin or blingbling_theme.h_margin or 2, 
								v_margin = calendar_theme_weeks_number_widget_style.v_margin or blingbling_theme.v_margin or 2,
								rounded_size = calendar_theme_weeks_number_widget_style.rounded_size or blingbling_theme.rounded_size or 0,
								font_size= calendar_theme_weeks_number_widget_style.font_size or 9,
								font = calendar_theme_weeks_number_widget_style.font or "sans"
							},
							corner_widget_style = {
								background_color = calendar_theme_corner_widget_style.background_color or beautiful.bg_normal,
								text_background_color = calendar_theme_corner_widget_style.text_background_color or beautiful.bg_normal,
								text_color = calendar_theme_corner_widget_style.text_color or beautiful.fg_normal,
								h_margin = calendar_theme_corner_widget_style.h_margin or blingbling_theme.h_margin or 2, 
								v_margin = calendar_theme_corner_widget_style.v_margin or blingbling_theme.v_margin or 2,
								rounded_size = calendar_theme_corner_widget_style.rounded_size or blingbling_theme.rounded_size or 0,
								font_size= calendar_theme_corner_widget_style.font_size or 9,
								font = calendar_theme_corner_widget_style.font or "sans"
							},
							current_day_widget_style = {
								background_color = calendar_theme_current_day_widget_style.background_color or beautiful.bg_normal,
								text_background_color = calendar_theme_current_day_widget_style.text_background_color or beautiful.bg_normal,
								text_color = calendar_theme_current_day_widget_style.text_color or beautiful.fg_normal,
								h_margin = calendar_theme_current_day_widget_style.h_margin or blingbling_theme.h_margin or 2, 
								v_margin = calendar_theme_current_day_widget_style.v_margin or blingbling_theme.v_margin or 2,
								rounded_size = calendar_theme_current_day_widget_style.rounded_size or blingbling_theme.rounded_size or 0,
								font_size= calendar_theme_current_day_widget_style.font_size or 9,
								font = calendar_theme_current_day_widget_style.font or "sans"
							},
							focus_widget_style = {
								background_color = calendar_theme_focus_widget_style.background_color or beautiful.bg_normal,
								text_background_color = calendar_theme_focus_widget_style.text_background_color or beautiful.bg_normal,
								text_color = calendar_theme_focus_widget_style.text_color or beautiful.fg_normal,
								h_margin = calendar_theme_focus_widget_style.h_margin or blingbling_theme.h_margin or 2, 
								v_margin = calendar_theme_focus_widget_style.v_margin or blingbling_theme.v_margin or 2,
								rounded_size = calendar_theme_focus_widget_style.rounded_size or blingbling_theme.rounded_size or 0,
								font_size= calendar_theme_focus_widget_style.font_size or 9,
								font = calendar_theme_focus_widget_style.font or "sans"
							},
							info_cell_style = {
								background_color = calendar_theme_info_cell_style.background_color or beautiful.bg_normal,
								text_background_color = calendar_theme_info_cell_style.text_background_color or beautiful.bg_normal,
								text_color = calendar_theme_info_cell_style.text_color or beautiful.fg_normal,
								h_margin = calendar_theme_info_cell_style.h_margin or blingbling_theme.h_margin or 2, 
								v_margin = calendar_theme_info_cell_style.v_margin or blingbling_theme.v_margin or 2,
								rounded_size = calendar_theme_info_cell_style.rounded_size or blingbling_theme.rounded_size or 0,
								font_size= calendar_theme_info_cell_style.font_size or 9,
								font = calendar_theme_info_cell_style.font or "sans"
							},
						};
  init = init
}
