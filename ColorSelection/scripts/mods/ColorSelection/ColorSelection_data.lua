local mod = get_mod("ColorSelection")

local default_slot_colors = {
    {r = 226, g = 210, b = 117},
    {r = 180, g = 88,  b = 108},
    {r = 84,  g = 172, b = 121},
    {r = 126, g = 153, b = 230},
    {r = 128, g = 128, b = 128},
}

local function slot_widgets(slot)
    local prefix = string.format("slot%d", slot)
    local defaults = default_slot_colors[slot]

    return {
        setting_id = prefix,
        type = "color",
        tab = "Colors",
        default_value = {255, defaults.r, defaults.g, defaults.b},
    }
end

local default_class_colors = {
    veteran = {r = 84,  g = 172, b = 121},
    zealot  = {r = 180, g = 88,  b = 108},
    psyker  = {r = 126, g = 153, b = 230},
    ogryn   = {r = 226, g = 210, b = 117},
    broker  = {r = 217, g = 104, b = 41},
    adamant = {r = 138, g = 43,  b = 226},
    cryptic = {r = 32,  g = 178, b = 170},
}

local function class_widgets(class_name)
    local defaults = default_class_colors[class_name]

    return {
        setting_id = class_name,
        type = "color",
        tab = "Class Colors",
        default_value = {255, defaults.r, defaults.g, defaults.b},
    }
end

local widgets = {
  {
    setting_id = "general_settings",
    type = "group",
    tab = "General",
    sub_widgets = {
      {
        setting_id = "open_color_customizer_bind",
        type = "keybind",
        title = "open_color_customizer_bind",
        tooltip = "open_color_customizer_bind_tooltip",
        default_value = {},
        keybind_trigger = "pressed",
        keybind_type = "function_call",
        function_name = "open_color_customizer"
      },
      {
        setting_id = "force_local_slot_1",
        type = "checkbox",
        default_value = true,
      },
      {
        setting_id = "color_by_class",
        type = "checkbox",
        default_value = false,
        title = "color_by_class",
        tooltip = "color_by_class_tooltip",
      },
      {
        setting_id = "color_outlines",
        type = "checkbox",
        default_value = true,
        title = "color_outlines",
        tooltip = "color_outlines_tooltip",
      },
      {
        setting_id = "color_dog_outlines",
        type = "checkbox",
        default_value = true,
        title = "color_dog_outlines",
        tooltip = "color_dog_outlines_tooltip",
      },
      {
        setting_id = "color_bots",
        type = "checkbox",
        default_value = true,
        title = "color_bots",
        tooltip = "color_bots_tooltip",
      },
      {
        setting_id = "color_local_outside_mission",
        type = "checkbox",
        default_value = true,
        title = "color_local_outside_mission",
        tooltip = "color_local_outside_mission_tooltip",
      },
      {
        setting_id = "color_custom_outside_mission",
        type = "checkbox",
        default_value = true,
        title = "color_custom_outside_mission",
        tooltip = "color_custom_outside_mission_tooltip",
      },
      {
        setting_id = "chat_local_name_style",
        type = "dropdown",
        default_value = "colored_you",
        options = {
          { text = "chat_style_vanilla", value = "vanilla" },
          { text = "chat_style_colored_you", value = "colored_you" },
          { text = "chat_style_character", value = "character" },
          { text = "chat_style_account", value = "account" },
        },
        title = "chat_local_name_style",
        tooltip = "chat_local_name_style_tooltip",
      },
    }
  }
}

local slot_sub_widgets = {}
for slot=1,4 do
    slot_sub_widgets[#slot_sub_widgets+1] = slot_widgets(slot)
end
slot_sub_widgets[#slot_sub_widgets+1] = {
    setting_id = "bot",
    type = "color",
    tab = "Colors",
    default_value = {255, 128, 128, 128},
}

widgets[#widgets+1] = {
    setting_id = "slot_colors_group",
    type = "group",
    tab = "Colors",
    sub_widgets = slot_sub_widgets
}

local class_sub_widgets = {}
local classes = {"veteran", "zealot", "psyker", "ogryn", "broker", "adamant", "cryptic"}
for _, class_name in ipairs(classes) do
    local cw = class_widgets(class_name)
    cw.tab = "Colors" -- Force it to stay on the same tab
    class_sub_widgets[#class_sub_widgets+1] = cw
end

widgets[#widgets+1] = {
    setting_id = "class_colors_group",
    type = "group",
    tab = "Colors",
    sub_widgets = class_sub_widgets
}

widgets[#widgets+1] = {
  setting_id = "debug_mode_group",
  type = "group",
  tab = "Debug",
  title = "debug_mode_group",
  sub_widgets = {
    {
      type = "checkbox",
      setting_id = "debug_mode",
      default_value = false,
      tooltip = "debug_mode_tooltip",
    },
  },
}

return {
  name = mod:localize("mod_name"),
  description = mod:localize("mod_description"),
  is_togglable = true,
  options = {
    widgets = widgets
  },
}
