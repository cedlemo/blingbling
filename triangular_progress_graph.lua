-- @author cedlemo  

local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local table = table
local type = type
local string = string
local color = require("gears.color")
local base = require("wibox.widget.base")
local helpers = require("blingbling.helpers")
local superproperties = require('blingbling.superproperties')

---Fill all the widget (width * height) with this color (default is transparent ) 
--myvolume:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@graph graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

--Define the form of the graph: use five growing bars instead of a triangle
--myvolume:set_bar(boolean) --> true or false
--@name set_bar
--@class function
--@param graph the graph
--@param boolean true or false (default is false)

--Define the top and bottom margin for the graph
--myvolume:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param graph the graph
--@param margin an integer for top and bottom margin

--Define the left and right margin for the graph
--myvolume:set_h_margin(integer)
--@name set_h_margin
--@class function
--@param graph the graph
--@param margin an integer for left and right margin

---Set the color of the graph background
--myvolume:set_filled_color(string) -->"#rrggbbaa"
--@name set_filled_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the graph color
--myvolume:set_graph_color(string) -->"#rrggbbaa"
--@name set_graph_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

--Display text on the graph or not
--myvolume:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param graph the graph
--@param boolean true or false (default is false)

--Define the color of the text
--myvolume:set_text_color(string) -->"#rrggbbaa"
--@name set_text_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb" defaul is white

--Define the background color of the text
--myvolume:set_background_text_color(string) -->"#rrggbbaa"
--@name set_background_text_color
--@class
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the text font size
--myvolume:set_font_size(integer)
--@name set_font_size
--@class function
--@param graph the graph
--@param size the font size

---Define the template of the text to display
--@usage myvolume:set_label(string)
--By default the text is : (value_send_to_the_widget *100) .. "%"
--static string: example set_label("Volume:") will display "Volume:" on the graph
--dynamic string: use $percent in the string example set_label("Volume $percent %") will display "Volume 10%" 
--@name set_label
--@class function
--@param graph the graph
--@param text the text to display

local triangular_progressgraph = { mt = {} }

local data = setmetatable({}, { __mode = "k" })
local properties = {"width", "height", "v_margin", "h_margin", "background_color", "graph_background_color", "graph_color","graph_line_color","show_text", "text_color", "background_text_color" ,"label", "font_size","font", "bar"}

function triangular_progressgraph.draw(tp_graph, wibox, cr, width, height)

  local v_margin =  superproperties.v_margin 
  if data[tp_graph].v_margin and data[tp_graph].v_margin <= data[tp_graph].height/4 then 
    v_margin = data[tp_graph].v_margin 
  end
    
  local h_margin = superproperties.h_margin
  if data[tp_graph].h_margin and data[tp_graph].h_margin <= data[tp_graph].width / 3 then 
    h_margin = data[tp_graph].h_margin 
  end
    
  local background_color = data[tp_graph].background_color or superproperties.background_color
  local rounded_size = data[tp_graph].rounded_size or superproperties.rounded_size
  local graph_background_color = data[tp_graph].graph_background_color or superproperties.graph_background_color
  local graph_color = data[tp_graph].graph_color or superproperties.graph_color
  local graph_line_color = data[tp_graph].graph_line_color or superproperties.graph_line_color
  local text_color = data[tp_graph].text_color or superproperties.text_color
  local background_text_color = data[tp_graph].background_text_color or superproperties.background_text_color
  local font_size =data[tp_graph].font_size or superproperties.font_size
  local font = data[tp_graph].font or superproperties.font

--Generate Background (background color and Tiles)
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(background_color)
    cr:set_source_rgba(r,g,b,a)
    cr:paint()
--Drawn the tp_graph
  
  if data[tp_graph].value > 0 then
    if data[tp_graph].bar == true then
      --4 bar are use to represent data:
      --bar width:
      local nb_bar=5
      local bar_separator = 2
      local bar_width 
      bar_width=math.floor((data[tp_graph].width -((2*h_margin) + ((nb_bar - 1) * bar_separator)))/nb_bar)
      local h_rest =data[tp_graph].width -( 2*h_margin +((nb_bar -1)*bar_separator) + nb_bar * bar_width)
      if h_rest ==2 or h_rest == 3 then 
        h_rest = 1
      end
      if h_rest == 4 then
        h_rest = 2
      end
      --Drawn background graph
      x=h_margin+h_rest
      y=data[tp_graph].height - v_margin
      for i=1, nb_bar do
        cr:rectangle(x,y-((0.2*i)*(data[tp_graph].height - 2*v_margin)),bar_width,((0.2*i)*(data[tp_graph].height - 2*v_margin)))
        x=x+(bar_width + bar_separator)
      end

      r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_background_color)
      cr:set_source_rgba(r, g, b, a)

      cr:fill()
      --Drawn the graph
      --find nb column to drawn:
      local ranges={0,0.2,0.4,0.6,0.8,1,1.2}
      nb_bar=0
      for i,  limite in ipairs(ranges) do
        if data[tp_graph].value < limite then
        --helpers.dbg({data[tp_graph].value, limite})
          nb_bar = i-1
          break
        end
      end
      x=h_margin+h_rest
      y=data[tp_graph].height - v_margin
      for i=1, nb_bar do
        if i ~= nb_bar then
          cr:rectangle(x,y-((0.2*i)*(data[tp_graph].height - 2*v_margin)),bar_width,(0.2*i)*(data[tp_graph].height - 2*v_margin))
          x=x+(bar_width + bar_separator)
        else
          val_to_display =data[tp_graph].value - ((nb_bar-1) * 0.2)

          cr:rectangle(x,y-((0.2*i)*(data[tp_graph].height - 2*v_margin)),bar_width * (val_to_display/0.2),(0.2*i)*(data[tp_graph].height - 2*v_margin))
        end
      end
      
      r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_color)
      cr:set_source_rgba(r, g, b, a)

      cr:fill()

    else  
      x=h_margin 
      y=data[tp_graph].height-(v_margin) 
  
      cr:new_path()
      cr:move_to(x,y)
      cr:line_to(x,y)
      y_range=data[tp_graph].height - (2 * v_margin)
      cr:line_to(data[tp_graph].width + h_margin,data[tp_graph].height -( v_margin + y_range ))
      cr:line_to(data[tp_graph].width  + h_margin, data[tp_graph].height - (v_margin ))
      cr:line_to(h_margin,data[tp_graph].height-(v_margin))
  
      cr:close_path()
    
      r,g,b,a = helpers.hexadecimal_to_rgba_percent(graph_background_color)
      cr:set_source_rgba(r, g, b,a)

      cr:fill()
      
      x=h_margin 
      y=data[tp_graph].height-(v_margin) 
  
      cr:new_path()
      cr:move_to(x,y)
      cr:line_to(x,y)
      y_range=data[tp_graph].height - (2 * v_margin)
      cr:line_to(data[tp_graph].width * data[tp_graph].value + h_margin,data[tp_graph].height -( v_margin + (y_range * data[tp_graph].value)))
      cr:line_to(data[tp_graph].width * data[tp_graph].value + h_margin, data[tp_graph].height - (v_margin ))
      cr:line_to(0+h_margin,data[tp_graph].height-(v_margin))
  
      cr:close_path()
      r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_color)
      cr:set_source_rgba(r, g, b, a)

      cr:fill()

      x=0+h_margin 
      y=data[tp_graph].height-(v_margin) 

      cr:new_path()
      cr:move_to(x,y)
      cr:line_to(x,y)
      y_range=data[tp_graph].height - (2 * v_margin)
      cr:line_to((data[tp_graph].width * data[tp_graph].value) + h_margin  ,data[tp_graph].height -( v_margin +  (y_range * data[tp_graph].value)))
      cr:line_to((data[tp_graph].width * data[tp_graph].value) - h_margin, data[tp_graph].height - (v_margin ))
      cr:set_antialias("subpixel") 
      cr:set_line_width(1)

      r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_line_color)
      cr:set_source_rgb(r, g, b)

  
      cr:stroke()
    end
  end
--Draw Text and it's background
  if data[tp_graph].show_text == true  then 

    cr:set_font_size(font_size)
  
    if type(font) == "string" then
      cr:select_font_face(font,nil,nil)
    elseif type(font) == "table" then
      cr:select_font_face(font.family or "Sans", font.slang or "normal", font.weight or "normal")
    end

    local value = data[tp_graph].value * 100
    
    if data[tp_graph].label then
      text=string.gsub(data[tp_graph].label,"$percent", value)
    else
      text=value .. "%"
    end
    helpers.draw_text_and_background(cr, 
                                      text, 
                                      h_margin, 
                                      (data[tp_graph].height/2) , 
                                      background_text_color, 
                                      text_color,
                                      false,
                                      true,
                                      false,
                                      false)
  end
end


function triangular_progressgraph.fit(tp_graph, width, height)
    return data[tp_graph].width, data[tp_graph].height
end

--- Add a value to the tp_graph
-- For compatibility between old and new awesome widget, add_value can be replaced by set_value
-- @usage mygraph:add_value(a) or mygraph:set_value(a)
-- @param tp_graph The tp_graph.
-- @param value The value between 0 and 1.
-- @param group The stack color group index.
--local function add_value(tp_graph, value, group)
--    if not graph then return end
--
--    local value = value or 0
--    local values = data[tp_graph].values
--   
--   if string.find(value, "nan") then
--       value=0
--    end
--   
--    local values = data[tp_graph].values
--    table.remove(values, #values)
--    table.insert(values,1,value)
--   
--    tp_graph:emit_signal("widget::updated")
--    return tp_graph
--end
--or
--- Set the tp_graph value.
-- @param p_graph The progress bar.
-- @param value The progress bar value between 0 and 1.
local function set_value(tp_graph, value)
    local value = value or 0
    local max_value = data[tp_graph].max_value
    data[tp_graph].value = math.min(max_value, math.max(0, value))
    tp_graph:emit_signal("widget::updated")
    return tp_graph
end

--- Set the tp_graph height.
-- @param tp_graph The graph.
-- @param height The height to set.
function triangular_progressgraph:set_height( height)
    if height >= 5 then
        data[self].height = height
        self:emit_signal("widget::updated")
    end
    return self
end

--- Set the graph width.
-- @param graph The graph.
-- @param width The width to set.
function triangular_progressgraph:set_width( width)
    if width >= 5 then
        data[self].width = width
        self:emit_signal("widget::updated")
    end
    return self
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not triangular_progressgraph["set_" .. prop] then
        triangular_progressgraph["set_" .. prop] = function(tp_graph, value)
            data[tp_graph][prop] = value
            tp_graph:emit_signal("widget::updated")
            return tp_graph
        end
    end
end

--- Create a tp_graph widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set graph geometry.
-- @return A graph widget.
function triangular_progressgraph.new(args)
    
    local args = args or {}

    args.width = args.width or 100
    args.height = args.height or 20

    if args.width < 5 or args.height < 5 then return end

    local tp_graph = base.make_widget()
    
    data[tp_graph] = {}

    for _, v in ipairs(properties) do
      data[tp_graph][v] = args[v] 
    end


    data[tp_graph].value = 0
    data[tp_graph].max_value = 1

    -- Set methods
    tp_graph.set_value = set_value
    tp_graph.add_value = set_value
    tp_graph.draw = triangular_progressgraph.draw
    tp_graph.fit = triangular_progressgraph.fit

    for _, prop in ipairs(properties) do
        tp_graph["set_" .. prop] = triangular_progressgraph["set_" .. prop]
    end

    return tp_graph
end

function triangular_progressgraph.mt:__call(...)
    return triangular_progressgraph.new(...)
end

return setmetatable(triangular_progressgraph, triangular_progressgraph.mt)

