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
local superproperties = require("blingbling.superproperties")
local lgi = require("lgi")
local pango = lgi.Pango
local pangocairo = lgi.PangoCairo
local util = require('awful.util')
---A text box.  
--@module blingbling.text_box
local text_box = { mt = {} }
local data = setmetatable({}, { __mode = "k" })

---Fill all the widget with this color (default is transparent).
--@usage myt_box:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@param t_box the value text box
--@param color a string "#rrggbbaa" or "#rrggbb"

---Fill the text area (text height/width + padding) background with this color (default is none).
--@usage myt_box:set_text_background_color(string) -->"#rrggbbaa"
--@name set_text_background_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set a border on the text area background (default is none ). 
--@usage myt_box:set_text_background_border(string) -->"#rrggbbaa"
--@name set_text_background_border
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the top and bottom margin for the text background .
--@usage myt_box:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param t_box the value text box
--@param margin an integer for top and bottom margin

---Define the left and right margin for the text background.
--@usage myt_box:set_h_margin(integer) 
--@name set_h_margin
--@class function
--@param t_box the value text box
--@param margin an integer for left and right margin

---Set rounded corners for background and text background.
--@usage myt_box:set_rounded_size(a) -> a in [0,1]
--@usage myt_box:set_rounded_size(b) -> b = { 0.2,0.3,0.4,0.7}
--@name set_rounded_size
--@class function
--@param t_box the value text box
--@param rounded_size float in [0,1] or a table of 4 float for each corners.

---Define the color of the text.
--@usage myt_box:set_text_color(string) 
--@name set_text_color
--@class function
--@param t_box the value text box
--@param color a string "#rrggbb" 

---Define the text font size.
--@usage myt_box:set_font_size(integer)
--@name set_font_size
--@class function
--@param t_box the value text box
--@param size the font size

local properties = {    "width", "height", "h_margin", "v_margin", 
                        "background_color", 
                        "background_text_border", "text_background_color",
                        "rounded_size", "text_color", "font_size", "font"
                   }

 -- Setup a pango layout for the given textbox and cairo context
local function setup_layout(t_box, width, height)
	local layout = t_box._layout
  layout.width = pango.units_from_double(width)
  layout.height = pango.units_from_double(height)
end

local function draw( t_box, wibox, cr, width, height)

  local props = helpers.load_properties(properties, data, t_box, superproperties)
  local text = data[t_box].text

  if type(props.font) ~= "string" and type(props.font) == "table" then
    font = (props.font.family or "Sans") ..(props.font.slang or "normal") ..( props.font.weight or "normal")
  end
  
	layout = t_box._layout
	cr:update_layout(layout)
	local font_desc = pango.FontDescription.from_string(props.font .. " " .. props.font_size)
	layout:set_font_description(font_desc)
	layout.text = text
  layout:set_markup("<span color='".. props.text_color .."'>"..text.."</span>" )
  local _, logical = layout:get_pixel_extents()
  
	local width = data[t_box].width > logical.width and data[t_box].width or logical.width
  local height = data[t_box].height > logical.height and data[t_box].height or logical.height

	setup_layout(t_box, width, height)
  
	--Generate Background (background widget)
  if data[t_box].background_color then
    helpers.draw_rounded_corners_rectangle( cr,
                                            0,
                                            0,
                                            width, 
                                            height,
                                            props.background_color, 
                                            props.rounded_size)
  end
  
  --Draw nothing, or filled ( value background)
  if data[t_box].text_background_color then
    --draw rounded corner rectangle
    local x = props.h_margin
    local y = props.v_margin
    
    helpers.draw_rounded_corners_rectangle( cr,
                                            x,
                                            y,
                                            width - x, 
                                            height - y, 
                                            props.text_background_color, 
                                            props.rounded_size,
                                            props.background_text_border
                                            )
  end  
	local x_offset, y_offset = 0
	if logical.width < data[t_box].width then
		x_offset = (data[t_box].width - logical.width)/2
	end
 	if logical.height < data[t_box].height then
		y_offset = (data[t_box].height - logical.height)/2
	end
	cr:move_to(x_offset,y_offset)
	cr:show_layout(layout)
end

function text_box:fit( width, height)
	setup_layout(self, width, height)
  
  local props = helpers.load_properties(properties, data, self, superproperties)
	local font_desc = pango.FontDescription.from_string(props.font .. " " .. props.font_size)
  local text = data[self].text or ""
  self._layout:set_font_description(font_desc)
  if props.text_color then
    self._layout:set_markup("<span color='"..props.text_color.."'>"..text.."</span>" )
	else
    self._layout:set_markup(text)
  end
  local _, logical = self._layout:get_pixel_extents()
	local width, height
	width = logical.width > data[self].width and logical.width or data[self].width
	height = logical.height > data[self].height and logical.height or data[self].height
	
	if logical.width == 0 or logical.height == 0 then
		width = 0
		height = 0
	end
	return width, height
end

--- Add a text to the t_box.
-- @usage myt_box:set_text(a_text) 
-- @param t_box The t_box.
-- @param string a string.
local function set_text(t_box, string)
    if not t_box then return end

		local text = string or ""
		
    data[t_box].text = text
		t_box._layout.text = text
    t_box:emit_signal("widget::updated")
    return t_box
end


--- Set the t_box height.
-- @param height The height to set.
function text_box:set_height( height)
    if height >= 5 then
        data[self].height = height
        self:emit_signal("widget::updated")
    end
    return self
end

--- Set the t_box width.
-- @param width The width to set.
function text_box:set_width( width)
    if width >= 5 then
        data[self].width = width
        self:emit_signal("widget::updated")
    end
    return self
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not text_box["set_" .. prop] then
        text_box["set_" .. prop] = function(t_box, value)
            data[t_box][prop] = value
            t_box:emit_signal("widget::updated")
            return t_box
        end
    end
end

--- Create a t_box widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set t_box geometry.
-- @return A t_box widget.
function text_box.new(args)
    local args = args or {}

    local width = args.width or 5 
    local height = args.height or 5

    if width < 5 or height < 5 then return end

    local t_box = base.make_widget()
    data[t_box] = {}
    
		data[t_box].text = args.text or ""

		for _, v in ipairs(properties) do
      data[t_box][v] = args[v] 
    end
    data[t_box].height = height
		data[t_box].width = width    
		
		local ctx = pangocairo.font_map_get_default():create_context()
    t_box._layout = pango.Layout.new(ctx)

    -- Set methods
    t_box.set_text = set_text
    t_box.draw = draw
    t_box.fit = text_box.fit

    for _, prop in ipairs(properties) do
        t_box["set_" .. prop] = text_box["set_" .. prop]
    end

    return t_box
end
function text_box.mt:__call(...)
    return text_box.new(...)
end

return setmetatable(text_box, text_box.mt)
