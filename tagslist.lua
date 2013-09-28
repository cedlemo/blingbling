--@author cedlemo
local capi = { screen = screen,
               awesome = awesome,
               client = client }
local type = type
local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local table = table
local common = require("awful.widget.common")
local util = require("awful.util")
local tag = require("awful.tag")
local beautiful = require("beautiful")
local wibox = require("wibox")
local fixed = require("wibox.layout.fixed")
local surface = require("gears.surface")
local helpers = require("blingbling.helpers")
local text_box = require("blingbling.text_box")
local superproperties = require("blingbling.superproperties")
---Tagslist widget. Based on the original taglist widget from awesome
--@module blingbling.tagslist

local taglist = { mt = {} }
taglist.filter = {}

local function taglist_customize(t, style)
		if (not style or (type(style) ~= "table")) then 
			style = {} 
		end
		local style_normal = {}
		local style_focus = {}
		local style_urgent = {}
		local style_occupied = {}
		
		if style.normal and type(style.normal) == "table" then	
			for k, v in pairs(superproperties.tagslist.normal) do	
				style_normal[v] = style.normal[v] or superproperties.tagslist.normal[v]
			end
		else
			style_normal = superproperties.tagslist.normal
		end
		
		if style.focus and type(style.focus) == "table" then	
			for k, v in pairs(superproperties.tagslist.focus) do	
				style_focus[v] = style.focus[v] or superproperties.tagslist.focus[v]
			end
		else
			style_focus = superproperties.tagslist.focus
		end
		
		if style.urgent and type(style.urgent) == "table" then	
			for k, v in pairs(superproperties.tagslist.urgent) do	
				style_urgent[v] = style.urgent[v] or superproperties.tagslist.urgent[v]
			end
		else
			style_urgent = superproperties.tagslist.urgent
		end
		
		if style.occupied and type(style.occupied) == "table" then	
			for k, v in pairs(superproperties.tagslist.occupied) do	
				style_occupied[v] = style.occupied[v] or superproperties.tagslist.occupied[v]
			end
		else
			style_occupied = superproperties.tagslist.occupied
		end
			
		local current_style = style_normal
		local theme = beautiful.get()
    local taglist_squares_sel = style.squares_sel or theme.taglist_squares_sel
    local taglist_squares_unsel = style.squares_unsel or theme.taglist_squares_unsel
    local taglist_squares_sel_empty = style.squares_sel_empty or theme.taglist_squares_sel_empty
    local taglist_squares_unsel_empty = style.squares_unsel_empty or theme.taglist_squares_unsel_empty
    local taglist_squares_resize = style.squares_resize or theme.taglist_squares_resize or true
    local taglist_disable_icon = style.taglist_disable_icon or theme.taglist_disable_icon or true
		local text = ""
    local sel = capi.client.focus
    local bg_image
    local icon
    local bg_resize = false
    local is_selected = false
    if t.selected then
			current_style = style_focus
		end

    if sel then
        if taglist_squares_sel then
            local seltags = sel:tags()
            for _, v in ipairs(seltags) do
                if v == t then
                    bg_image = taglist_squares_sel
                    bg_resize = taglist_squares_resize == "true"
                    is_selected = true
                    break
                end
            end
        end
    end
    if t:clients() == 0 and t.selected and taglist_squares_sel_empty then
        bg_image = taglist_squares_sel_empty
        bg_resize = taglist_squares_resize == "true"
    elseif not is_selected then
        local cls = t:clients()
        if #cls > 0 then
            if taglist_squares_unsel then
                bg_image = taglist_squares_unsel
                bg_resize = taglist_squares_resize == "true"
            end
            current_style = style_occupied
        else
            if taglist_squares_unsel_empty then
                bg_image = taglist_squares_unsel_empty
                bg_resize = taglist_squares_resize == "true"
            end
        end
        for k, c in pairs(cls) do
            if c.urgent then
                current_style = style_urgent
                break
            end
        end
    end
    if not tag.getproperty(t, "icon_only") then
           text = (util.escape(t.name) or "")
    end
    if not taglist_disable_icon then
        if tag.geticon(t) and type(tag.geticon(t)) == "image" then
            icon = tag.geticon(t)
        elseif tag.geticon(t) then
            icon = surface.load(tag.geticon(t))
        end
    end
		return text , current_style, bg_image, not taglist_disable_icon and icon or nil
end

local function taglist_update_style(w, buttons, style, data, tags)
    -- update the widgets, creating them if needed
    w:reset()
    for i, o in ipairs(tags) do
        local text, style, icon = taglist_customize(o, style)
				local cache = data[o]
        local ib, tb, bgb, m, l
        if cache then
            ib = cache.ib
            tb = cache.tb
            bgb = cache.bgb
            m   = cache.m
        else
            ib = wibox.widget.imagebox()
            tb = text_box(style)
            bgb = wibox.widget.background()
            m = wibox.layout.margin(tb, 2, 2)
            l = wibox.layout.fixed.horizontal()

            -- All of this is added in a fixed widget
            l:fill_space(true)
            l:add(ib)
            l:add(m)

            -- And all of this gets a background
            bgb:set_widget(l)

            bgb:buttons(common.create_buttons(buttons, o))

            data[o] = {
                ib = ib,
                tb = tb,
                bgb = bgb,
                m   = m
            }
        end
			  -- The text might be invalid, so use pcall
        if not pcall(tb.set_text, tb, text) then
            tb:set_text("<i>&lt;Invalid text&gt;</i>")
        end
				tb:set_h_margin(style.h_margin)
				tb:set_v_margin(style.v_margin)
				tb:set_rounded_size(style.rounded_size)
				tb:set_text_color(style.text_color)
				tb:set_font(style.font)
				tb:set_font_size(style.font_size)
				tb:set_background_color(style.background_color)
				tb:set_text_background_color(style.text_background_color)
				
				bgb:set_bg(bg)
        if type(bg_image) == "function" then
            bg_image = bg_image(tb,o,m,objects,i)
        end
        bgb:set_bgimage(bg_image)
        ib:set_image(icon)
        w:add(bgb)
   end
end

local function taglist_update(s, w, buttons, filter, data, style)
    local tags = {}
    for k, t in ipairs(tag.gettags(s)) do
        if not tag.getproperty(t, "hide") and filter(t) then
            table.insert(tags, t)
        end
    end

    taglist_update_style(w, buttons, style, data, tags)
end
--- Get the tag object the given widget appears on.
-- @param widget The widget the look for.
-- @return The tag object.
function taglist.gettag(widget)
    return common.tagwidgets[widget]
end
---Create a new tagslist widget
--@usage mytags = blingbling.tagslist(screen, filter, buttons,{normal={blingbling.text_box parameters}, focus = {blingbling.text_box parameters},urgent = {blingbling.text_box parameters}, occupied = {blingbling.text_box parameters}}, an awful.layout)
--@param screen an integer for the screen of the tagslist
--@param filter a filtering function the default check if the current tag is not empty and return true if so.
--@param buttons a table of awful.button (mytaglist.buttons from the default rc.lua of awesome for example)
--@param style an optional table with contains 4 tables of text_box parameters in order to change the apparence of the tag based on its state (normal, focus, urgent, occupied)
--@param base_widget an awful.layout (horizontal or vertical)
function taglist.new(screen, filter, buttons, style, base_widget)
	local w = base_widget or fixed.horizontal()
  local data = setmetatable({}, { __mode = 'k' })
  local u = function (s)
      if s == screen then
          taglist_update(s, w, buttons, filter, data, style)
      end
  end
  local uc = function (c) return u(c.screen) end
  local ut = function (t) return u(tag.getscreen(t)) end
  capi.client.connect_signal("focus", uc)
  capi.client.connect_signal("unfocus", uc)
  tag.attached_connect_signal(screen, "property::selected", ut)
  tag.attached_connect_signal(screen, "property::icon", ut)
  tag.attached_connect_signal(screen, "property::hide", ut)
  tag.attached_connect_signal(screen, "property::name", ut)
  tag.attached_connect_signal(screen, "property::activated", ut)
  tag.attached_connect_signal(screen, "property::screen", ut)
  tag.attached_connect_signal(screen, "property::index", ut)
  capi.client.connect_signal("property::urgent", uc)
  capi.client.connect_signal("property::screen", function(c)
      -- If client change screen, refresh it anyway since we don't from
      -- which screen it was coming :-)
      u(screen)
  end)
  capi.client.connect_signal("tagged", uc)
  capi.client.connect_signal("untagged", uc)
  capi.client.connect_signal("unmanage", uc)
  u(screen)
  return w
end

--- Filtering function to include all nonempty tags on the screen.
-- @param t The tag.
-- @param args unused list of extra arguments.
-- @return true if t is not empty, else false
function taglist.filter.noempty(t, args)
    return #t:clients() > 0 or t.selected
end

--- Filtering function to include all tags on the screen.
-- @param t The tag.
-- @param args unused list of extra arguments.
-- @return true
function taglist.filter.all(t, args)
    return true
end

function taglist.mt:__call(...)
    return taglist.new(...)
end

return setmetatable(taglist, taglist.mt)
