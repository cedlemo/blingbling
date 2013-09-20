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
local taglist = { mt = {} }
taglist.filter = {}

local function taglist_customize(t, style)
		if not style then style = {} end
    local theme = beautiful.get()
    local fg_focus = style.fg_focus or theme.taglist_fg_focus or theme.fg_focus
    local bg_focus = style.bg_focus or theme.taglist_bg_focus or theme.bg_focus
    local fg_urgent = style.fg_urgent or theme.taglist_fg_urgent or theme.fg_urgent
    local bg_urgent = style.bg_urgent or theme.taglist_bg_urgent or theme.bg_urgent
    local bg_occupied = style.bg_occupied or theme.taglist_bg_occupied
    local fg_occupied = style.fg_occupied or theme.taglist_fg_occupied
    local taglist_squares_sel = style.squares_sel or theme.taglist_squares_sel
    local taglist_squares_unsel = style.squares_unsel or theme.taglist_squares_unsel
    local taglist_squares_sel_empty = style.squares_sel_empty or theme.taglist_squares_sel_empty
    local taglist_squares_unsel_empty = style.squares_unsel_empty or theme.taglist_squares_unsel_empty
    local taglist_squares_resize = theme.taglist_squares_resize or style.squares_resize or "true"
    local taglist_disable_icon = style.taglist_disable_icon or theme.taglist_disable_icon or false
    local font = style.font or theme.taglist_font or theme.font or ""
		local text = ""
    local sel = capi.client.focus
    local bg_color = nil
    local fg_color = nil
    local bg_image
    local icon
    local bg_resize = false
    local is_selected = false
    if t.selected then
        bg_color = bg_focus
        fg_color = fg_focus
    end
    if sel then
        if taglist_squares_sel then
            -- Check that the selected clients is tagged with 't'.
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
            if bg_occupied then bg_color = bg_occupied end
            if fg_occupied then fg_color = fg_occupied end
        else
            if taglist_squares_unsel_empty then
                bg_image = taglist_squares_unsel_empty
                bg_resize = taglist_squares_resize == "true"
            end
        end
        for k, c in pairs(cls) do
            if c.urgent then
                if bg_urgent then bg_color = bg_urgent end
                if fg_urgent then fg_color = fg_urgent end
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
		style.background_text_color = bg_color
		style.text_color = fg_color
		return text , style, bg_image, not taglist_disable_icon and icon or nil
end

local function taglist_update_style(w, buttons, style, data, tags)
    -- update the widgets, creating them if needed
    w:reset()
			--helpers.dbg({#tags})
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
				--tb:set_text(text)
				tb:set_text_color(style.text_color)
				tb:set_background_text_color(style.background_text_color)
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
