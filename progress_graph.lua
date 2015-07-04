--@author cedlemo
local setmetatable = setmetatable
local ipairs = ipairs
local type = type
local math = math
local string = string
local helpers = require('blingbling.helpers')
local base = require("wibox.widget.base")
local color = require("gears.color")
local superproperties = require('blingbling.superproperties')
--- A progress graph widget.
--@module blingbling.progress_graph

local progressgraph = { mt = {} }
---Fill all the widget (width * height) with this color (default is none ). 
--@usage mygraph:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Fill the graph area background with this color (default is none).
--@usage mygraph:set_graph_background_color(string) -->"#rrggbbaa"
--@name set_graph_background_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set rounded corners for background and graph background.
--@usage mygraph:set_rounded_size(a) -> a in [0,1]
--@name set_rounded_size
--@class function
--@param graph the graph
--@param rounded_size float in [0,1]

---Define the top and bottom margin for the graph area.
--@usage mygraph:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param graph the graph
--@param margin an integer for top and bottom margin

---Define the left and right margin for the graph area.
--@usage mygraph:set_h_margin(integer)
--@name set_h_margin
--@class function
--@param graph the graph
--@param margin an integer for left and right margin

---Define the graph color.
--@usage mygraph:set_graph_color(string) -->"#rrggbbaa"
--@name set_graph_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the graph outline.
--@usage mygraph:set_graph_line_color(string) -->"#rrggbbaa"
--@name set_graph_line_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Display text on the graph or not.
--@usage mygraph:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param graph the graph
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
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb" defaul is white

---Define the background color of the text.
--@usage mygraph:set_text_background_color(string) -->"#rrggbbaa"
--@name set_text_background_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the text font size.
--@usage mygraph:set_font_size(integer)
--@name set_font_size
--@class function
--@param graph the graph
--@param size the font size

---Define the template of the text to display.
--@usage mygraph:set_label(string)
--By default the text is : (value_send_to_the_widget *100) .. "%"
--static string: example set_label("CPU usage:") will display "CUP usage:" on the graph
--dynamic string: use $percent in the string example set_label("Load $percent %") will display "Load 10%" 
--@name set_label
--@class function
--@param graph the graph
--@param text the text to display

---Define if the graph should increase/decrease horizontaly.
--@usage mygraph:set_horizontal(boolean) --> true or false
--@name set_horizontal
--@class function
--@param graph the graph
--@param boolean true or false (false by default)

local data = setmetatable({}, { __mode = "k" })


local properties = {    "width", "height", "v_margin", "h_margin",
                        "background_color",
                        "graph_background_color","rounded_size",
                        "graph_color", "graph_line_color","show_text", "text_color", 
                        "text_background_color" ,"label", "font_size","font","horizontal",
                        "value_format"}

function progressgraph.draw(p_graph, wibox, cr, width, height)
    -- We want one pixel wide lines
    cr:set_line_width(1)
    -- Set the values we need
    local value = data[p_graph].value
    local props = helpers.load_properties(properties, data, p_graph, superproperties)    
    --Generate Background (background widget)
    if data[p_graph].background_color then
      helpers.draw_rounded_corners_rectangle( cr,
                                              0,
                                              0,
                                              width, 
                                              height,
                                              props.background_color, 
                                              props.rounded_size)
    end
  
    --draw a graph with graph_background_color
    if props.horizontal == true then
      helpers.draw_rounded_corners_horizontal_graph( cr,
                                        props.h_margin,
                                        props.v_margin,
                                        width - props.h_margin, 
                                        height - props.v_margin, 
                                        props.graph_background_color, 
                                        props.graph_color, 
                                        props.rounded_size, 
                                        value,
                                        props.graph_line_color)

    else
       helpers.draw_rounded_corners_vertical_graph( cr,
                                        props.h_margin,
                                        props.v_margin,
                                        width - props.h_margin, 
                                        height - props.v_margin, 
                                        props.graph_background_color, 
                                        props.graph_color, 
                                        props.rounded_size, 
                                        value,
                                        props.graph_line_color)
    end 

    if props.show_text == true then
        cr:set_font_size(props.font_size)

        if type(props.font) == "string" then
          cr:select_font_face(props.font,nil,nil)
        elseif type(props.font) == "table" then
          cr:select_font_face(props.font.family or "Sans", props.font.slang or
"normal", props.font.weight or "normal")
        end
        
        local value = string.format(props.value_format, data[p_graph].value * 100)
        if data[p_graph].label then
            text=string.gsub(data[p_graph].label,"$percent", value)
        else
            text=value .. "%"
        end
        --if vertical graph, text is at the middle of the width, if vertical bar text is at the middle of the height
        if props.horizontal == nil or props.horizontal == false then
        helpers.draw_text_and_background(cr, 
                                        props.text, 
                                        width/2, 
                                        height/2 , 
                                        props.text_background_color, 
                                        props.text_color,
                                        true,
                                        true,
                                        false,
                                        false)
        else
        helpers.draw_text_and_background(cr, 
                                        props.text, 
                                        props.h_margin, 
                                        height/2 , 
                                        props.text_background_color, 
                                        props.text_color,
                                        false,
                                        true,
                                        false,
                                        false)
        end     
    end
end

function progressgraph.fit(p_graph, width, height)
    return data[p_graph].width, data[p_graph].height
end

--- Set the p_graph value.
-- @param p_graph The progress bar.
-- @param value The progress bar value between 0 and 1.
function set_value(p_graph, value)
    if not p_graph then return end
    local value = value or 0
    local max_value = data[p_graph].max_value or 1
    data[p_graph].value = math.min(max_value, math.max(0, value))
    p_graph:emit_signal("widget::updated")
    return p_graph
end

--- Set the p_graph height.
-- @param height The height to set.
function progressgraph:set_height( height)
    data[self].height = height
    self:emit_signal("widget::updated")
    return self
end

--- Set the p_graph width.
-- @param width The width to set.
function progressgraph:set_width( width)
    data[self].width = width
    self:emit_signal("widget::updated")
    return self
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not progressgraph["set_" .. prop] then
        progressgraph["set_" .. prop] = function(p_graph, value)
            data[p_graph][prop] = value
            p_graph:emit_signal("widget::updated")
            return p_graph
        end
    end
end

--- Create a p_graph widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set p_graph geometry.
-- @return A p_graph widget.
function progressgraph.new(args)

    local args = args or {}
    
    args.width = args.width or 100
    args.height = args.height or 20

    if args.width < 5 or args.height < 5 then return end

    local p_graph = base.make_widget()

    data[p_graph] = {}

    for _, v in ipairs(properties) do
      data[p_graph][v] = args[v] 
    end

    data[p_graph].value = 0
    data[p_graph].max_value = 1

    -- Set methods
    for _, prop in ipairs(properties) do
        p_graph["set_" .. prop] = progressgraph["set_" .. prop]
    end

    p_graph.set_value = set_value
    p_graph.add_value = set_value
    p_graph.draw = progressgraph.draw
    p_graph.fit = progressgraph.fit

    return p_graph
end

function progressgraph.mt:__call(...)
    return progressgraph.new(...)
end
return setmetatable(progressgraph, progressgraph.mt)

-- vim: filetype=lua:expandtab:shiftwidth=2:tabstop=8:softtabstop=2:textwidth=80
