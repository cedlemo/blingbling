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

local widgetname = { mt = {} }

local data = setmetatable({}, { __mode = "k" })
local properties = {}

function widgetname.draw(graphtype, wibox, cr, width, height)

    local v_margin =  superproperties.v_margin 
    if data[p_graph].v_margin and data[p_graph].v_margin <= data[p_graph].height/4 then 
        v_margin = data[p_graph].v_margin 
    end
    
    local h_margin = superproperties.h_margin
    if data[p_graph].h_margin and data[p_graph].h_margin <= data[p_graph].width / 3 then 
        h_margin = data[p_graph].h_margin 
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

end

function widgetname.fit(graphtype, width, height)
    return data[graphtype].width, data[graphtype].height
end

--- Add a value to the graphtype
-- For compatibility between old and new awesome widget, add_value can be replaced by set_value
-- @usage mygraph:add_value(a) or mygraph:set_value(a)
-- @param graphtype The graphtype.
-- @param value The value between 0 and 1.
-- @param group The stack color group index.
local function add_value(graphtype, value, group)
    if not graph then return end

    local value = value or 0
    local values = data[graphtype].values
   
    if string.find(value, "nan") then
       value=0
    end
   
    local values = data[graphtype].values
    table.remove(values, #values)
    table.insert(values,1,value)
   
    graphtype:emit_signal("widget::updated")
    return graphtype
end
--or
--- Set the graphtype value.
-- @param p_graph The progress bar.
-- @param value The progress bar value between 0 and 1.
local function set_value(graphtype, value)
    local value = value or 0
    local max_value = data[graphtype].max_value
    data[graphtype].value = math.min(max_value, math.max(0, value))
    graphtype:emit_signal("widget::updated")
    return graphtype
end

--- Set the graphtype height.
-- @param graphtype The graph.
-- @param height The height to set.
function widgetname:set_height( height)
    if height >= 5 then
        data[self].height = height
        self:emit_signal("widget::updated")
    end
    return self
end

--- Set the graph width.
-- @param graph The graph.
-- @param width The width to set.
function widgetname:set_width( width)
    if width >= 5 then
        data[self].width = width
        self:emit_signal("widget::updated")
    end
    return self
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not widgetname["set_" .. prop] then
        widgetname["set_" .. prop] = function(graphtype, value)
            data[graphtype][prop] = value
            graphtype:emit_signal("widget::updated")
            return graphtype
        end
    end
end

--- Create a graphtype widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set graph geometry.
-- @return A graph widget.
function widgetname.new(args)
    
    local args = args or {}

    args.width = args.width or 100
    args.height = args.height or 20

    if args.width < 5 or args.height < 5 then return end

    local graphtype = base.make_widget()
    
    data[graphtype] = {}

    for _, v in ipairs(properties) do
      data[graphtype][v] = args[v] 
    end

    data[graphtype].values = {}
    --or
    data[graphtype].value = 0
    data[graphtype].max_value = 1
    -- Set methods
    graphtype.set_value = add_value
    graphtype.add_value = add_value
    graphtype.draw = widgetname.draw
    graphtype.fit = widgetname.fit

    for _, prop in ipairs(properties) do
        graphtype["set_" .. prop] = widgetname["set_" .. prop]
    end

    return graphtype
end

function widgetname.mt:__call(...)
    return widgetname.new(...)
end

return setmetatable(widgetname, widgetname.mt)

