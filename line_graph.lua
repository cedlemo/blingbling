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
--- A graph widget.
module("blingbling.line_graph")

local data = setmetatable({}, { __mode = "k" })

---Fill all the widget (width * height) with this color (default is none ) 
--mycairograph:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@graph graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set a border (width * height) with this color (default is none ) 
--mycairograph:set_background_border(string) -->"#rrggbbaa"
--@name set_background_border
--@class function
--@graph graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Fill the graph area background with this color (default is none)
--mycairograph:set_graph_background_color(string) -->"#rrggbbaa"
--@name set_graph_background_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set a border on the graph area background (default is none ) 
--mycairograph:set_graph_background_border(string) -->"#rrggbbaa"
--@name set_graph_background_border
--@class function
--@graph graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set rounded corners for background and graph background
--mycairograph:set_rounded_size(a) -> a in [0,1]
--@name set_rounded_size
--@class function
--@param graph the graph
--@param rounded_size float in [0,1]

---Define the top and bottom padding for the graph area
--mycairograph:set_v_padding(integer)
--@name set_v_padding
--@class function
--@param graph the graph
--@param padding an integer for top and bottom padding

---Define the left and right padding for the graph area
--mycairograph:set_h_padding(integer)
--@name set_h_padding
--@class function
--@param graph the graph
--@param padding an integer for left and right margin

---Define the graph color
--mycairograph:set_graph_color(string) -->"#rrggbbaa"
--@name set_graph_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the graph outline
--mycairograph:set_graph_line_color(string) -->"#rrggbbaa"
--@name set_graph_line_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Display text on the graph or not
--mycairograph:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param graph the graph
--@param boolean true or false (default is false)

---Define the color of the text
--mycairograph:set_text_color(string) -->"#rrggbbaa"
--@name set_text_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb" defaul is white

---Define the background color of the text
--mycairograph:set_background_text_color(string) -->"#rrggbbaa"
--@name set_background_text_color
--@class
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the text font size
--mycairograph:set_text_font_size(integer)
--@name set_text_font_size
--@class function
--@param graph the graph
--@param size the font size

---Define the template of the text to display
--mycairograph:set_label(string)
--By default the text is : (value_send_to_the_widget *100) .. "%"
--static string: example set_label("CPU usage:") will display "CUP usage:" on the graph
--dynamic string: use $percent in the string example set_label("Load $percent %") will display "Load 10%" 
--@name set_label
--@class function
--@param graph the graph
--@param text the text to display



local properties = {    "width", "height", "h_padding", "v_padding",
                        "background_border", "background_color", 
                        "graph_background_border", "graph_background_color",
                        "rounded_size", "graph_color", "graph_line_color",
                        "show_text", "text_color", "text_font_size",
                        "text_background_color", "label"
                   }

function draw(graph, wibox, cr, width, height)
    local max_value = data[graph].max_value
    local values = data[graph].values

    local background_border_width = 0
    if data[graph].background_border_color then
        background_border_width = 1
    end

    local graph_border_width = 0
    if data[graph].graph_border_color then
        graph_border_width = 1
    end
    
    local v_padding = 2
    if data[graph].v_padding  and data[graph].v_padding <= height / 3 then
      v_padding = data[graph].v_padding
    end
    
    local h_padding = 2
    if data[graph].h_padding and data[graph].h_padding <= width / 3 then
       h_padding = data[graph].h_padding
    end

    cr:set_line_width(1)

    -- Draw the widget background 
    if data[graph].background_color then
      helpers.draw_rounded_corners_rectangle(cr,
                                                0, --x
                                                0, --y
                                                width, 
                                                height,
                                                data[graph].background_color,
                                                data[graph].rounded_size,
                                                data[graph].background_border)
     end

    -- Draw the widget background 
    if data[graph].graph_background_color then
      helpers.draw_rounded_corners_rectangle(cr,
                                                h_padding, --x
                                                v_padding, --y
                                                width - h_padding, 
                                                height - v_padding,
                                                data[graph].graph_background_color,
                                                data[graph].rounded_size,
                                                data[graph].graph_background_border)
     end
    --Drawn the graph
    --find nb values we can draw every 3 px
    --if rounded, make sure that graph don't begin or end outside background
    --check for the less value between hight and height:
    rounded_size = data[graph].rounded_size or 0
    if height > width then
      less_value = width/2
    else
      less_value = height/2
    end
    max_column=math.ceil((width - (2*h_padding + (data[graph].rounded_size * less_value)))/3)
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
  
    x=width -(h_padding + rounded_size * less_value)
    y=height-(v_padding) 
  
    cr:new_path()
    cr:move_to(x,y)
    cr:line_to(x,y)
    for i=1,max_column do
      y_range=height - (2 * v_padding)
    
      y= height - (v_padding + ((data[graph].values[i]) * y_range))
      cr:line_to(x,y)
      x=x-3
    end
    y=height - (v_padding )
    cr:line_to(x + 3 ,y) 
    cr:line_to(width - h_padding,height - (v_padding))
    cr:close_path()
  
    if data[graph].graph_color then
      r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[graph].graph_color)
      cr:set_source_rgba(r, g, b, a)
    else
      cr:set_source_rgba(0.5, 0.7, 0.1, 0.7)
    end
    cr:fill()
  

    x=width - (h_padding + rounded_size * less_value)
    y=height-(v_padding) 
 
    cr:new_path()
    cr:move_to(x,y)
    cr:line_to(x,y)
    for i=1,max_column do
      y_range=height - (2 * v_padding + 1)
      y= height - (v_padding + ((data[graph].values[i]) * y_range))
      cr:line_to(x,y)
      x=x-3
    end
    x=h_padding + 3
    cr:line_to(x,y)
    y=height - (v_padding )
    cr:line_to(x ,y) 
    cr:set_line_width(1)
    if data[graph].graph_line_color then
      r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[graph].graph_line_color)
      cr:set_source_rgba(r, g, b,a)
    else
      cr:set_source_rgb(0.5, 0.7, 0.1)
    end
    cr:stroke()
    
    if data[graph].show_text == true then
    --Draw Text and it's background
      if data[graph].text_font_size == nil then
        data[graph].text_font_size = 9
      end
      cr:set_font_size(data[graph].text_font_size)
    
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

      helpers.draw_text_and_background(cr, 
                                        text, 
                                        h_padding + rounded_size * less_value, 
                                        height/2 , 
                                        data[graph].background_text_color, 
                                        data[graph].text_color,
                                        false,
                                        true,
                                        false,
                                        false)
    end
end

function fit(graph, width, height)
    return data[graph].width, data[graph].height
end

--- Add a value to the graph
-- @param graph The graph.
-- @param value The value between 0 and 1.
-- @param group The stack color group index.
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


--- Set the graph height.
-- @param graph The graph.
-- @param height The height to set.
function set_height(graph, height)
    if height >= 5 then
        data[graph].height = height
        graph:emit_signal("widget::updated")
    end
    return graph
end

--- Set the graph width.
-- @param graph The graph.
-- @param width The width to set.
function set_width(graph, width)
    if width >= 5 then
        data[graph].width = width
        graph:emit_signal("widget::updated")
    end
    return graph
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(graph, value)
            data[graph][prop] = value
            graph:emit_signal("widget::updated")
            return graph
        end
    end
end

--- Create a graph widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set graph geometry.
-- @return A graph widget.
function new(args)
    local args = args or {}

    local width = args.width or 100
    local height = args.height or 20

    if width < 5 or height < 5 then return end

    local graph = base.make_widget()

    data[graph] = { width = width, height = height, values = {} }

    -- Set methods
    graph.add_value = add_value
    graph.draw = draw
    graph.fit = fit

    for _, prop in ipairs(properties) do
        graph["set_" .. prop] = _M["set_" .. prop]
    end

    return graph
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })

