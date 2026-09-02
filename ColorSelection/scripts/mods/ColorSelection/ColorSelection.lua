local mod = get_mod("ColorSelection")

local UISettings = require("scripts/settings/ui/ui_settings")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")

local CONSTANTS = {
	MAX_PLAYERS_PER_PAGE = 14,
	MAX_COLOR_VALUE = 255,
	UUID_LENGTH_WITH_HYPHENS = 36,
	UUID_LENGTH_WITHOUT_HYPHENS = 32,
	SLIDER_HOLD_DELAY = 0.5,
	PLAYER_CHECK_INTERVAL = 1.0,
	SWATCH_SIZE = {30, 20},
	LINE_HEIGHT = 30
}

local ColorUtils = {}

local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match
local math_clamp = math.clamp

local function _get_player_slot(p) if not p then return nil end; local s, r = pcall(function() return p:slot() end); return s and r or nil end
local function _get_player_account_id(p) if not p then return nil end; local s, r = pcall(function() return p:account_id() end); return s and r or nil end
local function _get_player_name(p) if not p then return nil end; local s, r = pcall(function() return p:name() end); return s and r or nil end
local function _get_player_profile(p) if not p then return nil end; local s, r = pcall(function() return p:profile() end); return s and r or nil end
local function _get_user_display_name(p) if not p then return nil end; local s, r = pcall(function() return p:user_display_name(nil, true) end); return s and r or nil end
local function _set_vector3_for_materials(unit, param, color, val) if Unit and Unit.set_vector3_for_materials then Unit.set_vector3_for_materials(unit, param, color, val) end end
local function _get_is_human_controlled(p) if not p then return false end; local s, r = pcall(function() return p:is_human_controlled() end); return s and r or false end
local function _get_is_bot(p) if not p then return false end; local s, r = pcall(function() return p:is_human_controlled() end); return s and not r or false end
local function _get_mechanism_name(m) if not m then return nil end; local s, r = pcall(function() return m:mechanism_name() end); return s and r or nil end
local function _get_mission_name(m) if not m then return nil end; local s, r = pcall(function() return m:mission_name() end); return s and r or nil end

function ColorUtils.normalize_to_rgb(color)
	if not color or type(color) ~= "table" then
		return {r = CONSTANTS.MAX_COLOR_VALUE, g = CONSTANTS.MAX_COLOR_VALUE, b = CONSTANTS.MAX_COLOR_VALUE}
	end

	if color.r and color.g and color.b then
		return {
			r = math.clamp(color.r or CONSTANTS.MAX_COLOR_VALUE, 0, CONSTANTS.MAX_COLOR_VALUE),
			g = math.clamp(color.g or CONSTANTS.MAX_COLOR_VALUE, 0, CONSTANTS.MAX_COLOR_VALUE),
			b = math.clamp(color.b or CONSTANTS.MAX_COLOR_VALUE, 0, CONSTANTS.MAX_COLOR_VALUE)
		}
	elseif color[1] and color[2] and color[3] then

		return {
			r = math.clamp(color[2] or CONSTANTS.MAX_COLOR_VALUE, 0, CONSTANTS.MAX_COLOR_VALUE),
			g = math.clamp(color[3] or CONSTANTS.MAX_COLOR_VALUE, 0, CONSTANTS.MAX_COLOR_VALUE),
			b = math.clamp(color[4] or CONSTANTS.MAX_COLOR_VALUE, 0, CONSTANTS.MAX_COLOR_VALUE)
		}
	end

	return {r = CONSTANTS.MAX_COLOR_VALUE, g = CONSTANTS.MAX_COLOR_VALUE, b = CONSTANTS.MAX_COLOR_VALUE}
end

function ColorUtils.rgb_to_argb(rgb)
	return {CONSTANTS.MAX_COLOR_VALUE, rgb.r, rgb.g, rgb.b}
end

function ColorUtils.argb_to_rgb(argb)
	return {
		r = argb[2] or CONSTANTS.MAX_COLOR_VALUE,
		g = argb[3] or CONSTANTS.MAX_COLOR_VALUE,
		b = argb[4] or CONSTANTS.MAX_COLOR_VALUE
	}
end

mod._player_custom_colors = {}
mod._local_player_account_id = nil

mod.account_id_color_map = mod:persistent_table("account_id_color_map")

function mod.get_default_color_value(prefix, component)
	local defaults = {
		slot1 = {r = 226, g = 210, b = 117},
		slot2 = {r = 180, g = 88, b = 108},
		slot3 = {r = 84, g = 172, b = 121},
		slot4 = {r = 126, g = 153, b = 230},
		slot5 = {r = 230, g = 130, b = 50},
		slot6 = {r = 150, g = 50, b = 230},
		slot7 = {r = 50, g = 230, b = 200},
		slot8 = {r = 230, g = 230, b = 50},
		bot = {r = 128, g = 128, b = 128},
		veteran = {r = 84,  g = 172, b = 121},
		zealot  = {r = 180, g = 88,  b = 108},
		psyker  = {r = 126, g = 153, b = 230},
		ogryn   = {r = 226, g = 210, b = 117},
		broker  = {r = 217, g = 104, b = 41},
		adamant = {r = 138, g = 43,  b = 226},
		cryptic = {r = 32,  g = 178, b = 170},
	}

	local color_data = defaults[prefix]
	if color_data and component then
		return color_data[component] or CONSTANTS.MAX_COLOR_VALUE
	end

	return CONSTANTS.MAX_COLOR_VALUE
end

local function update_local_player_id()
	local pm = Managers and Managers.player
	if pm then
		local local_player = pm:local_player_safe(1)
		if local_player then
			local success, account_id = pcall(_get_player_account_id, local_player)
			if success and account_id and account_id ~= "" then
				mod._local_player_account_id = account_id
				return true
			end
		end
	end
	return false
end

local function pcall_safe(func, a, b, c, d)
	return func(a, b, c, d)
end


local cached_saved_colors = nil
local cached_saved_colors_loaded = false

local function _get_cached_saved_colors()
    if not cached_saved_colors_loaded then
        cached_saved_colors = mod:get("saved_player_colors")
        cached_saved_colors_loaded = true
    end
    return cached_saved_colors
end

local get_color_for_account_id

local color_customizer_view_name = "color_customizer"
local color_customizer_view_path = "ColorSelection/scripts/mods/ColorSelection/views/color_customizer_view/color_customizer_view"

mod:add_require_path(color_customizer_view_path)

local registered_view = mod:register_view({
    view_name = color_customizer_view_name,
    view_settings = {
        init_view_function = function(ingame_ui_context)
            return true
        end,
        state_bound = true,
        display_name = "loc_eye_color_sienna_desc",
        path = color_customizer_view_path,
        package = "packages/ui/views/credits_goods_vendor_view/credits_goods_vendor_view",
        class = "ColorCustomizerView",
        load_in_hub = false,
        game_world_blur = 1,
        enter_sound_events = {
            "wwise/events/ui/play_ui_enter_short"
        },
        exit_sound_events = {
            "wwise/events/ui/play_ui_back_short"
        },
        wwise_states = {},
    },
    view_transitions = {},
    view_options = {
        close_all = false,
        close_previous = false,
        close_transition_time = nil,
        transition_time = nil
    }
})

function mod.open_color_customizer()

    if Managers.ui:view_active(color_customizer_view_name) then
        Managers.ui:close_view(color_customizer_view_name)
        return
    end

    if Managers.ui:has_active_view() or Managers.ui:chat_using_input() then
        return
    end

    Managers.ui:open_view(color_customizer_view_name)
end

local function color_for_slot(slot)
	if not slot or slot < 1 then
		return 1
	end
	return slot
end

local function get_color(prefix)
	local color_array = mod:get(prefix)
	if color_array and type(color_array) == "table" and #color_array >= 3 then
		return {
			color_array[1] or 255,
			color_array[2] or mod.get_default_color_value(prefix, "r"),
			color_array[3] or mod.get_default_color_value(prefix, "g"),
			color_array[4] or mod.get_default_color_value(prefix, "b"),
		}
	end
	return {
		255,
		mod.get_default_color_value(prefix, "r"),
		mod.get_default_color_value(prefix, "g"),
		mod.get_default_color_value(prefix, "b"),
	}
end

local function get_local_player_slot()
	local pm = Managers and Managers.player
	if pm then
		local local_player = pm:local_player_safe(1)
		if local_player then
			local success, slot = pcall(_get_player_slot, local_player)
			if success and slot then
				return slot
			end
		end
	end
	return 1
end

local function get_slot_color(slot, is_local_player, is_bot)
    local force_slot_1 = mod:get("force_local_slot_1") ~= false

	if is_local_player and force_slot_1 then
		return get_color("slot1")
	end

	if is_bot then
		if mod:get("color_bots") ~= false then
			return get_color("bot")
		end
	end

	if type(slot) == "string" then
		slot = tonumber(slot)
	end

	if type(slot) == "number" then
		if slot > 8 then
			if force_slot_1 then
				slot = ((slot - 9) % 7) + 2
			else
				slot = ((slot - 9) % 8) + 1
			end
		end
		
		if slot >= 1 and slot <= 8 then
			local lp_slot = get_local_player_slot()
		
		if mod:get("randomize_slot_colors") then
			if not mod._randomized_slot_map then
				local pool = {1, 2, 3, 4, 5, 6, 7, 8}
				local map = {}
				
				if force_slot_1 then
					map[lp_slot] = 1
					table.remove(pool, 1)
				end
				
				for i = #pool, 2, -1 do
					local j = math.random(i)
					pool[i], pool[j] = pool[j], pool[i]
				end
				
				local pool_idx = 1
				for i = 1, 8 do
					if not map[i] then
						map[i] = pool[pool_idx]
						pool_idx = pool_idx + 1
					end
				end
				mod._randomized_slot_map = map
			end
			return get_color("slot" .. mod._randomized_slot_map[slot])
		end

		if force_slot_1 and lp_slot ~= 1 and slot == 1 then

			return get_color("slot" .. lp_slot)
		end
		return get_color("slot" .. slot)
	end
	end

	return nil
end

local function is_in_non_mission_context()
	local mechanism_name = nil
	if Managers.mechanism then
		local success, result = pcall(_get_mechanism_name, Managers.mechanism)
		if success then mechanism_name = result end
	end

	local mission_name = nil
	if Managers.state and Managers.state.mission then
		local success, result = pcall(_get_mission_name, Managers.state.mission)
		if success then mission_name = result end
	end

	local ui = Managers.ui
	if ui and (ui:view_active("end_view") or ui:view_active("end_player_view")) then
		return false
	end

	if mechanism_name == "left_session" or mechanism_name == "hub" then
		return true
	end

	if mechanism_name == "adventure" then
		return false
	end

	if not mission_name then
		return true
	end

	if mission_name == "hub_ship" then
		return true
	end

	if mechanism_name == "onboarding" and mission_name ~= "tg_shooting_range" then
		return true
	end

	return false
end

local function get_class_color(player)
	if not player then return nil end
	local profile = pcall_safe(_get_player_profile, player)
	if profile and profile.archetype and profile.archetype.name then
		local archetype = profile.archetype.name
		if archetype == "veteran" or archetype == "zealot" or archetype == "psyker" or archetype == "ogryn" or archetype == "broker" or archetype == "adamant" or archetype == "cryptic" then
			return get_color(archetype)
		end
	end
	return nil
end

local get_player_by_account_id
local get_player_by_slot

get_color_for_account_id = function(account_id, slot)
	if not mod._local_player_account_id then
		update_local_player_id()
	end

	local saved_colors = _get_cached_saved_colors()
	if saved_colors and type(saved_colors) == "table" and saved_colors[account_id] then
		local c = saved_colors[account_id]
		if c and type(c) == "table" then
			if not is_in_non_mission_context() or mod:get("color_custom_outside_mission") then
				return {255, c.r or 255, c.g or 255, c.b or 255}
			end
		end
	end

	local is_local = account_id and account_id ~= "" and mod._local_player_account_id == account_id

	if is_in_non_mission_context() and not is_local then
		return nil
	end


	local player = nil
	if account_id and account_id ~= "" then
		player = get_player_by_account_id(account_id)
	elseif slot then
		local pm = Managers and Managers.player
		if pm then
			local bot_players = pm:bot_players()
			if bot_players then
				for _, p in pairs(bot_players) do
					local success, s = pcall(_get_player_slot, p)
					if success and s == slot then
						player = p
						break
					end
				end
			end
		end
	end

	if not slot then
		local player_slot = nil
		if player then
			local success, s = pcall(_get_player_slot, player)
			if success and s then
				player_slot = s
			end
		end

		if not player_slot then
			if is_local and mod:get("force_local_slot_1") ~= false then
				slot = 1
			end
		else
			slot = player_slot
		end
	end

	local is_bot = false
	if player then
		is_bot = _get_is_bot(player)
	end

	if is_local then
		if not is_in_non_mission_context() or mod:get("color_local_outside_mission") then
			if mod:get("color_by_class") and player and mod:get("force_local_slot_1") == false then
				local class_color = get_class_color(player)
				if class_color then return class_color end
			end
			return get_slot_color(slot, true, is_bot)
		end
		return nil
	end

	if mod:get("color_by_class") and player then
		local class_color = get_class_color(player)
		if class_color then return class_color end
	end

	if not slot then
		return nil
	end

	return get_slot_color(slot, is_local, is_bot)
end

local function _on_player_removed(player)
	if not player then return end

	local success, account_id = pcall(_get_player_account_id, player)
	if success and account_id and mod._player_custom_colors then
		mod._player_custom_colors[account_id] = nil
	end
end

local _player_cache = {
	by_slot = {},
	by_account_id = {},
	last_update = 0
}

local function update_player_cache()
	local pm = Managers and Managers.player
	if not pm then
		return
	end

	table.clear(_player_cache.by_slot)
	table.clear(_player_cache.by_account_id)

	local human_players = pm:human_players()
	if human_players then
		for unique_id, player in pairs(human_players) do
			if player then

				local human_success, is_human = pcall(_get_is_human_controlled, player)
				local bot_success, is_bot = pcall(_get_is_bot, player)
				local id_success, account_id = pcall(_get_player_account_id, player)

				if not (human_success and is_human) then goto skip_cache end
				if bot_success and is_bot then goto skip_cache end
				if not (id_success and account_id and account_id ~= "") then goto skip_cache end

				local slot_success, slot = pcall(_get_player_slot, player)
				if slot_success and slot then _player_cache.by_slot[slot] = player end
				if id_success and account_id then _player_cache.by_account_id[account_id] = player end

				::skip_cache::
			end
		end
	end
	_player_cache.last_update = os.clock()
end

get_player_by_slot = function(slot)
	if not slot then return nil end

	local current_time = os.clock()
	if current_time - _player_cache.last_update > 0.5 then
		update_player_cache()
	end

	return _player_cache.by_slot[slot]
end

get_player_by_account_id = function(account_id)
	if not account_id then return nil end

	local current_time = os.clock()
	if current_time - _player_cache.last_update > 0.5 then
		update_player_cache()
	end

	return _player_cache.by_account_id[account_id]
end

local _color_tag_cache = {}
local function get_color_tag(color)
	if not color then return "" end
	local r = color[2] or 255
	local g = color[3] or 255
	local b = color[4] or 255
	local key = r * 65536 + g * 256 + b
	local tag = _color_tag_cache[key]
	if not tag then
		tag = string.format("{#color(%d,%d,%d)}", r, g, b)
		_color_tag_cache[key] = tag
	end
	return tag
end

local CLASS_ICON_STYLE_KEYS = {"texture", "icon", "class_icon", "text"}

local function apply_color_to_name_only(text, color)
	if not text or type(text) ~= "string" or not color then
		return text
	end

	local color_tag = get_color_tag(color)
	local stripped_text = text:gsub("^{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}$", "")

	return color_tag .. stripped_text .. "{#reset()}"
end

local function apply_widget_color(panel)
	if not panel or not panel._widgets_by_name then
		return
	end

	local player = panel._player
	if not player and panel._data then
		player = panel._data.player
	end

	local slot = nil
	local account_id = nil

	if player then

		local success, result = pcall(_get_player_slot, player)
		if success and result then
			slot = result
		end

		local id_success, id_result = pcall(_get_player_account_id, player)
		if id_success and id_result then
			account_id = id_result
		end

		if slot and not panel._player_slot then
			panel._player_slot = slot
		end
	else

		slot = panel._player_slot
		if slot then
			player = get_player_by_slot(slot)
			if player then
				local success, result = pcall(_get_player_account_id, player)
				if success then
					account_id = result
				end
			end
		end
	end

	if not slot then
		return
	end

	local color = get_color_for_account_id(account_id, slot)

	if account_id and color and not is_in_non_mission_context() then
		mod._mission_color_cache = mod._mission_color_cache or {}
		mod._mission_color_cache[account_id] = color
	end

	local class_icon = panel._widgets_by_name.class_icon or panel._widgets_by_name.character_portrait
	if class_icon and class_icon.style and color then
		for i = 1, #CLASS_ICON_STYLE_KEYS do
			local style_pass = class_icon.style[CLASS_ICON_STYLE_KEYS[i]]
			if style_pass then
				local c = style_pass.color or style_pass.text_color
				if c and type(c) == "table" then
					if c[2] ~= color[2] or c[3] ~= color[3] or c[4] ~= color[4] then
						c[1], c[2], c[3], c[4] = 255, color[2], color[3], color[4]
						class_icon.dirty = true
					end
				end
			end
		end
	end

	local widget = panel._widgets_by_name.player_name
	if not widget or not widget.style or not widget.style.text then
		return
	end

	if not color then
		if widget.content and widget.content.text then
			local stripped = widget.content.text:gsub("^{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}$", "")
			if widget.content.text ~= stripped then
				widget.content.text = stripped
				widget.dirty = true
				widget.content.dirty = true
			end
		end
		return
	end

	if widget.content and widget.content.text then
		local current_text = widget.content.text
		local new_text = apply_color_to_name_only(current_text, color)
		if current_text ~= new_text then
			widget.content.text = new_text
			widget.dirty = true
		end
	end
end

local function alias_ability_bar_widget(panel)
	local w = panel and panel._widgets_by_name
	if not w then
		return
	end
	if w.ability_bar then
		w.ability_bar_widget = w.ability_bar
	elseif not w.ability_bar_widget then
		w.ability_bar_widget = { visible = false, dirty = false, style = { texture = { color = { 255, 255, 255, 255 }, size = { 0, 0 } } } }
	end
end

mod:hook_safe("HudElementPersonalPlayerPanel", "init", function(self) alias_ability_bar_widget(self) end)
mod:hook_safe("HudElementTeamPlayerPanel",     "init", function(self) alias_ability_bar_widget(self) end)

mod:hook_safe("HudElementPlayerPanelBase",     "destroy", function(self) alias_ability_bar_widget(self) end)

mod:hook_safe("HudElementPersonalPlayerPanelHub", "update", function(self)
	if mod:is_enabled() then
		apply_widget_color(self)
	end
end)

mod:hook_safe("HudElementPersonalPlayerPanelHub", "_set_player_name", function(self)
	if mod:is_enabled() then
		apply_widget_color(self)
	end
end)

mod:hook_safe("HudElementPersonalPlayerPanel", "update", function(self)
	if mod:is_enabled() then
		apply_widget_color(self)
	end
end)

mod:hook_safe("HudElementTeamPlayerPanel", "update", function(self)
	if mod:is_enabled() then
		apply_widget_color(self)
	end
end)

mod:hook_safe("HudElementTeamPlayerPanelHub", "update", function(self)
	if mod:is_enabled() then

		local player = self._player
		if not player and self._data then
			player = self._data.player
		end

		if player then
			local account_id = nil
			local id_success, id_result = pcall(_get_player_account_id, player)
			if id_success and id_result then
				account_id = id_result
			end


			local color = get_color_for_account_id(account_id)

			local class_icon = self._widgets_by_name and (self._widgets_by_name.class_icon or self._widgets_by_name.character_portrait)
			if class_icon and class_icon.style and color then
				local style_keys = {"texture", "icon", "class_icon", "text"}
				for i = 1, #style_keys do
					local style_pass = class_icon.style[style_keys[i]]
					if style_pass then
						local c = style_pass.color or style_pass.text_color
						if c and type(c) == "table" then
							c[1], c[2], c[3], c[4] = 255, color[2], color[3], color[4]
							class_icon.dirty = true
						end
					end
				end
			end

			local widget = self._widgets_by_name and self._widgets_by_name.player_name

			if not color then
				if widget and widget.content and widget.content.text then
					local stripped = widget.content.text:gsub("^{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}$", "")
					if widget.content.text ~= stripped then
						widget.content.text = stripped
						widget.dirty = true
					end
				end
				return
			end


			if widget and widget.content and widget.content.text and not self.tl_modified and not self.wru_modified then
				local current_text = widget.content.text
				local new_text = apply_color_to_name_only(current_text, color)
				widget.content.text = new_text
				widget.dirty = true
			end
		end
	end
end)

local function colourise_team_panels(handler)
	if not mod:is_enabled() then return end
	local panels = handler and handler._player_panels_array
	if not panels then return end
	for i = 1, #panels do
		local p = panels[i] and panels[i].panel
		if p then apply_widget_color(p) end
	end
end

local function apply_nameplate_color(marker)
    if not marker or not marker.widget or not mod:is_enabled() then
        return
    end

    local player = marker.data
    if not player then
        return
    end

    local slot = pcall_safe(_get_player_slot, player)
    local account_id = pcall_safe(_get_player_account_id, player)

    local is_saved_friend = false
    local saved_colors = _get_cached_saved_colors()
    if account_id and saved_colors and type(saved_colors) == "table" and saved_colors[account_id] then
        is_saved_friend = true
    end

    local is_local_player = account_id and account_id ~= "" and mod._local_player_account_id == account_id

    if is_in_non_mission_context() and not is_saved_friend and not is_local_player then
        return
    end

    local marker_type = marker.type
    if not is_saved_friend and not is_local_player and marker_type and string.find(marker_type, "hub", 1, true) then
        local widget = marker.widget
        local content = widget and widget.content
        if content then
            local changed = false
            if content.header_text and string.find(content.header_text, "{#color", 1, true) then
                local name_part, title_part = content.header_text:match("^([^\n]*)\n?(.*)$")
                if not name_part then
                    name_part = content.header_text
                    title_part = ""
                end
                
                local stripped_name = name_part:gsub("{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}", "")
                
                local new_header = stripped_name
                if title_part and title_part ~= "" then
                    new_header = new_header .. "\n" .. title_part
                end
                
                if content.header_text ~= new_header then
                    content.header_text = new_header
                    changed = true
                end
            end
            if content.icon_text and string.find(content.icon_text, "{#color", 1, true) then
                local stripped_icon = content.icon_text:gsub("{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}", "")
                if content.icon_text ~= stripped_icon then
                    content.icon_text = stripped_icon
                    changed = true
                end
            end

            if changed then
                widget.dirty = true
                content.dirty = true
            end
            marker._cs_is_reset = true
            marker._cs_colored_header = nil
            marker._cs_applied_color = nil
        end
        return
    end

    local color = get_color_for_account_id(account_id, slot)

    local widget = marker.widget
    local content = widget and widget.content
    
    if not color then
        if is_local_player and is_in_non_mission_context() then
            return
        end
        if content then
            local changed = false
            if content.header_text and string.find(content.header_text, "{#color", 1, true) then
                local name_part, title_part = content.header_text:match("^([^\n]*)\n?(.*)$")
                if not name_part then
                    name_part = content.header_text
                    title_part = ""
                end
                
                local stripped_name = name_part:gsub("{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}", "")
                
                local new_header = stripped_name
                if title_part and title_part ~= "" then
                    new_header = new_header .. "\n" .. title_part
                end
                
                if content.header_text ~= new_header then
                    content.header_text = new_header
                    changed = true
                end
            end
            if content.icon_text and string.find(content.icon_text, "{#color", 1, true) then
                local stripped_icon = content.icon_text:gsub("{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}", "")
                if content.icon_text ~= stripped_icon then
                    content.icon_text = stripped_icon
                    changed = true
                end
            end

            if changed then
                widget.dirty = true
                content.dirty = true
            end
            marker._cs_is_reset = true
            marker._cs_colored_header = nil
            marker._cs_applied_color = nil
        end
        return
    end

    local is_companion = marker.type and string.find(marker.type, "companion", 1, true)

    if not content or (not content.header_text and not content.icon_text) then
        return
    end

    local color_tag = get_color_tag(color)

    if marker._cs_applied_color == color_tag and marker._cs_colored_header == (content.header_text or "") then
        local skip = true
        if widget and widget.style then
            local icon_style = widget.style.icon or widget.style.class_icon
            if icon_style and icon_style.color then
                local c = icon_style.color
                if c[2] ~= color[2] or c[3] ~= color[3] or c[4] ~= color[4] then
                    skip = false
                end
            end
        end
        if skip then return end
    end

    local changed = false

    if widget and widget.style then
        local icon_style = widget.style.icon or widget.style.class_icon
        if icon_style and icon_style.color then
            local c = icon_style.color
            if c[2] ~= color[2] or c[3] ~= color[3] or c[4] ~= color[4] then
                c[1], c[2], c[3], c[4] = 255, color[2], color[3], color[4]
                changed = true
            end
        end
    end

    if content.header_text then
        local header = content.header_text

        if is_companion then
            local companion_glyph = ""
            local stripped_header = header:gsub("{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}", "")
            local companion_name = stripped_header:match(companion_glyph .. "%s*(.-)$") or stripped_header:match("%s*(.-)$") or stripped_header
            
            local new_header = color_tag .. companion_glyph .. "{#reset()} " .. companion_name
            if content.header_text ~= new_header then
                content.header_text = new_header
                marker._cs_last_header = nil
                marker._cs_colored_header = new_header
                changed = true
            end
        else
            local player_name = pcall_safe(_get_player_name, player)
            if not player_name or player_name == "" then
                local name_part = header:match("^([^\n]*)")
                player_name = name_part and name_part:match("%w+") or header:match("%w+") or header
            end

            player_name = player_name:gsub("{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}", "")
            local escaped_name = player_name:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")

            local name_part, title_part = header:match("^([^\n]*)\n?(.*)$")
            if not name_part then
                name_part = header
                title_part = ""
            end

            local clean_name_part = name_part:gsub("{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}", "")
            local name_start, name_end = clean_name_part:find(escaped_name, 1, true)

            if name_start and player_name ~= "" then
                local before_name = clean_name_part:sub(1, name_start - 1)
                local after_name = clean_name_part:sub(name_end + 1)
                local new_name_part = color_tag .. before_name .. player_name .. "{#reset()}" .. after_name

                local new_header = new_name_part
                if title_part and title_part ~= "" then
                    new_header = new_header .. "\n" .. title_part
                end

                content.header_text = new_header
                marker._cs_last_header = nil
                marker._cs_colored_header = new_header
                changed = true
            end
        end
    end

    if content.icon_text then
        local stripped_icon = content.icon_text:gsub("{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}", "")
        if stripped_icon ~= "" then
            local new_icon = color_tag .. stripped_icon .. "{#reset()}"
            if content.icon_text ~= new_icon then
                content.icon_text = new_icon
                changed = true
            end
        end
    end

    if changed then
        marker._cs_applied_color = color_tag
        marker._cs_is_reset = false

        if widget then
            widget.dirty = true
            if widget.content then
                widget.content.dirty = true
            end
        end
    end
end

mod:hook_require("scripts/ui/hud/elements/team_panel_handler/hud_element_team_panel_handler", function(H)
	if not H.__cs_hooked then
		H.__cs_hooked = true
		mod:hook_safe(H, "update", function(self) colourise_team_panels(self) end)
	end
end)

local nameplate_template_path = "scripts/ui/hud/elements/world_markers/templates/world_marker_template_nameplate"
mod:hook_require(nameplate_template_path, function(template)
	if not template then return end


	if template.on_enter then
		local original_on_enter = template.on_enter
		template.on_enter = function(widget, marker)
			original_on_enter(widget, marker)

			if mod:is_enabled() and marker and marker.data then


				if marker.widget and marker.widget.content and marker.widget.content.header_text then
					apply_nameplate_color(marker)
				end
			end
		end
	end
end)

local companion_templates = {
	"scripts/ui/hud/elements/world_markers/templates/world_marker_template_nameplate_companion",
	"scripts/ui/hud/elements/world_markers/templates/world_marker_template_nameplate_companion_hub",
}

for i = 1, #companion_templates do
	local template_path = companion_templates[i]
	mod:hook_require(template_path, function(template)
		if not template or not template.on_enter then return end

		local original_on_enter = template.on_enter
		template.on_enter = function(widget, marker)
			original_on_enter(widget, marker)

			if not mod:is_enabled() or not marker or not marker.data then return end

			local data = marker.data
			local content = widget.content
			if not content then return end

			local player_slot = pcall_safe(_get_player_slot, data)
			local account_id = pcall_safe(_get_player_account_id, data)

			local current_header = content.header_text or ""
			if current_header == "" then
				return
			end

			local color = get_color_for_account_id(account_id, player_slot)
			if color then
				local color_string = "{#color(" .. color[2] .. "," .. color[3] .. "," .. color[4] .. ")}"
				local companion_glyph = ""

				if content.icon_text then
					content.icon_text = color_string .. companion_glyph .. "{#reset()}"
				end

				if content.header_text and content.header_text ~= "" then
					local header = content.header_text
					local companion_name = header:match(companion_glyph .. "%s*(.-)$") or header:match("%s*(.-)$")
					if companion_name then
						content.header_text = color_string .. companion_glyph .. "{#reset()} " .. companion_name
					end
				end

				widget.dirty = true
				if content then
					content.dirty = true
				end
			end
		end
	end)
end

mod:hook_safe("HudElementWorldMarkers", "event_add_world_marker_unit", function(self, marker_type, unit, callback, data)
	if not mod:is_enabled() then return end

	if marker_type and (string.find(marker_type, "nameplate", 1, true) or string.find(marker_type, "companion", 1, true)) then
		local by_type = self._markers_by_type
		if by_type then
			for type_key, bucket in pairs(by_type) do
				if type(type_key) == "string" and (string.find(type_key, "nameplate", 1, true) or string.find(type_key, "companion", 1, true)) then
					for _, marker in pairs(bucket) do
						if marker.unit == unit and marker.widget and marker.widget.content then
							apply_nameplate_color(marker)
							break
						end
					end
				end
			end
		end
	end
end)

mod:hook_safe("HudElementNameplates", "update", function(self, dt, t, ui_renderer)
	if not mod:is_enabled() then return end

	if not Managers or not Managers.ui then return end

	local ui_manager = Managers.ui
	local hud = ui_manager._hud
	if not hud then return end

	local world_markers = hud.element and hud:element("HudElementWorldMarkers")
	if not world_markers or not world_markers._markers_by_type then return end

	for marker_type, bucket in pairs(world_markers._markers_by_type) do
		if type(marker_type) == "string" and (string.find(marker_type, "nameplate", 1, true) or string.find(marker_type, "companion", 1, true)) then
			for _, marker in pairs(bucket) do
				apply_nameplate_color(marker)
			end
		end
	end
end)

mod:hook(CLASS.ConstantElementChat, "_participant_displayname", function(func, self, participant)
	local display_name = func(self, participant)

	if not display_name then
		return nil
	end

	if not mod:is_enabled() then
		return func(self, participant)
	end

	local is_local = false
	if participant then
		if participant.is_current_user then
			is_local = true
		elseif participant.account_id and mod._local_player_account_id and participant.account_id == mod._local_player_account_id then
			is_local = true
		end
	end

	if is_local then
		local account_id = mod._local_player_account_id
		local pm = Managers.player
		local player = pm and pm:local_player_safe(1)
		local slot = player and pcall_safe(_get_player_slot, player) or 1
		local color = get_color_for_account_id(account_id, slot)

		local display_name
		local style = mod:get("chat_local_name_style") or "colored_you"
		if style == "character" then
			display_name = func(self, participant)
		elseif style == "account" then
			local player_info = account_id and Managers.data_service.social:get_player_info_by_account_id(account_id)
			display_name = player_info and pcall_safe(_get_user_display_name, player_info)
		end
		
		if not display_name then
			display_name = mod:localize("loc_color_selection_you")
			if type(display_name) ~= "string" or display_name == "" or display_name == "<loc_color_selection_you>" then
				display_name = "You"
			end
		end

		if color then
			local color_tag = string.format("{#color(%d,%d,%d)}", color[2], color[3], color[4])
			return color_tag .. display_name .. "{#reset()}"
		else
			return display_name
		end
	end

	local display_name = func(self, participant)

	if not display_name then
		return nil
	end

	local account_id = participant and participant.account_id
	if not account_id or account_id == "" then
		return display_name
	end

	local slot = nil
	local player = get_player_by_account_id(account_id)
	
	if player then
		slot = pcall_safe(_get_player_slot, player)
	end

	local color = get_color_for_account_id(account_id, slot)
	if not color then
		return display_name
	end

	if color then
		local color_tag = string.format("{#color(%d,%d,%d)}", color[2], color[3], color[4])
		local stripped_display_name = display_name:gsub("{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}", "")
		local result = color_tag .. stripped_display_name .. "{#reset()}"
		return result
	end

	return display_name
end)

mod:hook(CLASS.ConstantElementChat, "cb_chat_manager_message_recieved", function(func, self, channel_handle, participant, message)
	if not mod:is_enabled() then
		return func(self, channel_handle, participant, message)
	end

	local participant_current = participant and participant.is_current_user
	local message_current = message and message.is_current_user
	local style = mod:get("chat_local_name_style") or "colored_you"

	if (participant_current or message_current) and style ~= "vanilla" then
		local cloned_participant = participant and table.clone(participant) or nil
		local cloned_message = message and table.clone(message) or nil
		
		if cloned_participant then cloned_participant.is_current_user = false end
		if cloned_message then cloned_message.is_current_user = false end

		return func(self, channel_handle, cloned_participant, cloned_message)
	end

	return func(self, channel_handle, participant, message)
end)



local function apply_color_to_player_name(name, player)
	if not name or name == "" or not player then
		return name
	end

	local account_id = pcall_safe(_get_player_account_id, player)
	if not account_id or account_id == "" then
		return name
	end

	local color = get_color_for_account_id(account_id)

	if color then
		local color_tag = string.format("{#color(%d,%d,%d)}", color[2], color[3], color[4])
		local clean_name = name:gsub("{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}", "")
		return color_tag .. clean_name .. "{#reset()}"
	end

	return name
end

mod:hook(CLASS.HumanPlayer, "name", function(func, self)
	local name = func(self)

	if not mod:is_enabled() then
		return name
	end

	return apply_color_to_player_name(name, self)
end)

mod:hook(CLASS.RemotePlayer, "name", function(func, self)
	local name = func(self)

	if not mod:is_enabled() then
		return name
	end

	return apply_color_to_player_name(name, self)
end)

mod:hook(CLASS.BotPlayer, "name", function(func, self)
	local name = func(self)

	if not mod:is_enabled() then
		return name
	end

	return apply_color_to_player_name(name, self)
end)

mod:hook(CLASS.PlayerInfo, "character_name", function(func, self)
	local name = func(self)

	if not mod:is_enabled() then
		return name
	end

	local account_id = self._account_id
	if account_id then
		local color = get_color_for_account_id(account_id)
		if color then
			local color_tag = string.format("{#color(%d,%d,%d)}", color[2], color[3], color[4])
			return color_tag .. name .. "{#reset()}"
		end
	end

	return name
end)

mod:hook(CLASS.RemotePlayer, "character_name", function(func, self)
	local name = func(self)

	if not mod:is_enabled() then
		return name
	end

	return apply_color_to_player_name(name, self)
end)


mod:hook(CLASS.PresenceEntryMyself, "character_name", function(func, self)
	local name = func(self)

	if not mod:is_enabled() then
		return name
	end

	local color = get_color("slot1")
	local color_tag = string.format("{#color(%d,%d,%d)}", color[2], color[3], color[4])
	return color_tag .. name .. "{#reset()}"
end)

mod:hook(CLASS.PresenceEntryImmaterium, "character_name", function(func, self)
	local name = func(self)

	if not mod:is_enabled() then
		return name
	end

	local account_id = self._immaterium_entry and self._immaterium_entry.account_id
	if account_id then
		local color = get_color_for_account_id(account_id)
		if color then
			local color_tag = string.format("{#color(%d,%d,%d)}", color[2], color[3], color[4])
			return color_tag .. name .. "{#reset()}"
		end
	end

	return name
end)

mod:hook_require("scripts/utilities/profile_utils", function(instance)
	mod:hook(instance, "character_name", function(func, profile)
		local name = func(profile)

		if not mod:is_enabled() then
			return name
		end

		local account_id = profile and profile.account_id
		if account_id then
			local color = get_color_for_account_id(account_id)
			if color then
				local color_tag = string.format("{#color(%d,%d,%d)}", color[2], color[3], color[4])
				return color_tag .. name .. "{#reset()}"
			end
		end

		return name
	end)
end)

local function install_player_panel_hooks(base)
	if not base or base.__cs_hooks then return end
	base.__cs_hooks = true

	mod:hook_safe(base, "update", function(self, dt, t, ui_renderer)

		if mod:is_enabled() and self._widgets_by_name and self._widgets_by_name.player_name then
			apply_widget_color(self)
		end
	end)

	mod:hook_safe(base, "_update_player_name_prefix", function(self)
		if not mod:is_enabled() then return end
		if self._colors_revision ~= mod._colors_revision then
			self._colors_revision = mod._colors_revision
			apply_widget_color(self)
		end
	end)

	mod:hook_safe(base, "_set_player_name", function(self)
		if not mod:is_enabled() then return end
		apply_widget_color(self)
	end)

	mod:hook_safe(base, "_update_player_features", function(self, dt, t, player, ui_renderer)

		if player then
			self._player = player

			local success, slot = pcall(_get_player_slot, player)
			if success and slot then
				self._player_slot = slot
			end
		end
		apply_widget_color(self)
	end)

	mod:hook_safe(base, "init", function(self, parent, draw_layer, scale, data)
		if data and data.player then
			local player = data.player
			if player then
				local success, slot = pcall(_get_player_slot, player)
				if success and slot then
					self._player_slot = slot
				end
			end
		end

		apply_widget_color(self)
	end)
end

mod:hook_require("scripts/ui/hud/elements/player_panel_base/hud_element_player_panel_base", function(B) install_player_panel_hooks(B) end)

mod._colors_revision = 0
local previous_slot_colors

local function deep_clone(tbl)
	if not tbl then return nil end
	local copy = {}
	for k, v in pairs(tbl) do
		copy[k] = type(v) == "table" and deep_clone(v) or v
	end
	return copy
end

local function restore_previous()
	if previous_slot_colors then
		UISettings.player_slot_colors = previous_slot_colors
		previous_slot_colors = nil
		mod._colors_revision = mod._colors_revision + 1
	end
end

mod.on_unload = restore_previous

local function update_world_markers()
	local ui_manager = Managers and Managers.ui
	if not ui_manager then return false end

	local hud = ui_manager:get_hud()
	if not hud then return false end

	local world_markers = hud:element("HudElementWorldMarkers")
	if not world_markers or not world_markers._markers_by_id then return false end

	for marker_id, marker in pairs(world_markers._markers_by_id) do
		local marker_type = marker.type

		if marker_type and (marker_type:match("nameplate") or marker_type:match("companion")) then
			marker.wru_modified = false
			marker.tl_modified = false
			marker._cs_last_header = nil
			marker._cs_colored_header = nil
			marker._cs_applied_color = nil
			apply_nameplate_color(marker)
		end
	end

	local rh_mod = get_mod("RingHud")
	if rh_mod and rh_mod:is_enabled() then
		if rh_mod.floating_manager and type(rh_mod.floating_manager.bump_names) == "function" then
			rh_mod.floating_manager.bump_names()
		end
		local hewm = rawget(rh_mod, "_hewm_world_markers")
		local list = hewm and hewm._markers_by_type and hewm._markers_by_type.ringhud_teammate_tile
		if list then
			local function each(tbl, fn)
				if #tbl > 0 then for i = 1, #tbl do fn(tbl[i]) end
				else for _, v in pairs(tbl) do fn(v) end end
			end
			each(list, function(marker)
				if marker then
					marker._state_accum = 1
					marker._last_state_hash = -1
				end
			end)
		end
	end

	return true
end

local function update_player_panel_colors()

	local ui_manager = Managers and Managers.ui
	if not ui_manager or not ui_manager._hud then return false end

	local hud = ui_manager._hud
	local elements_array = hud._elements_array
	if not elements_array then return false end

	for i = 1, #elements_array do
		local element = elements_array[i]
		if element then
			local class_name = element.__class_name
			if class_name == "HudElementPersonalPlayerPanel" or class_name == "HudElementPersonalPlayerPanelHub" then

				element.wru_modified = false
				element.tl_modified = false
				apply_widget_color(element)
			elseif class_name == "HudElementTeamPlayerPanel" or class_name == "HudElementTeamPlayerPanelHub" then

				element.wru_modified = false
				element.tl_modified = false
				apply_widget_color(element)
			elseif class_name == "HudElementTeamPanelHandler" then

				if element._player_panels_array then
					for _, data in ipairs(element._player_panels_array) do
						if data.panel then
							data.panel.wru_modified = false
							data.panel.tl_modified = false
						end
					end
				end
				colourise_team_panels(element)
			end
		end
	end

	update_world_markers()

	return true
end

local is_applying_colors = false

local function apply_slot_colors_internal()
	if not UISettings or is_applying_colors then
		return
	end

	is_applying_colors = true

	_player_cache.last_update = 0

	if not UISettings.player_slot_colors then
		UISettings.player_slot_colors = {}
	end

	if not previous_slot_colors then
		previous_slot_colors = deep_clone(UISettings.player_slot_colors)
	end

	local color_metatable = {
		__index = function(_, k)
			if type(k) ~= "number" or k < 1 then return nil end
			if is_in_non_mission_context() then return nil end

			local account_id = nil
			local player = get_player_by_slot(k)
			if player then
				local success, result = pcall(_get_player_account_id, player)
				if success then
					account_id = result
				end
			end
			return get_color_for_account_id(account_id, k)
		end,
	}

	local current_table = UISettings.player_slot_colors or {}
	for k in pairs(current_table) do
		current_table[k] = nil
	end

	for i = 1, 8 do
		if is_in_non_mission_context() then break end

		local account_id = nil
		local is_bot_in_slot = false
		local pm = Managers and Managers.player
		if pm and mod:get("color_bots") ~= false then
			local bot_players = pm:bot_players()
			if bot_players then
				for _, p in pairs(bot_players) do
					local success, s = pcall(_get_player_slot, p)
					if success and s == i then
						is_bot_in_slot = true
						break
					end
				end
			end
		end

		local color
		if is_bot_in_slot then
			color = get_color("bot")
		else
			local player = get_player_by_slot(i)
			if player then
				local success, result = pcall(_get_player_account_id, player)
				if success then
					account_id = result
				end
			end
			color = get_color_for_account_id(account_id, i)
		end

		if color then
			current_table[i] = color
		end
	end

	UISettings.player_slot_colors = setmetatable(current_table, color_metatable)

	mod._colors_revision = (mod._colors_revision or 0) + 1
	UISettings._colors_revision = (UISettings._colors_revision or 0) + 1
	update_player_panel_colors()

	local debug_enabled = mod:get("debug_mode")
	if debug_enabled then
		mod:echo("[ColorSelection] Slot colors applied successfully")
	end

	is_applying_colors = false
end

local function apply_slot_colors()
	apply_slot_colors_internal()
end
mod.update = function(dt)
	mod._bot_check_timer = (mod._bot_check_timer or 0) + dt
	if mod._bot_check_timer > 0.5 then
		mod._bot_check_timer = 0
		
		local pm = Managers and Managers.player
		if pm then
			local bot_count = 0
			local bot_players = pm:bot_players()
			if bot_players then
				for _ in pairs(bot_players) do
					bot_count = bot_count + 1
				end
			end
			if bot_count ~= mod._last_bot_count then
				mod._last_bot_count = bot_count
				if type(mod.apply_slot_colors) == "function" then
					mod.apply_slot_colors()
				end
			end
		end
	end
end

mod.apply_slot_colors = apply_slot_colors
mod.update_player_panel_colors = update_player_panel_colors
mod.ColorUtils = ColorUtils
mod.CONSTANTS = CONSTANTS
mod.get_player_by_account_id = get_player_by_account_id
mod.get_player_by_slot = get_player_by_slot
mod.get_color_for_account_id = get_color_for_account_id

local function _strip_cs_color_tags(text)
    if not text or type(text) ~= "string" then
        return text
    end

    local cleaned = text:gsub("^{#color%(%d+,%d+,%d+,%d+%)}", ""):gsub("{#reset%(%)}$", "")
    return cleaned
end

local function reset_team_panel_colors()
    local ui_manager = Managers and Managers.ui
    if not ui_manager then
        return
    end

    local hud = ui_manager:get_hud()
    if not hud then
        return
    end

    local handler = hud:element("HudElementTeamPanelHandler")
    if not handler or not handler._player_panels_array then
        return
    end

    for i = 1, #handler._player_panels_array do
        local p = handler._player_panels_array[i] and handler._player_panels_array[i].panel
        if p and p._widgets_by_name then
            local class_icon = p._widgets_by_name.class_icon or p._widgets_by_name.character_portrait
            if class_icon and class_icon.style and class_icon.style.texture then
                local c = class_icon.style.texture.color
                if c and type(c) == "table" then
                    c[1], c[2], c[3], c[4] = 255, 255, 255, 255
                    class_icon.dirty = true
                end
            end

            local widget = p._widgets_by_name.player_name
            if widget and widget.content and widget.content.text then
                widget.content.text = _strip_cs_color_tags(widget.content.text)
                widget.dirty = true
            end
        end
    end
end

local function reset_nameplate_colors()
    local ui_manager = Managers and Managers.ui
    if not ui_manager then
        return
    end
    local hud = ui_manager._hud
    if not hud then
        return
    end
    local world_markers = hud:element("HudElementWorldMarkers")
    if not world_markers or not world_markers._markers_by_id then
        return
    end
    for _, marker in pairs(world_markers._markers_by_id) do
        local marker_type = marker.type
        if marker_type and (marker_type:match("nameplate") or marker_type:match("companion")) then
            if marker.widget and marker.widget.content then
                if marker.widget.content.header_text then
                    marker.widget.content.header_text = _strip_cs_color_tags(marker.widget.content.header_text)
                    marker._cs_last_header = nil
                end
                if marker_type:match("companion") and marker.widget.content.icon_text then
                    marker.widget.content.icon_text = _strip_cs_color_tags(marker.widget.content.icon_text)
                end
            end

        end
    end
end

local function reset_character_outlines()
    local extension_manager = Managers and Managers.state and Managers.state.extension
    if not extension_manager then return end

    local outline_system = extension_manager:system("outline_system")
    if not outline_system or not outline_system._unit_extension_data then return end

    local default_outline_color = Vector3(163/255, 255/255, 185/255)
    for unit, extension in pairs(outline_system._unit_extension_data) do
        local pm = Managers.player
        local is_player = pm and pm:player_by_unit(unit)
        
        local is_dog = false
        if not is_player then
            local ext = ScriptUnit.has_extension(unit, "unit_data_system")
            local breed = ext and ext.breed and ext:breed()
            if breed and breed.name and (string.find(breed.name, "dog", 1, true) or string.find(breed.name, "mastiff", 1, true)) then
                is_dog = true
            end
        end

        if is_player or is_dog then
            pcall_safe(_set_vector3_for_materials, unit, "outline_color", default_outline_color, true)
        end
    end
end

mod:hook_safe("OutlineSystem", "update", function(self)
	if not mod:is_enabled() then return end
	if not mod:get("color_outlines") and not mod:get("color_dog_outlines") then return end
	if self._total_num_outlines == 0 then return end
	if not self._visible then return end

	local pm = Managers and Managers.player
	if not pm then return end

	for unit, extension in pairs(self._unit_extension_data) do
		local player = pm:player_by_unit(unit)

		if player and mod:get("color_outlines") then
			local top_outline = extension.outlines[1]

			if top_outline then
				local account_id = pcall_safe(_get_player_account_id, player)
				local slot = pcall_safe(_get_player_slot, player)

				local color = get_color_for_account_id(account_id, slot)

				if color then
					local color_vector = Vector3(color[2] / 255, color[3] / 255, color[4] / 255)
					Unit.set_vector3_for_materials(unit, "outline_color", color_vector, true)
				end
			end
		elseif not player and mod:get("color_dog_outlines") then
			local is_dog = false
			local ext = ScriptUnit.has_extension(unit, "unit_data_system")
			local breed = ext and ext.breed and ext:breed()
			if breed and breed.name and (string.find(breed.name, "dog", 1, true) or string.find(breed.name, "mastiff", 1, true)) then
				is_dog = true
			end

			if is_dog then
				local owner = nil
				local players = pm:players()
				if players then
					for _, p in pairs(players) do
						local p_unit = p.player_unit
						if p_unit and ALIVE[p_unit] then
							local spawner_ext = ScriptUnit.has_extension(p_unit, "companion_spawner_system")
							if spawner_ext and spawner_ext._spawned_units then
								for _, u in ipairs(spawner_ext._spawned_units) do
									if u == unit then
										owner = p
										break
									end
								end
							end
						end
						if owner then break end
					end
				end

				if owner then
					local top_outline = extension.outlines[1]
					if top_outline then
						local account_id = pcall_safe(_get_player_account_id, owner)
						local slot = pcall_safe(_get_player_slot, owner)

						local color = get_color_for_account_id(account_id, slot)

						if color then
							local color_vector = Vector3(color[2] / 255, color[3] / 255, color[4] / 255)
							Unit.set_vector3_for_materials(unit, "outline_color", color_vector, true)
						end
					end
				end
			end
		end
	end
end)

local in_gameplay_state = false

mod:hook_require("scripts/ui/view_elements/view_element_player_social_popup/view_element_player_social_popup_content_list", function(module)
	if module.from_player_info then
		local original_from_player_info = module.from_player_info

		module.from_player_info = function(parent, player_info)
			local popup_menu_items, num_menu_items = original_from_player_info(parent, player_info)

			if not player_info:is_own_player() and player_info:account_id() then
				local account_id = player_info:account_id()

				local _add_divider = function(at_index)
					local _get_next_list_item = function(at_index)
						local last_item_index = num_menu_items + 1
						local new_item = popup_menu_items[last_item_index]

						if new_item then
							table.clear(new_item)
						else
							new_item = {}
							popup_menu_items[last_item_index] = new_item
						end

						if at_index then
							popup_menu_items[last_item_index] = nil
							table.insert(popup_menu_items, at_index, new_item)
						end

						num_menu_items = last_item_index
						return new_item, last_item_index
					end

					local item, num_items = _get_next_list_item(at_index)
					item.blueprint = "group_divider"
					item.label = "divider_" .. num_items
				end

				local _get_next_list_item = function(at_index)
					local last_item_index = num_menu_items + 1
					local new_item = popup_menu_items[last_item_index]

					if new_item then
						table.clear(new_item)
					else
						new_item = {}
						popup_menu_items[last_item_index] = new_item
					end

					if at_index then
						popup_menu_items[last_item_index] = nil
						table.insert(popup_menu_items, at_index, new_item)
					end

					num_menu_items = last_item_index
					return new_item, last_item_index
				end

				_add_divider()

				local copy_button = _get_next_list_item()
				copy_button.blueprint = "button"
				copy_button.label = mod:localize("copy_account_id_button")
				copy_button.callback = function()
					if account_id then
						Clipboard.put(account_id)
						mod:notify(mod:localize("account_id_copied"))
					end
				end
				copy_button.on_pressed_sound = UISoundEvents.social_menu_see_player_profile
			end

			return popup_menu_items, num_menu_items
		end
	end
end)

mod.on_all_mods_loaded = function()
	local career_outlines = get_mod("CareerColourOutlines")
	if career_outlines and career_outlines:is_enabled() then
		mod:echo("{#color(255,50,50)}[ColorSelection] WARNING:{#reset()} CareerColourOutlines is enabled! It conflicts with this mod and will cause outline colors to bug out. Please disable it!")
	end

	mod:add_global_localize_strings({
		players_list_title = {
			en = "Customized Players",
		},
		preset_colors_title = {
			en = "Preset Colors",
		}
	})

	update_local_player_id()
	if mod.command then
		mod:command("cs_menu", "open color customizer menu", function() mod.open_color_customizer() end)
		mod:command("cs_sync", "sync/apply color settings", function()
			if UISettings and in_gameplay_state then
				apply_slot_colors()
				mod:notify("Colors synced")
			else
				mod:notify("Cannot sync colors outside of gameplay")
			end
		end)
	end

	local dmf = get_mod("DMF")
	if dmf then

		mod:hook(dmf, "check_keybinds", function(func)

			if Managers.ui and Managers.ui:view_active(color_customizer_view_name) then

				return
			end

			return func()
		end)
	end

	mod:hook_safe("HumanGameplay", "on_player_removed", function(self, player)
		_on_player_removed(player)

		if in_gameplay_state then
			mod:pcall(function()
				apply_slot_colors()
			end)
		end
	end)

	mod:hook_safe("GameModeManager", "on_player_unit_spawn", function(self, player, player_unit, is_respawn)
		if in_gameplay_state then
			mod:pcall(function()
				apply_slot_colors()
			end)
		end
	end)

	local slotfix = get_mod("SlotFix")
	if not slotfix then
		mod:echo("WARNING: SlotFix mod is required for ColorSelection to work properly!")
	end
end

mod.on_game_state_changed = function(status, state_name)
	update_local_player_id()

	if status == "enter" and state_name == "StateGameplay" then
		in_gameplay_state = true
		mod._mission_color_cache = {}
		apply_slot_colors()
	elseif status == "exit" and state_name == "StateGameplay" then
		in_gameplay_state = false
		restore_previous()
	end
end

mod.on_enabled = function()
	update_local_player_id()
	if UISettings and in_gameplay_state then
		apply_slot_colors()
	end
end

mod.on_disabled = function()
	if previous_slot_colors and UISettings and UISettings.player_slot_colors then
		restore_previous()

		if in_gameplay_state then
			apply_slot_colors()
		end
	end

	reset_team_panel_colors()
	reset_nameplate_colors()
	reset_character_outlines()
end

mod:hook_safe("PlayerManager", "add_player", function(self)
	if in_gameplay_state then
		mod:pcall(function()
			apply_slot_colors()
		end)
	end
end)

mod:hook_safe("PlayerManager", "add_bot_player", function(self)
	if in_gameplay_state then
		mod:pcall(function()
			apply_slot_colors()
		end)
	end
end)
mod:hook_safe("PlayerManager", "remove_player", function(self)
	if in_gameplay_state then
		mod:pcall(function()
			apply_slot_colors()
		end)
	end
end)

mod.on_setting_changed = function(setting_id)
	local triggers_update = false

	if setting_id == "color_by_class" and mod:get("color_by_class") then
		mod:set("randomize_slot_colors", false, true)
	elseif setting_id == "randomize_slot_colors" and mod:get("randomize_slot_colors") then
		mod:set("color_by_class", false, true)
	end

	if setting_id == "saved_player_colors" then
		cached_saved_colors = mod:get("saved_player_colors")
		cached_saved_colors_loaded = true
		triggers_update = true
	end
	if string.find(setting_id, "slot%d") or string.find(setting_id, "bot_") or setting_id == "bot" then
		triggers_update = true
	elseif setting_id == "color_bots" or setting_id == "color_by_class"
			or setting_id == "color_local_outside_mission" or setting_id == "color_custom_outside_mission" then
		triggers_update = true
	elseif setting_id == "randomize_slot_colors" then
		mod._randomized_slot_map = nil
		triggers_update = true
	elseif setting_id == "force_local_slot_1" then
		if mod:get("force_local_slot_1") == false then
			mod:set("color_local_outside_mission", false, true)
		end
		triggers_update = true
	else
		local classes = {"veteran", "zealot", "psyker", "ogryn", "broker", "adamant", "cryptic"}
		for _, class_name in ipairs(classes) do
			if string.find(setting_id, class_name) then
				triggers_update = true
				break
			end
		end
	end

	if triggers_update then
		if UISettings then
			apply_slot_colors()
		end
		update_player_panel_colors()
	end


	if setting_id == "color_outlines" or setting_id == "color_dog_outlines" then
	    if in_gameplay_state then
	        reset_character_outlines()
	    end
	end
end

mod.save_custom_player_colors = function(colors)
	mod:set("saved_player_colors", colors)
	if mod.on_setting_changed then
		mod.on_setting_changed("saved_player_colors")
	end
end

mod.on_game_state_changed = function(status, state_name)
	if status == "enter" and state_name == "StateGameplay" then
		mod._randomized_slot_map = nil
	end
end
