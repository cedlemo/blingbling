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

---Graph widget.
--@module blingbling.linegraph

local linegraph = { mt = {} }

local data = setmetatable({}, { __mode = "k" })

---Fill all the widget (width * height) with this color (default is none ). 
--@usage mygraph:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Fill the graph area background with this color (default is none).
--@usage mygraph:set_graph_background_color(string) -->"#rrggbbaa"
--@name set_graph_background_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set rounded corners for background and graph background.
--@usage mygraph:set_rounded_size(a) -> a in [0,1]
--@name set_rounded_size
--@class function
--@param rounded_size float in [0,1]

---Define the top and bottom margin for the graph area.
--@usage mygraph:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param margin an integer for top and bottom margin

---Define the left and right margin for the graph area.
--@usage mygraph:set_h_margin(integer)
--@name set_h_margin
--@class function
--@param margin an integer for left and right margin

---Define the graph color.
--@usage mygraph:set_graph_color(string) -->"#rrggbbaa"
--@name set_graph_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the graph outline.
--@usage mygraph:set_graph_line_color(string) -->"#rrggbbaa"
--@name set_graph_line_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Display text on the graph or not.
--@usage mygraph:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param boolean true or false (default is false)

---Define displayed text value format string
--@usage mygraph:set_value_format(string) --> "%2.f"
--@name set_value_format
--@class function
--@param graph the graph
--@param printf format string for display text

---Define the color of the text.
--@usage mygraph:set_text_color(string) -->"#rrggbbaa"
--@name set_text_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb" defaul is white

---Define the background color of the text.
--@usage mygraph:set_text_background_color(string) -->"#rrggbbaa"
--@name set_text_background_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the text's font .
--@usage mygraph:set_font(string)
--@name set_font
--@class function
--@param font a string that contains the font name family and weight

---Define the text font size.
--@usage mygraph:set_font_size(integer)
--@name set_font_size
--@class function
--@param size the font size

---Define the template of the text to display.
--@usage mygraph:set_label(string)
--By default the text is : (value_send_to_the_widget *100) .. "%"
--static string: example set_label("CPU usage:") will display "CUP usage:" on the graph
--dynamic string: use $percent in the string example set_label("Load $percent %") will display "Load 10%" 
--@name set_label
--@class function
--@param text the text to display



local properties = {    "width", "height", "h_margin", "v_margin",
                        "background_color", "graph_background_color",
                        "rounded_size", "graph_color", "graph_line_color",
                        "show_text", "text_color", "font_size", "font",
                        "text_background_color", "label", "value_format"
                   }

function linegraph.draw(graph, wibox, cr, width, height)

  local values = data[graph].values

  -- Set the values we need
  local value = data[graph].value

  
    
  local props = helpers.load_properties(properties, data, graph, superproperties)

  local line_width = 1
  cr:set_line_width(line_width)
  cr:set_antialias("subpixel") 
  helpers.draw_rounded_corners_rectangle(	cr,
                                          0, --x
                                          0, --y
                                          width, 
                                          height,
                                          props.background_color,
                                          props.rounded_size
                                         )

    -- Draw the graph background 

  helpers.draw_rounded_corners_rectangle(cr,
                                         props.h_margin, --x
                                         props.v_margin, --y
                                         width - props.h_margin, 
                                         height - props.v_margin ,
                                         props.graph_background_color,
                                         props.rounded_size,
                                         props.graph_background_border)

  helpers.clip_rounded_corners_rectangle(cr,
                                         props.h_margin, --x
                                         props.v_margin, --y
                                         width - props.h_margin, 
                                         height - (props.v_margin),
                                         props.rounded_size
                                 )
  --Drawn the graph
  --if graph_background_border is set, graph must not be drawn on it 

  --find nb values we can draw every column_length px
  --if rounded, make sure that graph don't begin or end outside background
  --check for the less value between hight and height to calculate the space for rounded size:
  local column_length = 6
  
  if height > width then
    less_value = width/2
  else
    less_value = height/2
  end
  max_column=math.ceil((width - (2*props.h_margin +2*(props.rounded_size * less_value)))/column_length) 
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
  --Fill the graph 
  x=width -(props.h_margin + props.rounded_size * less_value)
  y=height-(props.v_margin) 

  cr:new_path()
  cr:move_to(x,y)
  cr:line_to(x,y)
  for i=1,max_column do
    y_range=height - (2 * props.v_margin)
    y= height - (props.v_margin + ((data[graph].values[i]) * y_range))
    cr:line_to(x,y)
    x=x-column_length
  end
  y=height - (props.v_margin )
  cr:line_to(x + column_length ,y) 
  cr:line_to(width - props.h_margin,height - (props.v_margin ))
  cr:close_path()

  r,g,b,a=helpers.hexadecimal_to_rgba_percent(props.graph_color)
  cr:set_source_rgba(r, g, b, a)
  cr:fill()

  --Draw the graph line

  x=width -(props.h_margin + props.rounded_size * less_value)
  y=height-(props.v_margin) 

  cr:new_path()
  cr:move_to(x,y)
  cr:line_to(x,y)
  for i=1,max_column do
    y_range=height - (2 * props.v_margin)
    y= height - (props.v_margin + ((data[graph].values[i]) * y_range))
    -- this is a trick:
    -- when value a equal to zero, I remove add 1 pixel to the y point in order
    -- to put the point outside the clip area done with helpers.clip_rounded_corners_rectangle
    -- so when a value is == 0 the point is almost not visible whereas the line of the graph
    -- is not broken.
    if data[graph].values[i] == 0 then
      y= y + 1
    end
    cr:line_to(x,y)
    x=x-column_length
  end
  y=height - (props.v_margin - 1) -- the y point here is set outside the clip rectangle
  cr:line_to(x + column_length ,y) 

  r,g,b,a=helpers.hexadecimal_to_rgba_percent(props.graph_line_color)
  cr:set_source_rgba(r, g, b, a)
  cr:stroke() 
  if props.show_text == true then
  --Draw Text and it's background
    cr:set_font_size(props.font_size)

    if type(props.font) == "string" then
      cr:select_font_face(props.font,nil,nil)
    elseif type(props.font) == "table" then
      cr:select_font_face(props.font.family or "Sans",
                          props.font.slang or "normal",
                          props.font.weight or "normal")
    end
  
    local value = string.format(props.value_format, data[graph].values[1] * 100)
    if props.label then
      text=string.gsub(data[graph].label,"$percent", value)
    else
      text=value .. "%"
    end

    helpers.draw_text_and_background(cr, 
                                     text, 
                                     props.h_margin + props.rounded_size * less_value, 
                                      height/2 , 
                                      props.text_background_color, 
                                      props.text_color,
                                      false,
                                      true,
                                      false,
                                      false)
  end
end

function linegraph.fit(graph, width, height)
    return data[graph].width, data[graph].height
end

---Add a value to the graph.
--For compatibility between old and new awesome widget, add_value can be replaced by set_value
--@usage mygraph:add_value(a) or mygraph:set_value(a)
--@param graph the graph
--@param value The value between 0 and 1.
--@param group The stack color group index.
local function add_value(graph, value, group)
    if not graph then return end

    local value = value or 0
    local values = data[graph].values
   
    if string.find(value, "nan") then
       value=0
    end
   
    local values = data[graph].values
    table.remove(values, #values)
    table.insert(values,1,value)
    graph:emit_signal("widget::updated")
    return graph
end


---Set the graph height.
--@param height The height to set.
function linegraph:set_height( height)
    if height >= 5 then
        data[self].height = height
        self:emit_signal("widget::updated")
    end
    return self
end

---Set the graph width.
--@param width The width to set.
function linegraph:set_width( width)
    if width >= 5 then
        data[self].width = width
        self:emit_signal("widget::updated")
    end
    return self
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not linegraph["set_" .. prop] then
        linegraph["set_" .. prop] = function(graph, value)
            data[graph][prop] = value
            graph:emit_signal("widget::updated")
            return graph
        end
    end
end

---Create a graph widget.
--@param args Standard widget() arguments. You should add width and height
--key to set graph geometry.
--@return A graph widget.
function linegraph.new(args)
    
    local args = args or {}

    args.width = args.width or 100
    args.height = args.height or 20

    if args.width < 5 or args.height < 5 then return end

    local graph = base.make_widget()
    data[graph] = {}

    for _, v in ipairs(properties) do
      data[graph][v] = args[v] 
    end

    data[graph].values = {}
    
    -- Set methods
    graph.set_value = add_value
    graph.add_value = add_value
    graph.draw = linegraph.draw
    graph.fit = linegraph.fit

    for _, prop in ipairs(properties) do
        graph["set_" .. prop] = linegraph["set_" .. prop]
    end

    return graph
end

function linegraph.mt:__call(...)
    return linegraph.new(...)
end

return setmetatable(linegraph, linegraph.mt)
