local helpers =require("blingbling.helpers")
local string = require("string")
local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local type=type
local cairo = require("oocairo")
local capi = { image = image, widget = widget }
local layout = require("awful.widget.layout")

module("blingbling.progress_graph")

local data = setmetatable({}, { __mode = "k" })

local properties = { "width", "height", "v_margin", "h_margin", "background_color","rounded_size", "filled", "filled_color", "tiles", "tiles_color", "graph_color", "graph_line_color","show_text", "text_color", "background_text_color" ,"label", "font_size","horizontal"}

local function update(p_graph)
  
  local p_graph_surface=cairo.image_surface_create("argb32",data[p_graph].width, data[p_graph].height)
  local p_graph_context = cairo.context_create(p_graph_surface)
  
  local v_margin =  2 
  if data[p_graph].v_margin and data[p_graph].v_margin <= data[p_graph].height/4 then 
    v_margin = data[p_graph].v_margin 
  end
  local h_margin = 0
  if data[p_graph].h_margin and data[p_graph].h_margin <= data[p_graph].width / 3 then 
    h_margin = data[p_graph].h_margin 
  end
  
  local rounded_size = data[p_graph].rounded_size or 0

--Generate Background (background widget)
  if data[p_graph].background_color then
    helpers.draw_rounded_corners_rectangle( graph_context,
                                            0,
                                            0,
                                            data[p_graph].width, 
                                            data[p_graph].height,
                                            data[p_graph].background_color, 
                                            rounded_size )
  
  end
  
  --Draw nothing, tiles (default) or filled ( graph background)
  if data[p_graph].filled  == true then
    if data[p_graph].filled_color then
      background_color = data[p_graph].filled_color  
    --      p_graph_context:set_source_rgba(r, g, b,a)
    else
      background_color = "#00000066"
    end
      if data[p_graph].graph_color == nil then
        data[p_graph].graph_color="#7fb219B3"
      end
      if data[p_graph].graph_line_color == nil then
        data[p_graph].graph_line_color="#7fb219"
      end
    --draw a graph with filled background
    if data[p_graph].horizontal == true then
      helpers.draw_rounded_corners_horizontal_graph( p_graph_context,
                                        h_margin,
                                        v_margin,
                                        data[p_graph].width - h_margin, 
                                        data[p_graph].height - v_margin, 
                                        background_color, 
                                        data[p_graph].graph_color, 
                                        rounded_size, 
                                        data[p_graph].value,
                                        data[p_graph].graph_line_color)

    else
       helpers.draw_rounded_corners_vertical_graph( p_graph_context,
                                        h_margin,
                                        v_margin,
                                        data[p_graph].width - h_margin, 
                                        data[p_graph].height - v_margin, 
                                        background_color, 
                                        data[p_graph].graph_color, 
                                        rounded_size, 
                                        data[p_graph].value,
                                        data[p_graph].graph_line_color)
    end 
  elseif data[p_graph].filled ~= true and data[p_graph].tiles== false then
    --draw nothing
    else
    --draw tiles    
    if data[p_graph].tiles_color then
      r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[p_graph].tiles_color)
      p_graph_context:set_source_rgba(r, g, b,a)
    else
      p_graph_context:set_source_rgba(0, 0, 0,0.5)
    end
    helpers.draw_background_tiles(p_graph_context, 
                                  data[p_graph].height, 
                                  v_margin,   
                                  data[p_graph].width ,
                                  h_margin )        
    p_graph_context:fill()
    --draw the graph that will be in front of the tiles
    if data[p_graph].value > 0 then
      if data[p_graph].graph_color == nil then
        data[p_graph].graph_color="#7fb21946"
      end
      if data[p_graph].graph_line_color == nil then
        data[p_graph].graph_line_color="#7fb219"
      end
      if data[p_graph].horizontal == true then
        helpers.draw_rounded_corners_rectangle( p_graph_context,
                                                h_margin,
                                                v_margin,
                                                (data[p_graph].width - h_margin) * data[p_graph].value, 
                                                data[p_graph].height - v_margin, 
                                                data[p_graph].graph_color, 
                                                rounded_size,
                                                data[p_graph].graph_line_color
                                                )
      else
         helpers.draw_rounded_corners_rectangle( p_graph_context,
                                                h_margin,
                                                v_margin,
                                                data[p_graph].width - 2 *h_margin , 
                                                (data[p_graph].height - 2 * v_margin)* data[p_graph].value, 
                                                data[p_graph].graph_color, 
                                                rounded_size,
                                                data[p_graph].graph_line_color
                                                )
      end
    end
  end

--Drawn the p_graph
--  if data[p_graph].value > 0 then
--    if data[p_graph].horizontal == true then
      --progress bar increase/decrease from left to right
--      x=h_margin 
--      y=data[p_graph].height-(v_margin) 
--      PI = 2*math.asin(1)
--      p_graph_context:new_path()
--      p_graph_context:move_to(x,y)
--      p_graph_context:line_to(x,y)
--      x_range=data[p_graph].width - (2 * h_margin)
--      p_graph_context:line_to( h_margin + (x_range * data[p_graph].value) - (3*0),y )
----      p_graph_context:arc_negative(h_margin + (x_range * data[p_graph].value) - 3,y -3, 3, 0.5*PI, 2*PI)
--      p_graph_context:line_to( h_margin + (x_range * data[p_graph].value), v_margin )
--      p_graph_context:line_to(h_margin, v_margin )
--      p_graph_context:line_to(h_margin,data[p_graph].height-(v_margin))
--  
--      p_graph_context:close_path()
--      if data[p_graph].graph_color then
--        r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[p_graph].graph_color)
--        p_graph_context:set_source_rgba(r, g, b, a)
--      else
--        p_graph_context:set_source_rgba(0.5, 0.7, 0.1, 0.7)
--      end
--      p_graph_context:fill()
--      x=h_margin 
--      y=data[p_graph].height-(v_margin) 
--
--      p_graph_context:new_path()
--      p_graph_context:move_to(x,y)
--      p_graph_context:line_to(x,y)
--      x_range=data[p_graph].width - (2 * h_margin)
--      p_graph_context:line_to( h_margin + (x_range * data[p_graph].value),y)
--      p_graph_context:line_to( h_margin + (x_range * data[p_graph].value), v_margin )
--      p_graph_context:line_to(h_margin, v_margin )--  
--      p_graph_context:set_line_width(1)
--     if data[p_graph].graph_line_color then
--        r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[p_graph].graph_line_color)
--        p_graph_context:set_source_rgb(r, g, b)
--      else
--        p_graph_context:set_source_rgb(0.5, 0.7, 0.1)
--      end
--    else
      --progress bar increase/decrease from bottom to top
--      x=0+h_margin 
--      y=data[p_graph].height-(v_margin) 

--      p_graph_context:new_path()
--      p_graph_context:move_to(x,y)
--      p_graph_context:line_to(x,y)
--      y_range=data[p_graph].height - (2 * v_margin)
--      p_graph_context:line_to(x,data[p_graph].height -( v_margin + (y_range * data[p_graph].value)))
--      p_graph_context:line_to(data[p_graph].width - h_margin,data[p_graph].height -( v_margin + (y_range * data[p_graph].value)))
--      p_graph_context:line_to(data[p_graph].width - h_margin, data[p_graph].height - (v_margin ))
--      p_graph_context:line_to(0+h_margin,data[p_graph].height-(v_margin))
--  
--      p_graph_context:close_path()
--      if data[p_graph].graph_color then
--        r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[p_graph].graph_color)
--        p_graph_context:set_source_rgba(r, g, b, a)
--      else
--        p_graph_context:set_source_rgba(0.5, 0.7, 0.1, 0.7)
--      end
--      p_graph_context:fill()

--      x=0+h_margin 
--      y=data[p_graph].height-(v_margin) 
--  
--      p_graph_context:new_path()
--      p_graph_context:move_to(x,y)
--      p_graph_context:line_to(x,y)
--      y_range=data[p_graph].height - (2 * v_margin)
--      p_graph_context:line_to(x,data[p_graph].height -( v_margin + (y_range * data[p_graph].value)))
--      p_graph_context:line_to(data[p_graph].width -h_margin,data[p_graph].height -( v_margin +  (y_range * data[p_graph].value)))
--      p_graph_context:line_to(data[p_graph].width - h_margin, data[p_graph].height - (v_margin ))
--  
--      p_graph_context:set_line_width(1)
--      if data[p_graph].graph_line_color then
--        r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[p_graph].graph_line_color)
--        p_graph_context:set_source_rgb(r, g, b)
--      else
--        p_graph_context:set_source_rgb(0.5, 0.7, 0.1)
--      end
--    end
--    p_graph_context:stroke()
--  end
  if data[p_graph].show_text == true then
  --Draw Text and it's background
    if data[p_graph].font_size == nil then
      data[p_graph].font_size = 9
    end
    p_graph_context:set_font_size(data[p_graph].font_size)
        if data[p_graph].background_text_color == nil then
     data[p_graph].background_text_color = "#000000dd" 
    end
    if data[p_graph].text_color == nil then
     data[p_graph].text_color = "#ffffffff" 
    end    
    
    local value = data[p_graph].value * 100
    if data[p_graph].label then
      text=string.gsub(data[p_graph].label,"$percent", value)
    else
      text=value .. "%"
    end
    --if vertical graph, text is at the middle of the width, if vertical bar text is at the middle of the height
    if data[p_graph].horizontal == nil or data[p_graph].horizontal == false then
      helpers.draw_text_and_background(p_graph_context, 
                                        text, 
                                        data[p_graph].width/2, 
                                        data[p_graph].height/2 , 
                                        data[p_graph].background_text_color, 
                                        data[p_graph].text_color,
                                        true,
                                        true,
                                        false,
                                        false)
    else
       helpers.draw_text_and_background(p_graph_context, 
                                        text, 
                                        h_margin, 
                                        data[p_graph].height/2 , 
                                        data[p_graph].background_text_color, 
                                        data[p_graph].text_color,
                                        false,
                                        true,
                                        false,
                                        false)
    end     
  end

  p_graph.widget.image = capi.image.argb32(data[p_graph].width, data[p_graph].height, p_graph_surface:get_data())

end

local function add_value(p_graph, value)
  if not p_graph then return end
  local value = value or 0

  if string.find(value, "nan") then
    value=0
  end

  data[p_graph].value = value
  
  update(p_graph)
  return p_graph
end

function set_height(p_graph, height)
    if height >= 5 then
        data[p_graph].height = height
        update(p_graph)
    end
    return p_graph
end

function set_width(p_graph, width)
    if width >= 5 then
        data[p_graph].width = width
        update(p_graph)
    end
    return p_graph
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(p_graph, value)
            data[p_graph][prop] = value
            update(p_graph)
            return p_graph
        end
    end
end

function new(args)
    local args = args or {}
    args.type = "imagebox"

    local width = args.width or 100 
    local height = args.height or 20

    if width < 6 or height < 6 then return end

    local p_graph = {}
    p_graph.widget = capi.widget(args)
    p_graph.widget.resize = false

    data[p_graph] = { width = width, height = height, value = 0 }

    -- Set methods
    p_graph.add_value = add_value

    for _, prop in ipairs(properties) do
        p_graph["set_" .. prop] = _M["set_" .. prop]
    end

    p_graph.layout = args.layout or layout.horizontal.leftright

    return p_graph
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
