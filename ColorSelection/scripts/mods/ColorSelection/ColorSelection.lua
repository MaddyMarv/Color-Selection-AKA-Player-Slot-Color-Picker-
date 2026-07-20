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
			local success, account_id = pcall(function() return local_player:account_id() end)
			if success and account_id and account_id ~= "" then
				mod._local_player_account_id = account_id
				return true
			end
		end
	end
	return false
end

local function pcall_safe(func)
	local success, result = pcall(func)
	return success and result or nil
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
	return {
		mod:get(prefix .. "_a") or CONSTANTS.MAX_COLOR_VALUE,
		mod:get(prefix .. "_r") or mod.get_default_color_value(prefix, "r"),
		mod:get(prefix .. "_g") or mod.get_default_color_value(prefix, "g"),
		mod:get(prefix .. "_b") or mod.get_default_color_value(prefix, "b"),
	}
end

local function get_local_player_slot()
	local pm = Managers and Managers.player
	if pm then
		local local_player = pm:local_player_safe(1)
		if local_player then
			local success, slot = pcall(function() return local_player:slot() end)
			if success and slot then
				return slot
			end
		end
	end
	return 1
end

local function get_slot_color(slot, is_local_player, is_bot)
	if is_local_player then
		return get_color("slot1")
	end

	if is_bot then
		if mod:get("color_bots") ~= false then
			return get_color("bot")
		end
	end

	if slot and slot >= 1 and slot <= 4 then
		local lp_slot = get_local_player_slot()
		if lp_slot ~= 1 and slot == 1 then

			return get_color("slot" .. lp_slot)
		end
		return get_color("slot" .. slot)
	end

	return nil
end

local function is_in_non_mission_context()
	local mechanism_name = nil
	if Managers.mechanism then
		local success, result = pcall(function() return Managers.mechanism:mechanism_name() end)
		if success then mechanism_name = result end
	end

	local mission_name = nil
	if Managers.state and Managers.state.mission then
		local success, result = pcall(function() return Managers.state.mission:mission_name() end)
		if success then mission_name = result end
	end

	if mechanism_name == "left_session" or mechanism_name == "hub" then
		return true
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
	local profile = pcall_safe(function() return player:profile() end)
	if profile and profile.archetype and profile.archetype.name then
		local archetype = profile.archetype.name
		if archetype == "veteran" or archetype == "zealot" or archetype == "psyker" or archetype == "ogryn" or archetype == "broker" or archetype == "adamant" or archetype == "cryptic" then
			return get_color(archetype)
		end
	end
	return nil
end

get_color_for_account_id = function(account_id, slot)
	if not mod._local_player_account_id then
		update_local_player_id()
	end

	local saved_colors = mod:get("saved_player_colors")
	if saved_colors and type(saved_colors) == "table" and saved_colors[account_id] then
		local c = saved_colors[account_id]
		if c and type(c) == "table" then
			return {255, c.r or 255, c.g or 255, c.b or 255}
		end
	end

	local is_local = account_id and account_id ~= "" and mod._local_player_account_id == account_id

	if is_in_non_mission_context() and not is_local then
		return {255, 169, 191, 153}
	end

	if not account_id or account_id == "" then
		if mod:get("color_bots") ~= false then
			return get_color("bot")
		end
	end

	local player = nil
	local pm = Managers and Managers.player
	if pm then
		if account_id and account_id ~= "" then
			local human_players = pm:human_players()
			if human_players then
				for _, p in pairs(human_players) do
					local success, pid = pcall(function() return p:account_id() end)
					if success and pid == account_id then
						player = p
						break
					end
				end
			end
		elseif slot then
			local bot_players = pm:bot_players()
			if bot_players then
				for _, p in pairs(bot_players) do
					local success, s = pcall(function() return p:slot() end)
					if success and s == slot then
						player = p
						break
					end
				end
			end
		end
	end

	if mod:get("color_by_class") and player then
		local class_color = get_class_color(player)
		if class_color then return class_color end
	end

	if not slot then
		local player_slot = nil
		if player then
			local success, s = pcall(function() return player:slot() end)
			if success and s then
				player_slot = s
			end
		end

		if not player_slot then
			if is_local then
				slot = 1
			else
				return nil
			end
		else
			slot = player_slot
		end
	end

	return get_slot_color(slot, is_local, false)
end

local function _on_player_removed(player)
	if not player then return end

	local success, account_id = pcall(function() return player:account_id() end)
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

				local human_success, is_human = pcall(function() return player:is_human_controlled() end)
				local bot_success, is_bot = pcall(function() return player:is_bot() end)
				local id_success, account_id = pcall(function() return player:account_id() end)

				if not (human_success and is_human) then goto skip_cache end
				if bot_success and is_bot then goto skip_cache end
				if not (id_success and account_id and account_id ~= "") then goto skip_cache end

				local slot_success, slot = pcall(function() return player:slot() end)
				if slot_success and slot then _player_cache.by_slot[slot] = player end
				if id_success and account_id then _player_cache.by_account_id[account_id] = player end

				::skip_cache::
			end
		end
	end
	_player_cache.last_update = os.clock()
end

local function get_player_by_slot(slot)
	if not slot then return nil end

	local current_time = os.clock()
	if current_time - _player_cache.last_update > 0.5 then
		update_player_cache()
	end

	return _player_cache.by_slot[slot]
end

local function get_player_by_account_id(account_id)
	if not account_id then return nil end

	local current_time = os.clock()
	if current_time - _player_cache.last_update > 0.5 then
		update_player_cache()
	end

	return _player_cache.by_account_id[account_id]
end

local function apply_color_to_name_only(text, color)
	if not text or type(text) ~= "string" or not color then
		return text
	end

	local c = color
	local target_color_tag = string.format("{#color(%d,%d,%d)}", c[2], c[3], c[4])
	local stripped_text = text:gsub("^{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}$", "")

	return target_color_tag .. stripped_text .. "{#reset()}"
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

		local success, result = pcall(function() return player:slot() end)
		if success and result then
			slot = result
		end

		local id_success, id_result = pcall(function() return player:account_id() end)
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
				local success, result = pcall(function() return player:account_id() end)
				if success then
					account_id = result
				end
			end
		end
	end

	if not slot then
		return
	end

	if slot >= 1 and slot <= 4 and mod.apply_slot_colors and not is_in_non_mission_context() then
		if not mod._known_slot_account_ids then mod._known_slot_account_ids = {} end
		if mod._known_slot_account_ids[slot] ~= account_id then
			mod._known_slot_account_ids[slot] = account_id
			mod:pcall(function()
				mod.apply_slot_colors()
			end)
		end
	end

	local color = get_color_for_account_id(account_id, slot)

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
		widget.content.text = new_text
		widget.dirty = true
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
			local id_success, id_result = pcall(function() return player:account_id() end)
			if id_success and id_result then
				account_id = id_result
			end


			local color = get_color_for_account_id(account_id)

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

    local slot = pcall_safe(function() return player:slot() end)
    local account_id = pcall_safe(function() return player:account_id() end)

    local is_saved_friend = false
    local saved_colors = mod:get("saved_player_colors")
    if account_id and saved_colors and type(saved_colors) == "table" and saved_colors[account_id] then
        is_saved_friend = true
    end

    local is_local_player = account_id and account_id ~= "" and mod._local_player_account_id == account_id

    if is_in_non_mission_context() and not is_saved_friend and not is_local_player then
        return
    end

    local marker_type = marker.type
    if not is_saved_friend and not is_local_player and marker_type and marker_type:match("hub") then
        local widget = marker.widget
        local content = widget and widget.content
        if content then
            local changed = false
            if content.header_text then
                local stripped = content.header_text:gsub("{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}", "")
                if content.header_text ~= stripped then
                    content.header_text = stripped
                    changed = true
                end
            end
            if content.icon_text then
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
        end
        return
    end

    local color = get_color_for_account_id(account_id, slot)
    
    local widget = marker.widget
    local content = widget and widget.content
    
    if not color then
        if content then
            local changed = false
            if content.header_text then
                local stripped = content.header_text:gsub("{#color%([^%)]*%)}", ""):gsub("{#reset%(%)}", "")
                if content.header_text ~= stripped then
                    content.header_text = stripped
                    changed = true
                end
            end
            if content.icon_text then
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
        end
        return
    end

    if not content or not content.header_text then
        return
    end

    local color_tag = string.format("{#color(%d,%d,%d)}", color[2], color[3], color[4])

    local header = content.header_text

    local player_name = pcall_safe(function() return player:name() end)
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

    if name_start then

        local before_name = clean_name_part:sub(1, name_start - 1)
        local after_name = clean_name_part:sub(name_end + 1)
        local new_name_part = color_tag .. before_name .. player_name .. "{#reset()}" .. after_name


        local new_header = new_name_part
        if title_part and title_part ~= "" then
            new_header = new_header .. "\n" .. title_part
        end

        content.header_text = new_header
        marker._cs_last_header = nil

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

for _, template_path in ipairs(companion_templates) do
	mod:hook_require(template_path, function(template)
		if not template or not template.on_enter then return end

		local original_on_enter = template.on_enter
		template.on_enter = function(widget, marker)
			original_on_enter(widget, marker)

			if not mod:is_enabled() or not marker or not marker.data then return end

			local data = marker.data
			local content = widget.content
			if not content then return end

			local player_slot = pcall_safe(function() return data:slot() end)
			local account_id = pcall_safe(function() return data:account_id() end)

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

	if marker_type and (marker_type:match("nameplate") or marker_type:match("companion")) then
		if self._markers_by_id then
			for marker_id, marker in pairs(self._markers_by_id) do
				if marker.unit == unit then


					if marker.widget and marker.widget.content and marker.widget.content.header_text then
						apply_nameplate_color(marker)
					end
					break
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

	local success, world_markers = pcall(function() return hud:element("HudElementWorldMarkers") end)
	if not success or not world_markers or not world_markers._markers_by_id then return end

	for marker_id, marker in pairs(world_markers._markers_by_id) do
		local marker_type = marker.type
		if marker_type and (marker_type:match("nameplate") or marker_type:match("companion")) then
			apply_nameplate_color(marker)
		end
	end
end)

mod:hook(CLASS.ConstantElementChat, "_participant_displayname", function(func, self, participant)
	local display_name = func(self, participant)

	if not display_name then
		return nil
	end

	if not mod:is_enabled() then
		return display_name
	end

	local account_id = participant and participant.account_id
	if not account_id then
		return display_name
	end

	local slot = nil
	local player = get_player_by_account_id(account_id)
	if player then
		slot = pcall_safe(function() return player:slot() end)
	end

	local color = get_color_for_account_id(account_id, slot)
	if not color then
		return display_name
	end

	if color then
		local color_tag = string.format("{#color(%d,%d,%d)}", color[2], color[3], color[4])
		local result = color_tag .. display_name .. "{#reset()}"
		return result
	end

	return display_name
end)

local function apply_color_to_player_name(name, player)
	if not name or name == "" or not player then
		return name
	end

	local account_id = pcall_safe(function() return player:account_id() end)
	if not account_id or account_id == "" then
		return name
	end

	local color = get_color_for_account_id(account_id)

	if color then
		local color_tag = string.format("{#color(%d,%d,%d)}", color[2], color[3], color[4])
		return color_tag .. name .. "{#reset()}"
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

	local color = {
		255,
		mod:get("slot1_r"),
		mod:get("slot1_g"),
		mod:get("slot1_b"),
	}
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
			self._player_slot = nil

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

			local success, slot = pcall(function() return player:slot() end)
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
				local success, slot = pcall(function() return player:slot() end)
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

	local nameplates_element = hud:element("HudElementNameplates")
	if not nameplates_element then return false end

	local nameplate_units = nameplates_element._nameplate_units
	local companion_nameplates = nameplates_element._companion_nameplates


	nameplates_element._scan_delay_duration = 0
	if nameplates_element._nameplate_extension_scan then
		pcall_safe(function() nameplates_element:_nameplate_extension_scan() end)
	end

	for marker_id, marker in pairs(world_markers._markers_by_id) do
		local marker_type = marker.type

		if marker_type and (marker_type:match("nameplate") or marker_type:match("companion")) then
			marker.wru_modified = false
			marker.tl_modified = false
			marker._cs_last_header = nil
			apply_nameplate_color(marker)


			if nameplate_units and marker.unit then
				local unit_data = nameplate_units[marker.unit]
				if unit_data then
					unit_data.synced = false
				end
			end
		end
	end

	if nameplates_element._nameplate_extension_scan then
		pcall_safe(function() nameplates_element:_nameplate_extension_scan() end)
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

local last_debug_state = ""
local logged_reassignments = {}

local apply_slot_colors_internal

local color_assignment_queue = {}
local is_processing_queue = false

local function process_next_in_queue()
	if is_processing_queue or #color_assignment_queue == 0 then
		return
	end

	is_processing_queue = true
	local queue_size = #color_assignment_queue
	local debug_mode = mod:get("debug_mode")

	if queue_size > 1 then
		local msg = string.format("[ColorSelection] Processing queue with %d operations (RACE CONDITION PREVENTED!)", queue_size)
		mod:info(msg)
		if debug_mode then
			mod:echo(msg)
		end
	end

	local operation_count = 0
	while #color_assignment_queue > 0 do
		local operation = table.remove(color_assignment_queue, 1)
		operation_count = operation_count + 1
		if debug_mode then
			local msg = string.format("[ColorSelection] Executing queued operation %d/%d", operation_count, queue_size)
			mod:info(msg)
			mod:echo(msg)
		end
		operation()
	end
	is_processing_queue = false
end

local function queue_color_assignment()
	local queue_position = #color_assignment_queue + 1
	local debug_mode = mod:get("debug_mode")

	if debug_mode then
		local msg = string.format("[ColorSelection] Queueing color assignment (position %d)", queue_position)
		mod:info(msg)
		mod:echo(msg)
	end

	table.insert(color_assignment_queue, function() apply_slot_colors_internal() end)
	process_next_in_queue()
end

apply_slot_colors_internal = function()
	if not UISettings then
		return
	end

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

			local account_id = nil
			local player = get_player_by_slot(k)
			if player then
				local success, result = pcall(function() return player:account_id() end)
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

	for i = 1, 5 do
		local account_id = nil
		local player = get_player_by_slot(i)
		if player then
			local success, result = pcall(function() return player:account_id() end)
			if success then
				account_id = result
			end
		end

		local color = get_color_for_account_id(account_id, i)
		if color then
			current_table[i] = color
		end
	end

	UISettings.player_slot_colors = setmetatable(current_table, color_metatable)

	mod._colors_revision = mod._colors_revision + 1
	UISettings._colors_revision = (UISettings._colors_revision or 0) + 1
	update_player_panel_colors()

	local debug_enabled = mod:get("debug_mode")
	if debug_enabled then
		mod:echo("[ColorSelection] Slot colors applied successfully")
	else
		mod:info("[ColorSelection] Slot colors applied successfully")
	end
end

local function apply_slot_colors()
	queue_color_assignment()
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
        if p and p._widgets_by_name and p._widgets_by_name.player_name then
            local widget = p._widgets_by_name.player_name
            if widget.content and widget.content.text then
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
            if marker.widget and marker.widget.content and marker.widget.content.header_text then
                marker.widget.content.header_text = _strip_cs_color_tags(marker.widget.content.header_text)
                marker._cs_last_header = nil
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
        if is_player then
            pcall_safe(function()
                Unit.set_vector3_for_materials(unit, "outline_color", default_outline_color, true)
            end)
        end
    end
end

mod:hook_safe("OutlineSystem", "update", function(self)
	if not mod:is_enabled() then return end
	if not mod:get("color_outlines") then return end
	if self._total_num_outlines == 0 then return end
	if not self._visible then return end

	local pm = Managers and Managers.player
	if not pm then return end

	for unit, extension in pairs(self._unit_extension_data) do
		local player = pm:player_by_unit(unit)

		if player then
			local top_outline = extension.outlines[1]

			if top_outline then
				local account_id = pcall_safe(function() return player:account_id() end)
				local slot = pcall_safe(function() return player:slot() end)

				local color = get_color_for_account_id(account_id, slot)

				if color then
					local color_vector = Vector3(color[2] / 255, color[3] / 255, color[4] / 255)
					Unit.set_vector3_for_materials(unit, "outline_color", color_vector, true)
				end
			end
		end
	end
end)

mod.on_disabled = function()

    restore_previous()

    reset_team_panel_colors()
    reset_nameplate_colors()
    reset_character_outlines()
end

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
				update_player_panel_colors()
			end)
		end
	end)

	mod:hook_safe("GameModeManager", "on_player_unit_spawn", function(self, player, player_unit, is_respawn)
		if in_gameplay_state then
			mod:pcall(function()
				apply_slot_colors()
				update_player_panel_colors()
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
			update_player_panel_colors()
		end
	end
end

mod.on_setting_changed = function(setting_id)
	local triggers_update = false
	if string.find(setting_id, "slot%d") or string.find(setting_id, "bot_") then
		triggers_update = true
	elseif setting_id == "color_bots" or setting_id == "color_by_class" then
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
		if UISettings and in_gameplay_state then
			apply_slot_colors()
		end
		update_player_panel_colors()
	end


	if setting_id == "color_outlines" then
	    if not mod:get("color_outlines") and in_gameplay_state then
	        reset_character_outlines()
	    end
	end
end
