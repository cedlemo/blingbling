local helpers =require("blingbling.helpers")
local string = require("string")
local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local table =table
local type=type
local cairo = require("oocairo")
local capi = { image = image, widget = widget }
local layout = require("awful.widget.layout")

module("blingbling.value_text_box")

local data = setmetatable({}, { __mode = "k" })

local properties = { "width", "height", "v_margin", "h_margin","padding", "background_color","rounded_size", "filled", "filled_color", "default_text_color", "values_text_color", "label", "font_size",}

local function update(vt_box)
  
  local vt_box_surface=cairo.image_surface_create("argb32",50, 20)
  local vt_box_context = cairo.context_create(vt_box_surface)
    
  local v_margin =  2 
  if data[vt_box].v_margin and data[vt_box].v_margin <= data[vt_box].height/4 then 
    v_margin = data[vt_box].v_margin 
  end
  local h_margin = 2
  if data[vt_box].h_margin and data[vt_box].h_margin <= data[vt_box].width / 3 then 
    h_margin = data[vt_box].h_margin 
  end
  local padding = data[vt_box].padding or 2
  local font_size = data[vt_box].font_size or 9
  --find the width of our image
  local value = data[vt_box].value * 100
  local label = data[vt_box].label or "$percent"
  local text = string.gsub(label,"$percent", value)
  vt_box_context:set_font_size(font_size)
  local ext = vt_box_context:text_extents(text)
  local height = font_size + 2* padding + 2* v_margin
  local width = math.ceil(ext.width +2*ext.x_bearing+ 2*padding + 2* h_margin)

  if data[vt_box].width == nil or data[vt_box].width < width then
    data[vt_box].width = width
  end
  if data[vt_box].height == nil or data[vt_box].height < height then
    data[vt_box].height = height
  end
  vt_box_surface=cairo.image_surface_create("argb32",data[vt_box].width, data[vt_box].height)
  vt_box_context = cairo.context_create(vt_box_surface)
  
  local rounded_size = data[vt_box].rounded_size or 0
  
--Generate Background (background widget)
  if data[vt_box].background_color then
    helpers.draw_rounded_corners_rectangle( vt_box_context,
                                            0,
                                            0,
                                            data[vt_box].width, 
                                            data[vt_box].height,
                                            data[vt_box].background_color, 
                                            rounded_size )
  
  end
  
  --Draw nothing, or filled ( value background)
  if data[vt_box].filled  == true then
    if data[vt_box].filled_color then
      background_color = data[vt_box].filled_color  
    else
      background_color = "#00000066"
    end
    --draw rounded corner rectangle
    local x=h_margin
    local y=v_margin
    
    helpers.draw_rounded_corners_rectangle( vt_box_context,
                                            x,
                                            y,
                                            data[vt_box].width - h_margin, 
                                            data[vt_box].height - v_margin, 
                                            background_color, 
                                            rounded_size)
  end  
    --draw the value

    --get the colors used to display the value

    --analyse the label :
    label_parts={}
    label_length = string.len(label)
    value_start, value_finish = string.find(label, "$percent")
    table.insert(label_parts,{1, value_start -1})
    table.insert(label_parts,{value_start, value_finish,is_value = true})
    local new_start = value_finish + 1
    if value_finish < label_length then
      while value_start ~= nil do
        value_start, value_finish = string.find(label, "$percent", new_start)
        if value_start ~=nil and value_start ~= new_start then
          table.insert(label_parts,{new_start, value_start -1})
          table.insert(label_parts,{value_start, value_finish, is_value = true})
          new_start = value_finish + 1
        elseif value_start == new_start then
          table.insert(label_parts,{value_start, value_finish, is_value = true})
          new_start = value_finish + 1
        end
      end
      --if rest char:
      if label_parts[#label_parts][2] < label_length then
        table.insert(label_parts,{label_parts[#label_parts][2] + 1, label_length})
      end
    end
    x= h_margin + padding
    y= 0 
    --Draw the text:

    local default_text_color = data[vt_box].default_text_color or "#ffffffff"
    local value_text_color = default_text_color 
    if data[vt_box].values_text_color  and type(data[vt_box].values_text_color) == "table" then
      for i,table in ipairs(data[vt_box].values_text_color) do
        if i == 1 then 
          if data[vt_box].value >= table[2] then
            value_text_color = table[1]
          end
        elseif i ~= 1 then
          if data[vt_box].value >= table[2]  then
            value_text_color = table[1]
          end
        --elseif i == #data[vt_box].values_text_color then
        --  if data[vt_box].value > data[vt_box].values_text_color[i-1][2] and data[vt_box].value <=table[2] then
        --    value_text_color = table[1]
        --  end
        end
      end
    end
    for i,range in ipairs(label_parts) do
      if range.is_value then 
        text = value
        --dirty trick : if there are spaces at the end of cairo text, they aren't represented so I put them at the begining of the value:
        for j=range[1],label_parts[i-1][1], -1 do
          if string.sub(label, j,j) == " " then
            text = " " .. text
          end
        end
        r,g,b,a = helpers.hexadecimal_to_rgba_percent(value_text_color)
        vt_box_context:set_source_rgba(r,g,b,a)
        ext = vt_box_context:text_extents(text)
        y=data[vt_box].height/2 + font_size/2 - padding/2 
        vt_box_context:move_to(x,y)
        vt_box_context:show_text(text)
        x=x+ext.width + ext.x_bearing
      else
        text=string.sub(label, range[1],range[2])
        text=string.gsub(text, "(.*[^%s]*)(%s*)","%1")
        r,g,b,a = helpers.hexadecimal_to_rgba_percent(default_text_color)
        vt_box_context:set_source_rgba(r,g,b,a)
        ext = vt_box_context:text_extents(text)
       
        y=data[vt_box].height/2 + font_size/2 - padding/2 
 
        vt_box_context:move_to(x,y)
        vt_box_context:show_text(text)
        x=x+ext.width --+ext.x_bearing
      end
    end

  vt_box.widget.image = capi.image.argb32(data[vt_box].width, data[vt_box].height, vt_box_surface:get_data())

end

local function add_value(vt_box, value)
  if not vt_box then return end
  local value = value or 0

  if string.find(value, "nan") then
    value=0
  end

  data[vt_box].value = value
  
  update(vt_box)
  return vt_box
end

function set_height(vt_box, height)
    if height >= 5 then
        data[vt_box].height = height
        update(vt_box)
    end
    return vt_box
end

function set_width(vt_box, width)
    if width >= 5 then
        data[vt_box].width = width
        update(vt_box)
    end
    return vt_box
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(vt_box, value)
            data[vt_box][prop] = value
            update(vt_box)
            return vt_box
        end
    end
end

function new(args)
    local args = args or {}
    args.type = "imagebox"

    local width = args.width or 100 
    local height = args.height or 20

    if width < 6 or height < 6 then return end

    local vt_box = {}
    vt_box.widget = capi.widget(args)
    vt_box.widget.resize = false

    data[vt_box] = { width = width, height = height, value = 0 }

    -- Set methods
    vt_box.add_value = add_value

    for _, prop in ipairs(properties) do
        vt_box["set_" .. prop] = _M["set_" .. prop]
    end

    vt_box.layout = args.layout or layout.horizontal.leftright

    return vt_box
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
