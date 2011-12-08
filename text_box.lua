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
local cairo = require "oocairo"
---A simple text box with custumizable backrgound 
module("blingbling.text_box")

local data = setmetatable({}, { __mode = "k" })

---Fill all the widget with this color (default is transparent).
--@usage myt_box:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@param t_box the value text box
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set a border (width * height) with this color (default is none ) 
--@usage myt_box:set_background_border(string) -->"#rrggbbaa"
--@name set_background_border
--@class function
--@t_box t_box the t_box
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the padding between the text and it's background
--@usage myt_box:set_padding(integer) 
--@name set_padding
--@class function
--@param t_box the value text box
--@param padding an integer for the text padding

---Set rounded corners for background and text background
--@usage myt_box:set_rounded_size(a) -> a in [0,1]
--@name set_rounded_size
--@class function
--@param t_box the value text box
--@param rounded_size float in [0,1]

---Define the color for the text of the widget (white by default)
--@usage myt_box:set_text_color(string) -->"#rrggbbaa"
--@name set_text_color
--@class function
--@param t_box the value text box
--@param color a string "#rrggbbaa" or "#rrggbb

---Define the text font size
--@usage myt_box:set_font_size(integer)
--@name set_font_size
--@class function
--@param t_box the value text box
--@param size the font size


local properties = {    "width", "height", "padding",
                        "background_border", "background_color",
                        "rounded_size", "text_color",  
                        "font_size", "text"
                   }

function draw(t_box, wibox, cr, width, height)
  local padding = data[t_box].padding or 2
  local background_color = data[t_box].background_color or "#000000aa"
  local text_color = data[t_box].text_color or "#ffffffff"
  local font_size = data[t_box].font_size or 9
  local rounded_size = data[t_box].rounded_size or 0
  local border = data[t_box].background_border or nil
  local geometries = helpers.generate_rounded_rectangle_with_text( cr, 
                                        width,
                                        height,
                                        data[t_box].text, 
                                        padding,
                                        background_color,
                                        text_color,
                                        font_size,
                                        rounded_size,
                                        border
                                        )

  --Part that manage the auto-size of the widget
  if geometries.width >data[t_box].width then data[t_box].width= geometries.width end
  if geometries.height > data[t_box].height then data[t_box].height= geometries.height end
  return t_box
end

local function get_geometries(t_box, cr, width, height)
  local padding = data[t_box].padding or 2
  local background_color = data[t_box].background_color or "#000000aa"
  local text_color = data[t_box].text_color or "#ffffffff"
  local font_size = data[t_box].font_size or 9
  local rounded_size = data[t_box].rounded_size or 0
  local border = data[t_box].background_border or nil
  local geometries = helpers.generate_rounded_rectangle_with_text( cr, 
                                        width,
                                        height,
                                        data[t_box].text, 
                                        padding,
                                        background_color,
                                        text_color,
                                        font_size,
                                        rounded_size,
                                        border
                                        )

   return geometries
end

function fit(t_box, width, height)
    local geometries={}
    
    local surface=cairo.image_surface_create("argb32",data[t_box].width, data[t_box].height)
    local cr = cairo.context_create(surface)

    geometries = get_geometries(t_box, cr, data[t_box].width, data[t_box].height)
    data[t_box].width = geometries.width 
    data[t_box].height = geometries.height
    
    return data[t_box].width, data[t_box].height
end

function set_height(t_box, height)
    if height >= 5 then
        data[t_box].height = height
        t_box:emit_signal("widget::updated")
    end
    return t_box
end

function set_width(t_box, width)
    if width >= 5 then
        data[t_box].width = width
        t_box:emit_signal("widget::updated")
    end
    return t_box
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(t_box, value)
            data[t_box][prop] = value
            t_box:emit_signal("widget::updated")
            return t_box
        end
    end
end

--- Create a t_box widget.
-- @usage myt_box=blingbling.text_box.new({text = "your text" })
-- @param text a table : { text = your_text } No need to set width or height, it depends on padding, font size and text length. But you can set a bigger width/height and the text will be centered.
-- @return A t_box widget.
function new(args)
    local args = args or {}
    local t_box = base.make_widget()
    data[t_box]={}

    local width = args.width or 5
    local height = args.height or 5
    data[t_box].width = width 
    data[t_box].height = height
    
    --local text = args.text or "none"
    data[t_box].text = args.text or "none"

    if width < 5 or height < 5 then return end

    -- Set methods
    t_box.draw = draw
    t_box.fit = fit
    
    for _, prop in ipairs(properties) do
        t_box["set_" .. prop] = _M["set_" .. prop]
    end

    return t_box
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })

