local naughty= require("naughty")
local string = require("string")
local math = math
local table = table
module("blingbling.helpers")

function dbg(vars)
  local text = ""
  for i=1, #vars do text = text .. vars[i] .. " | " end
  naughty.notify({ text = text, timeout = 15 })
end

function hexadecimal_to_rgba_percent(my_color)
  --check if color is a valid hex color else return white
  if string.find(my_color,"#[0-f][0-f][0-f][0-f][0-f]") then
  --delete #
    my_color=string.gsub(my_color,"^#","")
    r=string.format("%d", "0x"..string.sub(my_color,1,2))
    v=string.format("%d", "0x"..string.sub(my_color,3,4))
    b=string.format("%d", "0x"..string.sub(my_color,5,6))
    if string.sub(my_color,7,8) == "" then
      a=255
    else
      a=string.format("%d", "0x"..string.sub(my_color,7,8))
    end
  else
    r=255
    v=255
    b=255
    a=255
   end
  return r/255,v/255,b/255,a/255
end

function split(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = string.find(str,fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t,cap)
    end
    last_end = e+1
    s, e, cap = string.find(str,fpat, last_end)
  end
  if last_end <= #str then
    cap = string.sub(str,last_end)
    table.insert(t, cap)
  end
  return t
end
function draw_background_tiles(cairo_context, height, v_margin , width, h_margin)
--tiles: width 4 px height 2px horizontal separator=1 px vertical separator=2px
--			v_separator
--		 _______\ /_______
--		|_______| |_______| 
--	 	 _______   _______  <--h_separator
--		|_______| |_______|	<--tiles_height
--		/        \
--		tiles_width
   
  tiles_width=4
  tiles_height=2
  h_separator=1
  v_separator=2
--find nb max horizontal lignes we can display with 2 pix squarre and 1 px separator (3px)
  local max_line=math.floor((height - v_margin*2) /(tiles_height+h_separator))
  --what to do with the rest of the height:
  local h_rest=(height - v_margin*2) - (max_line * (tiles_height+h_separator))
  if h_rest >= (tiles_height) then 
     max_line= max_line + 1
     h_rest= h_rest - tiles_height
  end
  if h_rest > 0 then
	  h_rest =h_rest / 2
  end	
  --find nb columns we can draw with tile of 4px width and 2 px separator (6px) and center them horizontaly
  local max_column=math.floor((width - h_margin*2)/6)
  local v_rest=(width- h_margin*2)-(max_column*( tiles_width + v_separator))
  if v_rest >= (tiles_width) then 
    max_column= max_column + 1
    v_rest= v_rest - tiles_width
  end
  if v_rest > 0 then
	  h_rest =h_rest / 2
  end	
  
  x=width-(tiles_width + v_rest)
  y=height -(v_margin +tiles_height + h_rest) 
  for i=1,max_column do
    for j=1,max_line do
      cairo_context:rectangle(x,y,4,2)
      y= y-(tiles_height + h_separator)
    end
      y=height -(v_margin + tiles_height + h_rest) 
      x=x-(tiles_width + v_separator)
  end
end

function draw_text_and_background(cairo_context, text, x, y, background_text_color, text_color, show_text_on_left_of_x, show_text_on_bottom_of_y)
    --Text background
    ext=cairo_context:text_extents(text)
    if show_text_on_left_of_x == true then
      x_modif = ext.width + 2 *ext.x_bearing     
    else 
      x_modif = 0
    end
    if show_text_on_bottom_of_y == true then
      y_modif = ext.height + 2 *ext.y_bearing     
    else 
      y_modif = 0
    end
    cairo_context:rectangle(x + ext.x_bearing - x_modif,y + ext.y_bearing - y_modif,ext.width, ext.height)
    r,g,b,a=hexadecimal_to_rgba_percent(background_text_color)
    cairo_context:set_source_rgba(r,g,b,a)
    cairo_context:fill()
    --Text
    cairo_context:new_path()
    cairo_context:move_to(x-x_modif,y-y_modif)
    r,g,b,a=hexadecimal_to_rgba_percent(text_color)
    cairo_context:set_source_rgba(r, g, b, a)
    cairo_context:show_text(text)
end

function draw_up_down_arrows(cairo_context,x,y_bottom,y_top,value,background_arrow_color, arrow_color, arrow_line_color,up)
    if up ~= false then 
      invert = 1
    else
      invert= -1
    end
    --Draw the background arrow
    cairo_context:move_to(x,y_bottom)
    cairo_context:line_to(x,y_top )
    cairo_context:line_to(x-(6 * invert), y_top + (6 * invert))
    cairo_context:line_to(x-(3*invert), y_top + (6 * invert))
    cairo_context:line_to(x-(3*invert), y_bottom)
    cairo_context:line_to(x,y_bottom)
    cairo_context:close_path()
    cairo_context:set_source_rgba(0, 0, 0, 0.3)
    cairo_context:fill()
    --Draw the arrow if value is > 0
    if value > 0 then
      cairo_context:move_to(x,y_bottom)
      cairo_context:line_to(x,y_top )
      cairo_context:line_to(x-(6*invert), y_top + (6 * invert))
      cairo_context:line_to(x-(3*invert), y_top + (6 * invert))
      cairo_context:line_to(x-(3*invert), y_bottom)
      cairo_context:line_to(x,y_bottom)
      cairo_context:close_path()
      cairo_context:set_source_rgba(0.5, 0.7, 0.1, 0.7)
      cairo_context:fill()
      cairo_context:move_to(x,y_bottom)
      cairo_context:line_to(x,y_top )
      cairo_context:line_to(x-(6*invert), y_top + (6 * invert))
      cairo_context:line_to(x-(3*invert), y_top + (6 * invert))
      cairo_context:line_to(x-(3*invert), y_bottom)
      cairo_context:line_to(x,y_bottom)
      cairo_context:close_path()
      cairo_context:set_source_rgba(0.5, 0.7, 0.1, 0.7)
      cairo_context:set_line_width(1)
      cairo_context:stroke()
  end
end
