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

local circle_graph = { mt = {} }

---Circle graph from wlourf.
--@module blingbling.wlourf_circle_graph

---Set the radius of the circle.
--@usage circle:set_radius(integer)
--@name set_radius
--@class function
--@param radius an integer value for the radius of the circle

---Set the default color for the graph.
--@usage circle:set_graph_color(string) -->"#rrggbbaa"
--@name set_graph_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb" 

---Set the colors and theirs ranges for the graph.
--@usage circle:set_graph_colors({{"#88aa00ff",0}, --all value > 0 will be displayed using this color
--{"#d4aa00ff", 0.5},
--{"#d45500ff",0.77}})
--@name set_graph_colors
--@class function
--@param colors a table of tables {color , float } with color a string "#rrggbbaa" or "#rrggbb" and float which is 0<=float<=1

---Display text on the graph or not.
--@usage circle:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param boolean true or false (default is false)

---Define the text's font .
--@usage circle:set_font(string)
--@name set_font
--@class function
--@param font a string that contains the font name family and weight

---Define the text font size.
--@usage circle:set_font_size(integer)
--@name set_font_size
--@class function
--@param size the font size

---Define the text to display.
--@usage circle:set_label(string)
--@name set_label
--@class function
--@param text the text to display


local data = setmetatable({}, { __mode = "k" })
local properties = {"width", "height", "radius", "graph_colors", "graph_color", "show_text", "font_size", "font", "label"}

function circle_graph.draw(c_graph, wibox, cr, width, height)

  local props = helpers.load_properties(properties, data, c_graph, superproperties)

  local value = data[c_graph].value
  local line_width = 1
  local radius = props.radius or height/2 - line_width
  local yy = ( height )/2
  local xx = radius + line_width
  local graph_color = props.graph_color
  
  if props.graph_colors  and type(props.graph_colors) == "table" then
    for i,table in ipairs(props.graph_colors) do
      if i == 1 then 
        if value >= table[2] then
          graph_color = table[1]
        end
      elseif i ~= 1 then
        if value >= table[2]  then
          graph_color = table[1]
        end
      end
    end
  end

  r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_color)
  cr:set_source_rgba(r,g,b,a)

  local te
  
  if props.show_text == true and props.label ~= nil then
    cr:set_font_size(props.font_size)

    if type(props.font) == "string" then
      cr:select_font_face(props.font,nil,nil)
    elseif type(props.font) == "table" then
      cr:select_font_face(props.font.family or "Sans",
                          props.font.slang or "normal",
                          props.font.weight or "normal")
    end
    
    te=cr:text_extents(props.label)
    cr:save()
    cr:translate(-te["y_bearing"] ,
                 (height + te["x_advance"] + te["x_bearing"])/2)
    cr:rotate(-math.pi/2)
    cr:show_text(props.label)
    cr:stroke()	
    cr:restore()
    xx= te["height"] - te["y_bearing"] + radius 
    width = te["height"] - te["y_bearing"] + radius*2 
  end
  

  cr:set_line_cap("butt")
  cr:set_line_width(line_width)
  cr:arc(xx,yy,radius,0,2*math.pi)
  cr:stroke()
  cr:move_to(xx,yy)
  cr:arc_negative(xx,yy,radius,0,-2*math.pi*value)
  cr:fill()
end

function circle_graph.fit(c_graph, width, height)
    return data[c_graph].width, data[c_graph].height
end

--- Set the c_graph value.
-- @param c_graph The progress bar.
-- @param value The progress bar value between 0 and 1.
local function set_value(c_graph, value)
    local value = value or 0
    local max_value = data[c_graph].max_value
    data[c_graph].value = math.min(max_value, math.max(0, value))
    c_graph:emit_signal("widget::updated")
    return c_graph
end

--- Set the c_graph height.
-- @param height The height to set.
function circle_graph:set_height( height)
    if height >= 5 then
        data[self].height = height
        self:emit_signal("widget::updated")
    end
    return self
end

--- Set the graph width.
-- @param width The width to set.
function circle_graph:set_width( width)
    if width >= 5 then
        data[self].width = width
        self:emit_signal("widget::updated")
    end
    return self
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not circle_graph["set_" .. prop] then
        circle_graph["set_" .. prop] = function(c_graph, value)
            data[c_graph][prop] = value
            c_graph:emit_signal("widget::updated")
            return c_graph
        end
    end
end

--- Create a c_graph widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set graph geometry.
-- @return A graph widget.
function circle_graph.new(args)
    
    local args = args or {}

    args.width = args.width or 100
    args.height = args.height or 20

    if args.width < 5 or args.height < 5 then return end

    local c_graph = base.make_widget()
    
    data[c_graph] = {}

    for _, v in ipairs(properties) do
      data[c_graph][v] = args[v] 
    end

    data[c_graph].value = 0
    data[c_graph].max_value = 1
    -- Set methods
    c_graph.set_value = set_value
    c_graph.add_value = set_value
    c_graph.draw = circle_graph.draw
    c_graph.fit = circle_graph.fit

    for _, prop in ipairs(properties) do
        c_graph["set_" .. prop] = circle_graph["set_" .. prop]
    end

    return c_graph
end

function circle_graph.mt:__call(...)
    return circle_graph.new(...)
end

return setmetatable(circle_graph, circle_graph.mt)

