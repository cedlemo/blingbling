--@author cedlemo
---Centralize theming values for blingbling widgets
--Users can create a theme.blingbling table in theirs theme.lua and defines some values for theirs widgets.
--@module blingbling.superproperties
local beautiful = require("beautiful")
local blingbling_theme= (type(beautiful.blingbling) == "table") and beautiful.blingbling  or {}

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
  text_color= blingbling_theme.text_color or "ffffff" ;
  font_size= blingbling_theme.font_size or 9 ;
  font = blingbling_theme.font or "sans";
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
--theme values for tagslist	
	tagslist=	{
						normal ={ background_color = blingbling_theme.tagslist.normal.background_color or beautiful.bg_normal,
											text_background_color = blingbling_theme.tagslist.normal.text_background_color or "#00000000",
											text_color = blingbling_theme.tagslist.normal.text_color or beautiful.fg_normal,
											h_margin = blingbling_theme.tagslist.normal.h_margin or blingbling_theme.h_margin or 2 ,
											v_margin = blingbling_theme.tagslist.normal.v_margin or blingbling_theme.v_margin or 2,
											rounded_size = blingbling_theme.tagslist.normal.rounded_size or blingbling_theme.rounded_size or 0,
											font_size= blingbling_theme.tagslist.normal.font_size or 9,
											font = blingbling_theme.tagslist.normal.font or "sans"
											},
						focus = { background_color = blingbling_theme.tagslist.focus.background_color or beautiful.taglist_bg_focus or beautiful.bg_focus,
											text_background_color = blingbling_theme.tagslist.focus.text_background_color or "#00000000",
											text_color = blingbling_theme.tagslist.focus.text_color or beautiful.taglist_fg_focus or beautiful.fg_focus,
											h_margin = blingbling_theme.tagslist.focus.h_margin or blingbling_theme.h_margin or 2 ,
											v_margin = blingbling_theme.tagslist.focus.v_margin or blingbling_theme.v_margin or 2,
											rounded_size = blingbling_theme.tagslist.focus.rounded_size or blingbling_theme.rounded_size or 0,
											font_size= blingbling_theme.tagslist.focus.font_size or  9,
											font = blingbling_theme.tagslist.normal.font or "sans"
											},
						urgent = { background_color = blingbling_theme.tagslist.urgent.background_color or  beautiful.taglist_bg_urgent or beautiful.bg_urgent or beautiful.taglist_bg_focus or beautiful.bg_focus,
											text_background_color = blingbling_theme.tagslist.urgent.text_background_color or  "#00000000",
											text_color = blingbling_theme.tagslist.urgent.text_color or  beautiful.taglist_fg_urgent or beautiful.fg_urgent or beautiful.taglist_fg_focus or beautiful.fg_focus,
											h_margin = blingbling_theme.h_margin or 2 ,
											v_margin = blingbling_theme.v_margin or 2,
											rounded_size = blingbling_theme.tagslist.urgent.rounded_size or  blingbling_theme.rounded_size or 0,
											font_size= blingbling_theme.tagslist.urgent.font_size or   9,
											font = blingbling_theme.tagslist.urgent.font or  "sans"
											},
						occupied={background_color = blingbling_theme.tagslist.occupied.background_color or  beautiful.taglist_bg_occupied or beautiful.bg_occupied or beautiful.taglist_bg_focus or beautiful.bg_focus,
											text_background_color = blingbling_theme.tagslist.occupied.text_background_color or "#00000000",
											text_color = blingbling_theme.tagslist.occupied.text_color or beautiful.fg_occupied or beautiful.fg_occupied or beautiful.taglist_fg_focus or beautiful.fg_focus,
											h_margin = blingbling_theme.h_margin or 2 ,
											v_margin = blingbling_theme.v_margin or 2,
											rounded_size = blingbling_theme.tagslist.occupied.rounded_size or blingbling_theme.rounded_size or 0,
											font_size= blingbling_theme.tagslist.occupied.font_size or 9,
											font = blingbling_theme.tagslist.occupied.font or "sans"
											}
						}
}
