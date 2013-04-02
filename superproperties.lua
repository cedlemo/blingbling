---Define default theme values   
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
  background_text_color = blingbling_theme.background_text_color or "#00000066" ;
  background_text_border = blingbling_theme.background_text_border or "#ffffff";
--theme values for popups module:
  htop_title_color = blingbling_theme.htop_title_color or "#7fb219";
  htop_user_color = blingbling_theme.htop_user_color or "#7fb219";
  htop_root_color = blingbling_theme.htop_root_color or "#000000";
  netstat_title_color = blingbling_theme.netstat_title_color or "#7fb219";
  nestat_established_color = blingbling_theme.nestat_established_color or "#7fb219";
  netstat_listen_color = blingbling_theme.netstat_listen_color or "#f38915";
--theme value for value_text_box
  padding = blingbling_theme.padding or 2;
  menu_width = blingbling_theme.menu_width or 300;
}
