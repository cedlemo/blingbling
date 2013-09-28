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

---Define the top and bottom margin for the graph area.
--@usage circle:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param margin an integer for top and bottom margin

---Define the left and right margin for the graph area.
--@usage circle:set_h_margin()
--@name set_h_margin
--@class function 
--@param margin an integer for left and right margin

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
local properties = {"width", "height", "h_margin", "v_margin", "radius", "graph_colors", "graph_color", "show_text", "font_size", "font", "label"}

function circle_graph.draw(c_graph, wibox, cr, width, height)

    local v_margin =  superproperties.v_margin 
    if data[c_graph].v_margin and data[c_graph].v_margin <= data[c_graph].height/4 then 
        v_margin = data[c_graph].v_margin 
    end
    
    local h_margin = superproperties.h_margin
    if data[c_graph].h_margin and data[c_graph].h_margin <= data[c_graph].width / 3 then 
        h_margin = data[c_graph].h_margin 
    end

    local graph_color = data[c_graph].graph_color or superproperties.graph_color
    
    local font_size =data[c_graph].font_size or superproperties.font_size
    local font = data[c_graph].font or superproperties.font
    local value = data[c_graph].value * 100
    local line_width = 1
    local radius = data[c_graph].radius or height/2-line_width
	  local yy = ( height - (v_margin*2))/2
	  local xx = radius+line_width
	  local w=height*2

    if data[c_graph].graph_colors  and type(data[c_graph].graph_colors) == "table" then
      for i,table in ipairs(data[c_graph].graph_colors) do
        if i == 1 then 
          if value/100 >= table[2] then
            graph_color = table[1]
          end
        elseif i ~= 1 then
          if value/100 >= table[2]  then
            graph_color = table[1]
          end
        end
      end
    end

    r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_color)
    cr:set_source_rgba(r,g,b,a)
    if data[c_graph].show_text == true and data[c_graph].label ~= nil then
      cr:set_font_size(font_size)

      if type(font) == "string" then
        cr:select_font_face(font,nil,nil)
      elseif type(font) == "table" then
        cr:select_font_face(font.family or "Sans", font.slang or "normal", font.weight or "normal")
      end
      
      te=cr:text_extents(data[c_graph].label)
      cr:save()
      cr:translate(-te["y_bearing"]+h_margin,(height+te["x_advance"]+te["x_bearing"])/2)
      cr:rotate(-math.pi/2)
      cr:show_text(data[c_graph].label)
      cr:stroke()	
      cr:restore()
      xx= te["height"]-te["y_bearing"]+radius +h_margin
    end
    
    data[c_graph].width = te["height"]-te["y_bearing"]+radius*2 + h_margin*2

    cr:set_line_cap("butt")
	  cr:set_line_width(line_width)
	  cr:arc(xx,yy,radius,0,2*math.pi)
	  cr:stroke()
	  cr:move_to(xx,yy)
	  cr:arc_negative(xx,yy,radius,0,-2*math.pi*value/100)
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

