local helpers =require("blingbling.helpers")
local string = require("string")
local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local table = table
local type=type
local cairo = require "oocairo"
local capi = { image = image, widget = widget }
local layout = require("awful.widget.layout")

module("blingbling.classical_graph")

local data = setmetatable({}, { __mode = "k" })

local properties = { "width", "height", "v_margin","h_margin", "background_color", "filled", "filled_color", "tiles", "tiles_color", "graph_color", "graph_line_color", "show_text", "text_color", "background_text_color" ,"label", "font_size"}

local function update(graph)
  
  local graph_surface=cairo.image_surface_create("argb32",data[graph].width, data[graph].height)
  local graph_context = cairo.context_create(graph_surface)
  
  local v_margin = 2 
  if data[graph].v_margin then 
    v_margin = data[graph].v_margin 
  end
  local h_margin = 0
  if data[graph].h_margin and data[graph].h_margin <= data[graph].width / 3 then 
    h_margin = data[graph].h_margin 
  end

--Generate Background (background widget)
  if data[graph].background_color then
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[graph].background_color)
    --helpers.dbg({r,g,b,a})
    graph_context:set_source_rgba(r,g,b,a)
    graph_context:paint()
  end
  
  
  --Draw nothing, tiles (default) or graph background (filled) 
  if data[graph].filled  == true then
    --fill the graph background
    graph_context:rectangle(h_margin,v_margin, data[graph].width - (2*h_margin), data[graph].height - (2* v_margin))

    if data[graph].filled_color then
          r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[graph].filled_color)
          graph_context:set_source_rgba(r, g, b,a)
    else
          graph_context:set_source_rgba(0, 0, 0,0.5)
    end
    graph_context:fill()
  elseif data[graph].filled ~= true and data[graph].tiles== false then
      --draw nothing
      else
      --draw tiles
        if data[graph].tiles_color then
          r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[graph].tiles_color)
          graph_context:set_source_rgba(r, g, b,a)
        else
          graph_context:set_source_rgba(0, 0, 0,0.5)
        end
		helpers.draw_background_tiles(graph_context, data[graph].height, v_margin, data[graph].width ,h_margin )
        graph_context:fill()
  end

--Drawn the graph
 --find nb values we can draw every 3 px
  max_column=math.ceil((data[graph].width - (2*h_margin))/3)
  --helpers.dbg({max_column})
  --Check if the table graph values is empty / not initialized
  --if next(data[graph].values) == nil then
  if #data[graph].values == 0 or #data[graph].values ~= max_column then
      -- initialize graph_values with empty values:
  data[graph].values={}
    for i=1,max_column do
      --the following line feed the graph with random value if you uncomment it and comment the line after it
      --data[graph].values[i]=math.random(0,100) / 100
      data[graph].values[i]=0
    end
  end
  
  x=data[graph].width -h_margin
  y=data[graph].height-(v_margin) 
  
  graph_context:new_path()
  graph_context:move_to(x,y)
  graph_context:line_to(x,y)
  for i=1,max_column do
    y_range=data[graph].height - (2 * v_margin)
    
    y= data[graph].height - (v_margin + ((data[graph].values[i]) * y_range))
    graph_context:line_to(x,y)
    x=x-3
  end
  y=data[graph].height - (v_margin )
  graph_context:line_to(x + 3 ,y) 
  graph_context:line_to(data[graph].width-h_margin,data[graph].height-(v_margin))
  graph_context:close_path()
  if data[graph].graph_color then
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[graph].graph_color)
    graph_context:set_source_rgba(r, g, b, a)
  else
    graph_context:set_source_rgba(0.5, 0.7, 0.1, 0.7)
  end
  graph_context:fill()
  

  x=data[graph].width - h_margin 
  y=data[graph].height-(v_margin) 
 
  graph_context:new_path()
  graph_context:move_to(x,y)
  graph_context:line_to(x,y)
  for i=1,max_column do
    y_range=data[graph].height - (2 * v_margin)
    y= data[graph].height - (v_margin + ((data[graph].values[i]) * y_range))
    graph_context:line_to(x,y)
    x=x-3
  end
  x=h_margin + 3
  graph_context:line_to(x,y)
  y=data[graph].height - (v_margin )
  graph_context:line_to(x ,y) 
  graph_context:set_line_width(1)
  if data[graph].graph_line_color then
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[graph].graph_line_color)
    graph_context:set_source_rgb(r, g, b)
  else
    graph_context:set_source_rgb(0.5, 0.7, 0.1)
  end
  
  graph_context:stroke()
  if data[graph].show_text == true then
  --Draw Text and it's background
    if data[graph].font_size == nil then
      data[graph].font_size = 9
    end
    graph_context:set_font_size(data[graph].font_size)
    
    if data[graph].background_text_color == nil then
     data[graph].background_text_color = "#000000dd" 
    end
    if data[graph].text_color == nil then
     data[graph].text_color = "#ffffffff" 
    end    
    
    local value = data[graph].values[1] * 100
    if data[graph].label then
      text=string.gsub(data[graph].label,"$percent", value)
    else
      text=value .. "%"
    end

    helpers.draw_text_and_background(graph_context, 
                                        text, 
                                        h_margin, 
                                        (data[graph].height/2) + (data[graph].font_size)/2, 
                                        data[graph].background_text_color, 
                                        data[graph].text_color,
                                        false,
                                        false)
  end
  graph.widget.image = capi.image.argb32(data[graph].width, data[graph].height, graph_surface:get_data())
end

local function add_value(graph, value)
  if not graph then return end
  local value = value or 0

  if string.find(value, "nan") then
    dbg({value})
    value=0
  end

  local values = data[graph].values
  table.remove(values, #values)
  table.insert(values,1,value)

  update(graph)
  return graph
end

function set_height(graph, height)
    if height >= 5 then
        data[graph].height = height
        update(graph)
    end
    return graph
end

function set_width(graph, width)
    if width >= 5 then
        data[graph].width = width
        update(graph)
    end
    return graph
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(graph, value)
            data[graph][prop] = value
            update(graph)
            return graph
        end
    end
end

function new(args)
    local args = args or {}
    args.type = "imagebox"

    local width = args.width or 100
    local height = args.height or 20

    if width < 5 or height < 5 then return end

    local graph = {}
    graph.widget = capi.widget(args)
    graph.widget.resize = false

    data[graph] = { width = width, height = height, values = {} }

    -- Set methods
    graph.add_value = add_value

    for _, prop in ipairs(properties) do
        graph["set_" .. prop] = _M["set_" .. prop]
    end

    graph.layout = args.layout or layout.horizontal.leftright

    return graph
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
