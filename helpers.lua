-- @author cedlemo 
local naughty= require("naughty")
local lgi = require("lgi")
local cairo = lgi.cairo
local string = require("string")
local os = require('os')
local awful = require('awful')
local wibox = require('wibox')
local math = math
local table = table
local print = print
---Functions used in blingbling.
--@module blingbling.helpers

local helpers={}

---Display values of variables in an awesome popup.
--Each variables in vars is separated by a "|"
--@param vars a table of variable
function helpers.dbg(vars)
  local text = ""
  for i=1, #vars do text = text .. vars[i] .. " | " end
  naughty.notify({ text = text, timeout = 15 })
end

---Convert an hexadecimal color to rgba color.
--It convert a string variable "#rrggbb" or "#rrggbbaa" (with r,g,b and a which are hexadecimal value) to r, g, b a=1 or r,g,b,a (with r,g,b,a floated value from 0 to 1.
--The function returns 4 variables.
--@param my_color a string "#rrggbb" or "#rrggbbaa"
function helpers.hexadecimal_to_rgba_percent(my_color)
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

---Get red green blue value in parameters and return hexadecimal string
function helpers.rgb(red, green, blue)
	if type(red) == "number" or type(green) == "number" or type(blue) == "number" then
		return "#"..string.format("%02x",red)..string.format("%02x",green)..string.format("%02x",blue)
	else
	  return nil
	end
end

---Get red green blue and alpha value in parameters and return hexadecimal string.
function helpers.rgba(red, green, blue, alpha)
	if type(red) == "number" or type(green) == "number" or type(blue) == "number" or type(alpha) == "number" then
		return "#"..string.format("%02x",red)..string.format("%02x",green)..string.format("%02x",blue)..string.format("%02x",alpha * 255)
	else
		return nil
	end
end

---Check if an hexadecimal color is fully transparent.
--Returns true or false
--@param my_color a string "#rrggbb" or "#rrggbbaa"
function helpers.is_transparent(my_color)
  --check if color is a valid hex color else return white
  if string.find(my_color,"#[0-f][0-f][0-f][0-f][0-f]") then
  --delete #
    local my_color=string.gsub(my_color,"^#","")
    if string.sub(my_color,7,8) == "" then
      return false
    else
      local alpha=string.format("%d", "0x"..string.sub(my_color,7,8))

      if alpha/1 == 0 then
        return true
      else
        return false
      end
    end
  else
    return false
   end
end
---Split string in different parts which are returned in a table. The delimiter of each part is a pattern given in argument.
--@param str the string to split
--@param pat the pattern delimiter
function helpers.split(str, pat)
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

---Draw tiles in a cairo context.
--@param cr a cairo context.
--@param height the height of the surface on which we want tiles
--@param v_margin value used to define top margin and/or bottom margin (tiles are not drawn on the margins)
--@param width the width of the surface on which we want tiles
--@param h_margin value used to define left margin and/or right margin.
function helpers.draw_background_tiles(cr, height, v_margin , width, h_margin)
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
      cr:rectangle(x,y,4,2)
      y= y-(tiles_height + h_separator)
    end
      y=height -(v_margin + tiles_height + h_rest) 
      x=x-(tiles_width + v_separator)
  end
end

---Draw text on a rectangle which width and height depend on the text width and height.
--@param cr a cairo context already initialised with oocairo.context_create( )
--@param text the text to display
--@param x the x coordinate of the left of the text 
--@param y the y coordinate of the bottom of the text
--@param text_background_color a string "#rrggbb" or "#rrggbbaa" for the rectangle color
--@param text_color a string "#rrggbb" or "#rrggbbaa" for the text color
--@param show_text_centered_on_x a boolean value not mandatory (false by default) if true, x parameter is the coordinate of the middle of the text
--@param show_text_centered_on_y a boolean value not mandatory (false by default) if true, y parameter is the coordinate of the middle of the text
--@param show_text_on_left_of_x a boolean value not mandatory (false by default) if true, x parameter is the right of the text
--@param show_text_on_bottom_of_y a boolean value not mandatory (false by default) if true, y parameter is the top of the text
function helpers.draw_text_and_background(cr, text, x, y, text_background_color, text_color, show_text_centered_on_x, show_text_centered_on_y, show_text_on_left_of_x, show_text_on_bottom_of_y)
    --Text background
    ext=cr:text_extents(text)
    x_modif = 0
    y_modif = 0
    
    if show_text_centered_on_x == true then
      x_modif = ((ext.width + ext.x_bearing) / 2) + ext.x_bearing / 2 
      show_text_on_left_of_x = false
    else
      if show_text_on_left_of_x == true then
        x_modif = ext.width + 2 *ext.x_bearing     
      else 
        x_modif = x_modif
      end
    end
    
    if show_text_centered_on_y == true then
      y_modif = ((ext.height +ext.y_bearing)/2 ) + ext.y_bearing / 2
      show_text_on_left_of_y = false
    else
      if show_text_on_bottom_of_y == true then
        y_modif = ext.height + 2 *ext.y_bearing     
      else 
        y_modif = y_modif
      end
    end
    cr:rectangle(x + ext.x_bearing - x_modif,y + ext.y_bearing - y_modif,ext.width, ext.height)
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(text_background_color)
    cr:set_source_rgba(r,g,b,a)
    cr:fill()
    --Text
    cr:new_path()
    cr:move_to(x-x_modif,y-y_modif)
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(text_color)
    cr:set_source_rgba(r, g, b, a)
    cr:show_text(text)
end

---Drawn one foreground arrow with a background arrow that depend on a value.
--If the value is egal to 0 then the foreground arrow is not drawn.
--@param cr a cairo context already initialised with oocairo.context_create( )
--@param x the x coordinate in the cairo context where the arrow start
--@param y_bottom the bottom corrdinate of the arrows
--@param y_top the top coordinate of the arrows
--@param value a number 
--@param background_arrow_color the color of the background arrow, a string "#rrggbb" or "#rrggbbaa" 
--@param arrow_color the color of the foreground arrow, a string "#rrggbb" or "#rrggbbaa"
--@param arrow_line_color the color of the outline of the foreground arrow , a string "#rrggbb" or "#rrggbbaa"
--@param up boolean value if false draw a down arrow, if true draw a up arrow
function helpers.draw_up_down_arrows(cr,x,y_bottom,y_top,value,background_arrow_color, arrow_color, arrow_line_color,up)
    if up ~= false then 
      invert = 1
    else
      invert= -1
    end
    --Draw the background arrow
    cr:move_to(x,y_bottom)
    cr:line_to(x,y_top )
    cr:line_to(x-(6 * invert), y_top + (6 * invert))
    cr:line_to(x-(3*invert), y_top + (6 * invert))
    cr:line_to(x-(3*invert), y_bottom)
    cr:line_to(x,y_bottom)
    cr:close_path()
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(background_arrow_color)
    cr:set_source_rgba(r, g, b, a)
    cr:fill()
    --Draw the arrow if value is > 0
    if value > 0 then
      cr:move_to(x,y_bottom)
      cr:line_to(x,y_top )
      cr:line_to(x-(6*invert), y_top + (6 * invert))
      cr:line_to(x-(3*invert), y_top + (6 * invert))
      cr:line_to(x-(3*invert), y_bottom)
      cr:line_to(x,y_bottom)
      cr:close_path()
      r,g,b,a = helpers.hexadecimal_to_rgba_percent(arrow_color)
      cr:set_source_rgba(r, g, b, a)
      cr:fill()
      cr:move_to(x,y_bottom)
      cr:line_to(x,y_top )
      cr:line_to(x-(6*invert), y_top + (6 * invert))
      cr:line_to(x-(3*invert), y_top + (6 * invert))
      cr:line_to(x-(3*invert), y_bottom)
      cr:line_to(x,y_bottom)
      cr:close_path()
      r,g,b,a = helpers.hexadecimal_to_rgba_percent(arrow_line_color)
      cr:set_source_rgba(r, g, b, a)
      cr:set_line_width(1)
      cr:stroke()
  end
end

---Draw a vertical bar with gradient color, so it looks like a cylinder, and it's height depends on a value. 
--@param cr a cairo context already initialised with oocairo.context_create( )
--@param h_margin the left and right margin of the bar in the cr 
--@param v_margin the top and bottom margin of the bar in the cr
--@param width the width used to display the left margin, the bar and the right margin
--@param height the height used to display the top margin, the bar and the bottom margin
--@param represent a table {background_bar_color = "#rrggbb" or "#rrggbbaa", color = "#rrggbb" or "#rrggbbaa", value =the value used to calculate the height of the bar}
function helpers.draw_vertical_bar(cr,h_margin,v_margin, width,height, represent)
  x=h_margin
  bar_width=width - 2*h_margin
  bar_height=height - 2*v_margin
  y=v_margin 
  if represent["background_bar_color"] == nil then
    r,g,b,a = helpers.hexadecimal_to_rgba_percent("#000000")
  else
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(represent["background_bar_color"])
  end

  cr:rectangle(x,y,bar_width ,bar_height)
  gradient=cairo.pattern_create_linear(h_margin, height/2, width-h_margin, height/2)
  gradient:add_color_stop_rgba(0, r, g, b, 0.5)
  gradient:add_color_stop_rgba(0.5, 1, 1, 1, 0.5)
  gradient:add_color_stop_rgba(1, r, g, b, 0.5)
  cr:set_source(gradient)
  cr:fill()
  if represent["value"] ~= nil and represent["color"] ~= nil then
    x=h_margin
    bar_width=width - 2*h_margin
    bar_height=height - 2*v_margin
    if represent["invert"] == true then
      y=v_margin 
    else
      y=height - (bar_height*represent["value"] + v_margin )
    end
    cr:rectangle(x,y,bar_width,bar_height*represent["value"])
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(represent["color"])
    gradient=cairo.pattern_create_linear(0, height/2,width, height/2)
    gradient:add_color_stop_rgba(0, r, g, b, 0.1)
    gradient:add_color_stop_rgba(0.5, r, g, b, 1)
    gradient:add_color_stop_rgba(1, r, g, b, 0.1)
    cr:set_source(gradient)
    cr:fill()
  end  
end
---Draw an horizontal bar with gradient color, so it looks like a cylinder, and it's height depends on a value. 
--@param cr a cairo context already initialised with oocairo.context_create( )
--@param h_margin the left and right margin of the bar in the cr 
--@param v_margin the top and bottom margin of the bar in the cr
--@param width the width used to display the left margin, the bar and the right margin
--@param height the height used to display the top margin, the bar and the bottom margin
--@param represent a table {background_bar_color = "#rrggbb" or "#rrggbbaa", color = "#rrggbb" or "#rrggbbaa", value =the value used to calculate the width of the bar}

function helpers.draw_horizontal_bar( cr,h_margin,v_margin, width, height, represent)
  x=h_margin
  bar_width=width - 2*h_margin
  bar_height=height - 2*v_margin
  y=v_margin 
  if represent["background_bar_color"] == nil then
    r,g,b,a = helpers.hexadecimal_to_rgba_percent("#000000")
  else
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(represent["background_bar_color"])
  end
  cr:rectangle(x,y,bar_width,bar_height)
  gradient=cairo.pattern_create_linear( width /2,v_margin , width/2, height - v_margin)
  gradient:add_color_stop_rgba(0, r, g, b, 0.5)
  gradient:add_color_stop_rgba(0.5, 1, 1, 1, 0.5)
  gradient:add_color_stop_rgba(1, r, g, b, 0.5)
  cr:set_source(gradient)
  cr:fill()
  if represent["value"] ~= nil and represent["color"] ~= nil then
    x=h_margin
    bar_width=width - 2*h_margin
    bar_height=height - 2*v_margin
    if represent["invert"] == true then
      x=width - (h_margin + bar_width*represent["value"] )
    else
      x=h_margin
    end
    cr:rectangle(x,y,bar_width*represent["value"],bar_height)
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(represent["color"])
    gradient=cairo.pattern_create_linear(width /2,0 , width/2, height)
    gradient:add_color_stop_rgba(0, r, g, b, 0.1)
    gradient:add_color_stop_rgba(0.5, r, g, b, 1)
    gradient:add_color_stop_rgba(1, r, g, b, 0.1)
    cr:set_source(gradient)
    cr:fill()
  end  
end

---Draw a rectangle width rounded corners.
--@param cr a cairo context already initialised with oocairo.context_create( )
--@param x the x coordinate of the left top corner
--@param y the y corrdinate of the left top corner
--@param width the width of the rectangle
--@param height the height of the rectangle
--@param color a string "#rrggbb" or "#rrggbbaa" for the color of the rectangle
--@param rounded_size a float value from 0 to 1 (0 is no rounded corner) or a table of float value
function helpers.draw_rounded_corners_rectangle(cr,x,y,width, height, color, rounded_size)
--if rounded_size =0 it is a classical rectangle (whooooo!)  
  local height = height
  local width = width
  local x = x
  local y = y
  local rounded_sizes = {}
	
	if type(rounded_size) == "number" then
		rounded_sizes[1]=rounded_size or 0
		rounded_sizes[2]=rounded_size or 0
		rounded_sizes[3]=rounded_size or 0
		rounded_sizes[4]=rounded_size or 0
	elseif type(rounded_size) == "table" then
		rounded_sizes[1]=rounded_size[1] or 0
		rounded_sizes[2]=rounded_size[2] or 0
		rounded_sizes[3]=rounded_size[3] or 0
		rounded_sizes[4]=rounded_size[4] or 0
	end
	
	local rounded_size = rounded_size or 0
  if height > width then
    radius=0.5 * width
  else
    radius=0.5 * height
  end

  PI = 2*math.asin(1)
  r,g,b,a=helpers.hexadecimal_to_rgba_percent(color)
  cr:set_source_rgba(r,g,b,a)
  --top left corner
  cr:arc(x + radius*rounded_sizes[1],y + radius*rounded_sizes[1], radius*rounded_sizes[1],PI, PI * 1.5)
  --top right corner
  cr:arc(width - radius*rounded_sizes[2],y + radius*rounded_sizes[2], radius*rounded_sizes[2],PI*1.5, PI * 2)
  --bottom right corner
  cr:arc(width - radius*rounded_sizes[3],height -  radius*rounded_sizes[3], radius*rounded_sizes[3],PI*0, PI * 0.5)
  --bottom left corner
  cr:arc(x + radius*rounded_sizes[4],height -  radius*rounded_sizes[4], radius*rounded_sizes[4],PI*0.5, PI * 1)
  cr:close_path()
  cr:fill()
end

---Set a rectangle width rounded corners that define the area to draw.
--@param cr a cairo context already initialised with oocairo.context_create( )
--@param x the x coordinate of the left top corner
--@param y the y corrdinate of the left top corner
--@param width the width of the rectangle
--@param height the height of the rectangle
--@param rounded_size a float value from 0 to 1 (0 is no rounded corner)
function helpers.clip_rounded_corners_rectangle(cr,x,y,width, height, rounded_size)
--if rounded_size =0 it is a classical rectangle (whooooo!)  
  local height = height
  local width = width
  local x = x
  local y = y
  local rounded_size = rounded_size or 0.4
  if height > width then
    radius=0.5 * width
  else
    radius=0.5 * height
  end

  PI = 2*math.asin(1)
  --top left corner
  cr:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
  --top right corner
  cr:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI * 2)
  --bottom right corner
  cr:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0, PI * 0.5)
  --bottom left corner
  cr:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
  cr:close_path()
  cr:clip()

end

---Draw a foreground rounded corners rectangle which width depends on a value, and a background rounded corners rectangle.
--@param cr a cairo context already initialised with oocairo.context_create( )
--@param x the x coordinate of the left top corner
--@param y the y corrdinate of the left top corner
--@param width the width of the background rectangle and the maximal width of th foreground rectangle
--@param height the height of the background and the foreground rectangles
--@param background_color a string "#rrggbb" or "#rrggbbaa" for the color of the background rectangle
--@param graph_color a string "#rrggbb" or "#rrggbbaa" for the color of the foreground rectangle
--@param rounded_size a float value from 0 to 1 (0 is no rounded corner)
--@param value_to_represent the percent of the max width used to calculate the width of the foreground rectangle
--@param graph_line_color a string "#rrggbb" or "#rrggbbaa" for the outiline color of the background rectangle
function helpers.draw_rounded_corners_horizontal_graph(cr,x,y,width, height, background_color, graph_color, rounded_size, value_to_represent, graph_line_color)
--if rounded_size =0 it is a classical rectangle (whooooo!)  
  local height = height
  local width = width
  local x = x
  local y = y
  local rounded_size = rounded_size or 0.4
  if height > width then
    radius=0.5 * width
  else
    radius=0.5 * height
  end

  PI = 2*math.asin(1)
  --draw the background
  r,g,b,a=helpers.hexadecimal_to_rgba_percent(background_color)
  cr:set_source_rgba(r,g,b,a)
  --top left corner
  cr:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
  --top right corner
  cr:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI * 2)
  --bottom right corner
  cr:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0, PI * 0.5)
  --bottom left corner
  cr:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
  cr:close_path()
  cr:fill()
  --represent the value
  -- value in 0 -> 1
  --  radius*rounded_size |  width - 2*( radius*rounded) | radius * rounded_size
  --                  |               |                         |
  --                  |      _________|  _______________________|
  --                  |     |           |
  --                  v ____v_________  v
  --                  /|              |\
  --                 | |              | |               (... and yes I don't have a job)
  --                  \|______________|/
  --
  --1 => width/ width
  --limit_2 => width -radius / width
  --limit_1 => radius /width
  value = value_to_represent
  limit_2 = (width -(radius * rounded_size)) / width
  limit_1 = radius* rounded_size /width

  r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_color)
  cr:set_source_rgba(r,g,b,a)
 
  if value <= 1 and value > limit_2 then
    cr:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
    ratio = (value - limit_2) / (1 - limit_2)
    cr:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI *(1.5 +(0.5  * ratio)))
    cr:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*(0.5 - (0.5 * ratio))  , PI * 0.5)
    cr:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
    cr:close_path()
    cr:fill()
  elseif value <= limit_2 and value > limit_1 then
    cr:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
    ratio = value  / limit_2
    cr:line_to(limit_2*width*ratio,y)
    cr:line_to(limit_2*width*ratio,height)
    cr:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
    cr:close_path()
    cr:fill()
  elseif value <= limit_1 and value > 0 then
    ratio = value  / limit_1
    cr:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * (1+ (0.5*ratio)))
    cr:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*(1-(0.5 * ratio)) , PI * 1)
    cr:close_path()
    cr:fill()
  end
  if graph_line_color then
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_line_color)
    cr:set_source_rgba(r,g,b,a)
    cr:set_line_width(1)

    if value <= 1 and value > limit_2 then
      cr:arc(x +1+ radius*rounded_size,y+1 + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
      ratio = (value - limit_2) / (1 - limit_2)
      cr:arc(width-1 - radius*rounded_size,y+1 + radius*rounded_size, radius*rounded_size,PI*1.5, PI *(1.5 +(0.5  * ratio)))
      cr:arc(width-1 - radius*rounded_size,height-1 -  radius*rounded_size, radius*rounded_size,PI*(0.5 - (0.5 * ratio))  , PI * 0.5)
      cr:arc(x+1 + radius*rounded_size,height-1 -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cr:close_path()
      cr:stroke()
    elseif value <= limit_2 and value > limit_1 then
      cr:arc(x +1+ radius*rounded_size,y+1 + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
      ratio = value  / limit_2
      cr:line_to(limit_2*width*ratio -1 ,y +1)
      cr:line_to(limit_2*width*ratio -1 ,height -1 )
      cr:arc(x +1 + radius*rounded_size,height -1 -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cr:close_path()
      cr:stroke()
    elseif value <= limit_1 and value > 0 then
      ratio = value  / limit_1
      cr:arc(x +1 + radius*rounded_size,y +1 + radius*rounded_size, radius*rounded_size,PI, PI * (1+ (0.5*ratio)))
      cr:arc(x +1 + radius*rounded_size,height +1 -  radius*rounded_size, radius*rounded_size,PI*(1-(0.5 * ratio)) , PI * 1)
      cr:close_path()
      cr:stroke()
    end
  end
end

---Draw a foreground rounded corners rectangle which height depends on a value, and a background rounded corners rectangle.
--@param cr a cairo context already initialised with oocairo.context_create( )
--@param x the x coordinate of the left top corner
--@param y the y corrdinate of the left top corner
--@param width the width of the background and the foreground rectangles
--@param height the height of the background rectangle and the maximal height of the foreground rectangle
--@param background_color a string "#rrggbb" or "#rrggbbaa" for the color of the background rectangle
--@param graph_color a string "#rrggbb" or "#rrggbbaa" for the color of the foreground rectangle
--@param rounded_size a float value from 0 to 1 (0 is no rounded corner)
--@param value_to_represent the percent of the max height used to calculate the height of the foreground rectangle
--@param graph_line_color a string "#rrggbb" or "#rrggbbaa" for the outiline color of the background rectangle
function helpers.draw_rounded_corners_vertical_graph(cr,x,y,width, height, background_color, graph_color, rounded_size, value_to_represent, graph_line_color)
--if rounded_size =0 it is a classical rectangle (whooooo!)  
  local height = height
  local width = width
  local x = x
  local y = y
  if rounded_size == nil or rounded_size == 0 then
    --draw the background:
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(background_color)
    cr:set_source_rgba(r,g,b,a)
    cr:move_to(x,y)
    cr:line_to(x,height)
    cr:line_to(width,height)
    cr:line_to(width,y)
    cr:close_path()
    cr:fill()
    --draw the graph:
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_color)
    cr:set_source_rgba(r,g,b,a)
    cr:move_to(x,height)
    cr:line_to(x, height -((height -y)* value_to_represent)  )
    cr:line_to(width,height -((height - y)*value_to_represent) )
    cr:line_to(width,height)
    cr:close_path()
    cr:fill()
    if graph_line_color then
      r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_line_color)
      cr:set_source_rgba(r,g,b,a)
      cr:move_to(x,height)
      cr:line_to(x,height -((height -y)* value_to_represent) )
      cr:line_to(width,height -((height -y)*value_to_represent) )
      cr:line_to(width,height)
      cr:close_path()
      cr:set_line_width(1)
      cr:stroke()
    end
  else
    local rounded_size = rounded_size or 0.4
    if height > width then
      radius=0.5 * width
    else
      radius=0.5 * height
    end

    PI = 2*math.asin(1)
    --draw the background
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(background_color)
    cr:set_source_rgba(r,g,b,a)
    --top left corner
    cr:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
    --top right corner
    cr:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI * 2)
    --bottom right corner
    cr:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0, PI * 0.5)
    --bottom left corner
    cr:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
    cr:close_path()
    cr:fill()
    --represent the value
    -- value in 0 -> 1
    --  radius*rounded_size |  height - 2*( radius*rounded) | radius * rounded_size
    --                  |               |                         |
    --                  |           ____|  _______________________|
    --                  |_______   |      |     
    --                   ___    |  |      |
    --                  /___\ <-   |      |
    --                 |     |     |      |
    --                 |     |<----       |
    --                 |_____|            |
    --                  \___/<------------
    --
    --1 => height/ height
    --limit_2 => height -radius / height
    --limit_1 => radius /height
    value = value_to_represent
    limit_2 = (height -(radius * rounded_size)) / height
    limit_1 = radius* rounded_size /height
    --dbg({value, limit_2, limit_1})
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_color)
    cr:set_source_rgba(r,g,b,a)
 
    if value <= 1 and value > limit_2 then
      ratio = (value - limit_2) / (1 - limit_2)
      cr:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0  , PI * 0.5)
      cr:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cr:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * (1+(0.5* ratio)) )
      cr:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*(2 -(0.5* ratio)), PI *2)
      cr:close_path()
      cr:fill()
    elseif value <= limit_2 and value > limit_1 then
      ratio = value  / limit_2
      cr:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0  , PI * 0.5)
      cr:arc(x + radius*rounded_size,height - radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cr:line_to(x,y + height - (height * ratio*limit_2) )
      cr:line_to(width,y+ height - (height * ratio*limit_2) )
      cr:close_path()
      cr:fill()

    elseif value <= limit_1 and value > 0 then
      ratio = value  / limit_1
      cr:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*(0.5-( 0.5*ratio))  , PI * 0.5)
      cr:arc(x + radius*rounded_size,height - radius*rounded_size, radius*rounded_size,PI*0.5, PI *(0.5+ (0.5*ratio)))
      cr:close_path()
      cr:fill()
    end
    if graph_line_color then
      r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_line_color)
      cr:set_source_rgba(r,g,b,a)
      cr:set_line_width(1)
      if value <= 1 and value > limit_2 then
        ratio = (value - limit_2) / (1 - limit_2)
        cr:arc(width -1 - radius*rounded_size,height -1 -  radius*rounded_size, radius*rounded_size,PI*0  , PI * 0.5)
        cr:arc(x+1 + radius*rounded_size,height -1 -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
        cr:arc(x+1 + radius*rounded_size,y+1 + radius*rounded_size, radius*rounded_size,PI, PI * (1+(0.5* ratio)) )
        cr:arc(width -1 - radius*rounded_size,y+1 + radius*rounded_size, radius*rounded_size,PI*(2 -(0.5* ratio)), PI *2)
        cr:close_path()
        cr:stroke()
      elseif value <= limit_2 and value > limit_1 then
        ratio = value  / limit_2
        cr:arc(width -1 - radius*rounded_size,height -1 -  radius*rounded_size, radius*rounded_size,PI*0  , PI * 0.5)
        cr:arc(x+1 + radius*rounded_size,height -1 - radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cr:line_to(x +1 ,y +1 + height - (height * ratio*limit_2) )
      cr:line_to(width - 1,y +1 + height - (height * ratio*limit_2) )
      cr:close_path()
      cr:stroke()
      elseif value <= limit_1 and value > 0 then
        ratio = value  / limit_1
        cr:arc(width -1 - radius*rounded_size,height -1 -  radius*rounded_size, radius*rounded_size,PI*(0.5-( 0.5*ratio))  , PI * 0.5)
        cr:arc(x +1 + radius*rounded_size,height -1 - radius*rounded_size, radius*rounded_size,PI*0.5, PI *(0.5+ (0.5*ratio)))
        cr:close_path()
        cr:stroke()
      end
    end
  end
end

---Generate a text in front of a centered rectangle with rounded corners (or not) in  a cairo context.
--It returns a table ={ width = the width of the image, height = the height of the image} 
--@param cr a cairo context already initialised with oocairo.context_create( )
--@param width the width of the widget
--@param height the height of the widget
--@param text the text to display
--@param padding the left/right/top/bottom padding used to center the text in the background rectangle
--@param background_color a string "#rrggbb" or "#rrggbbaa" for the color of the background rectangle
--@param text_color a string "#rrggbb" or "#rrggbbaa" for the color of the text
--@param font_size define the size of the font
--@param rounded_size a float value from 0 to 1 (0 is no rounded corner)
--@param border a color as a string "#rrggbb" or "#rrggbbaa"
function helpers.generate_rounded_rectangle_with_text(cr, width, height, text, padding, background_color, text_color, font_size, rounded_size, border)
  local data={}
  local padding = padding or 2
  --find the height and width of the image:
  cr:set_font_size(font_size)
  local ext = cr:text_extents(text)
  
  data.height = (font_size + 2* padding) > height and (font_size + 2* padding) or height
  data.width = (ext.width +ext.x_bearing*2 + 2*padding) > width and (ext.width +ext.x_bearing *2  + 2*padding) or width
  
  --draw the background
  draw_rounded_corners_rectangle(cr,0,0,data.width, data.height, background_color, rounded_size, border)
  
  --draw the text
  cr:move_to((data.width/2) -((ext.width+ext.x_bearing*2)/2), (data.height)/2 + (font_size/2))
  r,g,b,a=helpers.hexadecimal_to_rgba_percent(text_color)
  cr:set_font_size(font_size)
  cr:set_source_rgba(r,g,b,a)
  cr:show_text(text)
  
  return data
end

---Draw a rectangular triangle filled with given color
--@param cr cairo context
--@param first  point coordinates {x= 1.0, y = 2.0}
--@param second point coordinates {x= 1.0, y = 2.0}
--@param third  point coordinates {x= 1.0, y = 2.0}
--@param color  a color as a string "#rrggbb" or "#rrggbbaa"
function helpers.draw_triangle(cr, first, second, third, color)
  local r,g,b,a = helpers.hexadecimal_to_rgba_percent(color)
  cr:new_path()
  cr:set_source_rgba(r,g,b,a)
  cr:move_to(first.x, first.y)
  cr:line_to(second.x, second.y)
  cr:line_to(third.x, third.y)
  cr:close_path()
  cr:fill()
end

--- Draw a rectangular triangular outline of the given color
--@param cr cairo context
--@param first  point coordinates {x= 1.0, y = 2.0}
--@param second point coordinates {x= 1.0, y = 2.0}
--@param third  point coordinates {x= 1.0, y = 2.0}
--@param color  a color as a string "#rrggbb" or "#rrggbbaa"
function helpers.draw_triangle_outline(cr, first, second, third, color)
  local r,g,b,a = helpers.hexadecimal_to_rgba_percent(color)
  cr:new_path()
  cr:set_source_rgba(r,g,b,a)
  cr:move_to(first.x, first.y)
  cr:line_to(second.x, second.y)
  cr:line_to(third.x, third.y)
  cr:close_path()
  cr:set_antialias("subpixel") 
  cr:set_line_width(1)
  cr:stroke()
end
--- Compute the width of each bar in a graph
--It returns the width of the bar and a value
--that corresponds to the remaing space divided
--by 2
--@param nb_bars the number of bars
--@param width the width of the graph
--@param sep the size between two bars
function compute_bar_width(nb_bars, width, sep)
  local bar_width = 0
  local h_rest = 0
  local total_sep = (nb_bars - 1) * sep
  bar_width=math.floor ((width - total_sep) / nb_bars)
  h_rest = width - (total_sep + nb_bars * bar_width)
  --center the graph according to h_rest (2, 3 or 4)
  if h_rest ==2 or h_rest == 3 then 
    h_rest = 1
  end
  if h_rest == 4 then
    h_rest = 2
  end
  return bar_width, h_rest
end
function helpers.draw_triangle_using_bars(cr, width, height, h_margin, v_margin, color)
  local nb_bars=5
  local bar_separator = 2
  local bar_width, h_rest = compute_bar_width(nb_bars, width - 2*h_margin, bar_separator)
  x=h_margin+h_rest
  y=height - v_margin
  for i=1, nb_bars do
    cr:rectangle(x,y-((0.2*i)*(height - 2*v_margin)),bar_width,((0.2*i)*(height - 2*v_margin)))
    x=x+(bar_width + bar_separator)
  end

  local r,g,b,a=helpers.hexadecimal_to_rgba_percent(color)
  cr:set_source_rgba(r, g, b, a)
  cr:fill()
end
--- Display a value using bars or parts of bar in a triangular form
--@param cr cairo context
--@param width width of the graph
--@param height height of the graph
--@param h_margin horizontal space left at left and right of the graph
--@param v_margin vertical space left at top and bottom of the graph
--@param color the color of the graph
--@param value to represent
function helpers.draw_triangle_graph_using_bars(cr, width, height, h_margin, v_margin, color, value)
  local nb_bars=5
  local bar_separator = 2
  local bar_width, h_rest = compute_bar_width(nb_bars, width - 2*h_margin, bar_separator)
  if value > 0 then
    local ranges={0,0.2,0.4,0.6,0.8,1,1.2}
    nb_bars=0
    for i,  limite in ipairs(ranges) do
      if value < limite then
        nb_bar = i-1
        break
      end
    end
    x=h_margin + h_rest
    y=height - v_margin
    for i=1, nb_bar do
      if i ~= nb_bar then
        cr:rectangle(x,y-((0.2*i)*(height - 2*v_margin)),bar_width,(0.2*i)*(height - 2*v_margin))
        x=x+(bar_width + bar_separator)
      else
        val_to_display =value - ((nb_bar-1) * 0.2)

        cr:rectangle(x,y-((0.2*i)*(height - 2*v_margin)),bar_width * (val_to_display/0.2),(0.2*i)*(height - 2*v_margin))
      end
    end
    
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(color)
    cr:set_source_rgba(r, g, b, a)

    cr:fill()
  end
end
---Remove an element from  a table using key.
--@param hash the table
--@param key the key to remove
function helpers.hash_remove(hash,key)
  local element = hash[key]
  hash[key] = nil
  return element
end

---Functions for date and calendar
local function is_leap_year(year)
  return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

local days_in_m = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
---Get the number of days in a given month of a year.
--iT returns a number
--@param month the month we focus on ( 1 to 12 )
--@param year a number YYYY used to check if it's a leap year.
function helpers.get_days_in_month(month, year)
  if month == 2 and is_leap_year(year) then
    return 29
  else
    return days_in_m[month]
  end
end

---Find the weeks numbers of a given month.
--Implementation as per the ISO 8601 definition (http://en.wikipedia.org/wiki/ISO_week_date)
--Fully compatible with original, returns table with 6 week numbers
--@param month the month
--@param year the year
function helpers.get_ISO8601_weeks_number_of_month(month, year)
  local wday = os.date("*t", os.time{year=year,month=month,day=1}).wday-1
  wday = wday == 0 and 7 or wday
  local yday = os.date("*t", os.time{year=year,month=month,day=1}).yday
  local nweeks = is_leap_year(month == 12 and year+1 or year) and 53 or 52 -- Make a correction for leap weeks!
  local week = math.floor((yday-wday+10)/7) -- First week of the month
  if (week < 1) then week = nweeks+week end
  if (week > nweeks) then week = week-nweeks end    
  local t = {week}
  for i = 1, 5 do -- Calculate the next 5 weeks, correct where necessary
    t[i+1] = ((week+i) > nweeks and (week+i)-nweeks or week+i)
  end
  return t
end
---Get the number of cpu cores
--@return a number
function helpers.get_nb_cores()
  local f=io.open("/proc/stat")
  local nb=0
  for line in f:lines() do
    if string.find(line,"cpu%d+%s") then nb = nb + 1 end
  end
  return nb
end
---Get the cpu name
--@return a string describing the cpu
function helpers.get_cpu_name()
  local file = io.open("/proc/cpuinfo")
  for line in file:lines() do
    local cpu = string.match(line,"model%sname%s:%s*(.*)")
    if cpu then return cpu end
  end
end
---Get all the currently mounted devices
--@return an indexed table from 1 to n, where each element is a table with the "mnt", and "dev" key.
function helpers.get_mounted_devices()
  local buf = awful.util.pread("mount")
  buf = helpers.split(buf, "\n")
  local devices = {}
  local n = 0 --devices will be an array of table {dev, mnt} (allowing to keep an alphabetical order on /dev/sxxx
  for i=1,#buf do
    local dev, mnt = string.match(buf[i],"(/dev/[^%s]*)%s+on%s+([^%s]+).*")
    if dev and mnt then
      n=n+1
      devices[n]={mnt=mnt, dev=dev}
    end
  end
  table.sort(devices, function(a,b) return a.dev < b.dev end)
  return devices
end
---Get the total amount of RAM in kb
--@return a number
function helpers.get_total_mem_in_kb()
  local file = io.open("/proc/meminfo")
  for line in file:lines() do
    local mem = string.match(line,"MemTotal:%s*(%d*)")
    if mem then return mem end
  end
end
---Get the input device names
--@return an table with "keyboard" and "mouse" keys
function helpers.get_input_devices()
  local file = io.open("/proc/bus/input/devices")
  local devices={}
  local i= 0
  for line in file:lines() do
    local name, ev, handlers = nil
    if string.match(line,"I:%s") then
      devices[#devices+1]={}
    end
    name=string.match(line,"N:%sName=\"(.*)\"")
    if (name) then
      devices[#devices].name=name
    end
    ev=string.match(line,"B:%sEV=(.*)")
    if (ev) then
      devices[#devices].ev=ev
    end
    handlers=string.match(line,"H:%sHandlers=(.*)")
    if (handlers) then
      devices[#devices].handlers=handlers
    end
  end
  local inputs={}
  for _,device in ipairs(devices) do
    if string.match(device.ev, "120013") then
      inputs.keyboard= device.name
    end
    if device.handlers and string.match(device.handlers, "mouse") then
      inputs.mouse=device.name
    end
  end
  file:close()
  return inputs
end
---Get the current graphic card
--@return a string
function helpers.get_graphic_card()
  local buf = awful.util.pread("lspci | grep VGA")
  local graph_card = string.match(buf,"[^%s]*%s+VGA%s+compatible%s+controller:%s+(.*)")
  return graph_card
end
--- Get OS related informations from /etc/os-release
--@return a key/value table
function helpers.get_os_release_informations()
  local file = io.open("/etc/os-release")
  local infos = {}
  for line in file:lines() do
    local key,value = string.match(line,"([^%s]+)=%s*\"?([^\"]*)\"?")
    if key and value then
      infos[#infos +1]={key=key,value = value}
    end
  end
  return infos
end
--- Function used in order to have a tasklist with icons only
--The classical usage of it is:
--awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons,nil,icons_only_tasklist)
function helpers.icons_only_tasklist(w, buttons, label, data, objects)
    w:reset()
    local l = wibox.layout.fixed.horizontal()
    for i, o in ipairs(objects) do
        local cache = data[o]
        if cache then
            ib = cache.ib
        else
            local common = require("awful.widget.common")
            ib = wibox.widget.imagebox()
            ib:buttons(common.create_buttons(buttons, o))

            data[o] = {
                ib = ib
            }
        end
        local text, bg, bg_image, icon = label(o)
        ib:set_image(icon)
    l:add(ib)
   end
   w:add(l)
end

---Function used in widgets in order to create a local table of 
--all the widget properties which are a mix between the properties
--provided by the user trought the widget interface, or the properties
--defined by superproperties
--@param properties a table with the names of all the properties
--@param data the data table of the module that references all the same widgets
--@param graph the widget itself
--@param superproperties the table of the superporperties
function helpers.load_properties( properties, data, graph, superproperties)
  local props = {}
  for _i, prop in ipairs(properties) do
    props[prop] = data[graph][prop] or superproperties[prop]
    if prop == "v_margin" then
      if data[graph].v_margin and data[graph].v_margin <= data[graph].height/4 then
        props.v_margin = data[graph].v_margin
      end
    end
    if prop == "h_margin" then
      if data[graph].h_margin and data[graph].h_margin <= data[graph].height/3 then
        props.h_margin = data[graph].h_margin
      end
    end
  end
  return props
end

return helpers
