-- @author cedlemo

local setmetatable = setmetatable
local ipairs = ipairs
local math = math
--local table = table
local type = type
local string = string
local color = require("gears.color")
local base = require("wibox.widget.base")
local helpers = require("blingbling.helpers")
local superproperties = require('blingbling.superproperties')

---Triangular progress graph widget.
--@module blingbling.triangular_progress_graph

---Fill all the widget (width * height) with this color (default is transparent ).
--@usage mypgraph:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the form of the graph: use five growing bars instead of a triangle.
--@usage mypgraph:set_bar(boolean) --> true or false
--@name set_bar
--@class function
--@param boolean true or false (default is false)

---Define the top and bottom margin for the graph.
--@usage mypgraph:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param margin an integer for top and bottom margin

---Define the left and right margin for the graph.
--@usage mypgraph:set_h_margin(integer)
--@name set_h_margin
--@class function
--@param margin an integer for left and right margin

---Set the color of the graph background.
--@usage mypgraph:set_graph_background_color(string) -->"#rrggbbaa"
--@name set_graph_background_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

----Define the graph color.
--@usage mypgraph:set_graph_color(string) -->"#rrggbbaa"
--@name set_graph_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

----Define the color of the outline of the graph.
--@usage mypgraph:set_graph_line_color(string) -->"#rrggbbaa"
--@name set_graph_line_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Display text on the graph or not.
--@usage mypgraph:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param boolean true or false (default is false)

---Define displayed text value format string
--@usage mypgraph:set_value_format(string) --> "%2.f"
--@name set_value_format
--@class function
--@param printf format string for display text

---Define the color of the text.
--@usage mypgraph:set_text_color(string) -->"#rrggbbaa"
--@name set_text_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb" defaul is white

---Define the background color of the text.
--@usage mypgraph:set_text_background_color(string) -->"#rrggbbaa"
--@name set_text_background_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the text font size.
--@usage mypgraph:set_font_size(integer)
--@name set_font_size
--@class function
--@param size the font size

---Define the text font.
--@usage mypgraph:set_font(string|table)
--The argument can be a string for the font name or a table
--that  contains the cairo font informations
--@name set_font
--@class function
--@param the font to use

---Define the template of the text to display.
--@usage mypgraph:set_label(string)
--By default the text is : (value_send_to_the_widget *100) .. "%"
--static string: example set_label("Volume:") will display "Volume:" on the graph
--dynamic string: use $percent in the string example set_label("Volume $percent %") will display "Volume 10%"
--@name set_label
--@class function
--@param text the text to display

local triangular_progressgraph = { mt = {} }

local data = setmetatable({}, { __mode = "k" })
local properties = {"width", "height", "v_margin", "h_margin",
                    "background_color", "graph_background_color",
                    "graph_color","graph_line_color","show_text",
                    "text_color", "text_background_color",
                    "label", "font_size","font", "bar", "value_format"
                    }
function triangular_progressgraph.draw(tp_graph, wibox, cr, width, height)

  local props = helpers.load_properties(properties, data, tp_graph, superproperties)
--Generate Background (background color and Tiles)
    local r,g,b,a = helpers.hexadecimal_to_rgba_percent(props.background_color)
    cr:set_source_rgba(r,g,b,a)
    cr:paint()

  --Draw the background of the graph:
  if props.bar == true then
      helpers.draw_triangle_using_bars( cr, width,
                                        height,
                                        props.h_margin,
                                        props.v_margin,
                                        props.graph_background_color)

      helpers.draw_triangle_graph_using_bars(cr, width,
                                              height,
                                              props.h_margin,
                                              props.v_margin,
                                              props.graph_color,
                                              data[tp_graph].value
                                              )

  else
    --Draw graph background
    local first   = { x = props.h_marging,
                      y = height - props.v_margin }
    local y_range = height - (2 * props.v_margin)
    local second  = { x = width - props.h_margin,
                      y = height - (props.v_margin + y_range) }
    local third   = { x = width  - props.h_margin,
                      y = height - props.v_margin }

    helpers.draw_triangle(cr, first, second, third, props.graph_background_color)

    if data[tp_graph].value > 0 then
      --Draw graph
      second = { x = width * data[tp_graph].value - props.h_margin,
                 y = height -( props.v_margin + (y_range * data[tp_graph].value)) }
      third  = { x = width * data[tp_graph].value - props.h_margin,
                 y = height - props.v_margin }

      helpers.draw_triangle(cr, first, second, third, props.graph_color)

      helpers.draw_triangle_outline(cr, first, second, third, props.graph_line_color)
    end
  end
--Draw Text and it's background
  if props.show_text == true  then

    local font
    if type(props.font) == "string" then
      font = props.font .. " " .. props.font_size
    elseif type(props.font) == "table" then
      font = (props.font.family or "Sans") .. " " .. (props.font.slang or "normal") .. " " .. (props.font.weight or "normal") .. " " .. props.font_size
    end


    local value = string.format(props.value_format,
                                data[tp_graph].value * 100)

    if props.label then
      text = string.gsub(props.label,"$percent", value)
    else
      text = value .. "%"
    end
    helpers.draw_layout_and_background(cr,
                                       text,
                                       props.h_margin,
                                       height/2 ,
                                       font,
                                       props.text_background_color,
                                       props.text_color,
                                       "start",
                                       "middle")
  end
end


function triangular_progressgraph.fit(tp_graph, width, height)
    return data[tp_graph].width, data[tp_graph].height
end

---Set the tp_graph value.
--@param tp_graph The progress bar.
--@param value The progress bar value between 0 and 1.
local function set_value(tp_graph, value)
  local value = value or 0
  local max_value = data[tp_graph].max_value
  data[tp_graph].value = math.min(max_value, math.max(0, value))
  tp_graph:emit_signal("widget::updated")
  return tp_graph
end

---Set the tp_graph height.
-- @param height The height to set.
function triangular_progressgraph:set_height( height)
  if height >= 5 then
    data[self].height = height
    self:emit_signal("widget::updated")
  end
  return self
end

---Set the tp_graph width.
--@param width The width to set.
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
