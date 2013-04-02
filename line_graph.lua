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

local linegraph = { mt = {} }

local data = setmetatable({}, { __mode = "k" })

---Fill all the widget (width * height) with this color (default is none ) 
--@usage mygraph:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@graph graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set a border (width * height) with this color (default is none ) 
--@usage mygraph:set_background_border(string) -->"#rrggbbaa"
--@name set_background_border
--@class function
--@graph graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Fill the graph area background with this color (default is none)
--@usage mygraph:set_graph_background_color(string) -->"#rrggbbaa"
--@name set_graph_background_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set a border on the graph area background (default is none ) 
--@usage mygraph:set_graph_background_border(string) -->"#rrggbbaa"
--@name set_graph_background_border
--@class function
--@graph graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set rounded corners for background and graph background
--@usage mygraph:set_rounded_size(a) -> a in [0,1]
--@name set_rounded_size
--@class function
--@param graph the graph
--@param rounded_size float in [0,1]

---Define the top and bottom margin for the graph area
--@usage mygraph:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param graph the graph
--@param margin an integer for top and bottom margin

---Define the left and right margin for the graph area
--@usage mygraph:set_h_margin(integer)
--@name set_h_margin
--@class function
--@param graph the graph
--@param margin an integer for left and right margin

---Define the graph color
--@usage mygraph:set_graph_color(string) -->"#rrggbbaa"
--@name set_graph_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the graph outline
--@usage mygraph:set_graph_line_color(string) -->"#rrggbbaa"
--@name set_graph_line_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Display text on the graph or not
--@usage mygraph:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param graph the graph
--@param boolean true or false (default is false)

---Define the color of the text
--@usage mygraph:set_text_color(string) -->"#rrggbbaa"
--@name set_text_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb" defaul is white

---Define the background color of the text
--@usage mygraph:set_background_text_color(string) -->"#rrggbbaa"
--@name set_background_text_color
--@class
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the text font size
--@usage mygraph:set_font_size(integer)
--@name set_font_size
--@class function
--@param graph the graph
--@param size the font size

---Define the template of the text to display
--@usage mygraph:set_label(string)
--By default the text is : (value_send_to_the_widget *100) .. "%"
--static string: example set_label("CPU usage:") will display "CUP usage:" on the graph
--dynamic string: use $percent in the string example set_label("Load $percent %") will display "Load 10%" 
--@name set_label
--@class function
--@param graph the graph
--@param text the text to display



local properties = {    "width", "height", "h_margin", "v_margin",
                        "background_border", "background_color", 
                        "graph_background_border", "graph_background_color",
                        "rounded_size", "graph_color", "graph_line_color",
                        "show_text", "text_color", "font_size", "font",
                        "text_background_color", "label"
                   }

function linegraph.draw(graph, wibox, cr, width, height)

    local max_value = data[graph].max_value
    local values = data[graph].values

    -- Set the values we need
    local value = data[graph].value
    
--    local background_border_width = 0
--    if data[graph].background_border then
--        background_border_width = 1
--    end

    local graph_border_width = 0
    if data[graph].graph_background_border then
        graph_border_width = 1
    end
    
    local v_margin =  superproperties.v_margin 
    if data[graph].v_margin and data[graph].v_margin <= data[graph].height/4 then 
        v_margin = data[graph].v_margin 
    end
    
    local h_margin = superproperties.h_margin
    if data[graph].h_margin and data[graph].h_margin <= data[graph].width / 3 then 
        h_margin = data[graph].h_margin 
    end
    
    local background_border = data[graph].background_border or superproperties.background_border
    local background_color = data[graph].background_color or superproperties.background_color
    local rounded_size = data[graph].rounded_size or superproperties.rounded_size
    local graph_background_color = data[graph].graph_background_color or superproperties.graph_background_color
    local graph_background_border = data[graph].graph_background_border or superproperties.graph_background_border
    local graph_color = data[graph].graph_color or superproperties.graph_color
    local graph_line_color = data[graph].graph_line_color or superproperties.graph_line_color
    local text_color = data[graph].text_color or superproperties.text_color
    local background_text_color = data[graph].background_text_color or superproperties.background_text_color
    local font_size =data[graph].font_size or superproperties.font_size
    local font = data[graph].font or superproperties.font
    
    local line_width = 1
    cr:set_line_width(line_width)
    cr:set_antialias("subpixel") 
    -- Draw the widget background 
    if data[graph].background_color then
      helpers.draw_rounded_corners_rectangle(cr,
                                                0, --x
                                                0, --y
                                                data[graph].width, 
                                                data[graph].height,
                                                background_color,
                                                rounded_size,
                                                background_border)
     end

    -- Draw the graph background 
    --if background_border is set, graph background  must not be drawn on it 
    local h_padding = 0
    local v_padding = 0

    if background_border ~= nil and h_margin < 1 then
      h_padding = 1
    else 
      h_padding = h_margin + 1
    end
    if background_border ~= nil and v_margin < 1 then
      v_padding = 1 
    else
      v_padding = v_margin + 1
    end

    if data[graph].graph_background_color then
      helpers.draw_rounded_corners_rectangle(cr,
                                                h_padding, --x
                                                v_padding, --y
                                                data[graph].width - h_padding, 
                                                data[graph].height - v_padding ,
                                                graph_background_color,
                                                rounded_size,
                                                graph_background_border)
     end
    helpers.clip_rounded_corners_rectangle(cr,
                                   h_padding, --x
                                   v_padding, --y
                                   data[graph].width - h_padding, 
                                   data[graph].height - v_padding,
                                   rounded_size
                                    )
    --Drawn the graph
    --if graph_background_border is set, graph must not be drawn on it 

    if helpers.is_transparent(graph_background_border) == false then
      h_padding = h_padding + 1
      v_padding = v_padding + 1
    end
    --find nb values we can draw every column_length px
    --if rounded, make sure that graph don't begin or end outside background
    --check for the less value between hight and height to calculate the space for rounded size:
    local column_length = 6
    
    if data[graph].height > data[graph].width then
      less_value = data[graph].width/2
    else
      less_value = data[graph].height/2
    end
    max_column=math.ceil((data[graph].width - (2*h_padding +2*(rounded_size * less_value)))/column_length) 
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
    x=data[graph].width -(h_padding + rounded_size * less_value)
    y=data[graph].height-(v_padding) 
  
    cr:new_path()
    cr:move_to(x,y)
    cr:line_to(x,y)
    for i=1,max_column do
      y_range=data[graph].height - (2 * v_margin)
      y= data[graph].height - (v_padding + ((data[graph].values[i]) * y_range))
      cr:line_to(x,y)
      x=x-column_length
    end
    y=data[graph].height - (v_padding )
    cr:line_to(x + column_length ,y) 
    cr:line_to(width - h_padding,data[graph].height - (v_padding ))
    cr:close_path()
  
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_color)
    cr:set_source_rgba(r, g, b, a)
    cr:fill()
  
    --Draw the graph line
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_line_color)
    cr:set_source_rgba(r, g, b,a)
--    
    x=data[graph].width - (h_padding + rounded_size * less_value)
    y=data[graph].height-(v_padding) 
-- 
    cr:new_path()
    cr:move_to(x,y )
    cr:line_to(x,y )
    for i=1,max_column do
      y_range=data[graph].height - (2 * h_margin + 1)
      y= data[graph].height - (v_margin + ((data[graph].values[i]) * y_range))
      cr:line_to(x,y )
      x=x-column_length
    end
    x=x + column_length
    y=data[graph].height - (v_padding )
    cr:line_to(x ,y ) 
    cr:stroke()
    
    if data[graph].show_text == true then
    --Draw Text and it's background
      cr:set_font_size(font_size)

      if type(font) == "string" then
        cr:select_font_face(font,nil,nil)
      elseif type(font) == "table" then
        cr:select_font_face(font.family or "Sans", font.slang or "normal", font.weight or "normal")
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
                                        data[graph].height/2 , 
                                        background_text_color, 
                                        text_color,
                                        false,
                                        true,
                                        false,
                                        false)
    end
end

function linegraph.fit(graph, width, height)
    return data[graph].width, data[graph].height
end

--- Add a value to the graph
-- For compatibility between old and new awesome widget, add_value can be replaced by set_value
-- @usage mygraph:add_value(a) or mygraph:set_value(a)
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
function linegraph:set_height( height)
    if height >= 5 then
        data[self].height = height
        self:emit_signal("widget::updated")
    end
    return self
end

--- Set the graph width.
-- @param graph The graph.
-- @param width The width to set.
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

--- Create a graph widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set graph geometry.
-- @return A graph widget.
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

