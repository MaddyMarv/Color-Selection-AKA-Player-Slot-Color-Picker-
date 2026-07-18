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
        type = "group",
        tab = "Colors",
        sub_widgets = {
            {
                setting_id = prefix .. "_r",
                type = "numeric",
                default_value = defaults.r,
                range = {0,255},
            },
            {
                setting_id = prefix .. "_g",
                type = "numeric",
                default_value = defaults.g,
                range = {0,255},
            },
            {
                setting_id = prefix .. "_b",
                type = "numeric",
                default_value = defaults.b,
                range = {0,255},
            },
        }
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
        type = "group",
        tab = "Class Colors",
        sub_widgets = {
            {
                setting_id = class_name .. "_r",
                type = "numeric",
                default_value = defaults.r,
                range = {0,255},
            },
            {
                setting_id = class_name .. "_g",
                type = "numeric",
                default_value = defaults.g,
                range = {0,255},
            },
            {
                setting_id = class_name .. "_b",
                type = "numeric",
                default_value = defaults.b,
                range = {0,255},
            },
        }
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
        setting_id = "color_bots",
        type = "checkbox",
        default_value = true,
        title = "color_bots",
        tooltip = "color_bots_tooltip",
      },
    }
  }
}

for slot=1,4 do
    widgets[#widgets+1] = slot_widgets(slot)
end

local classes = {"veteran", "zealot", "psyker", "ogryn", "broker", "adamant", "cryptic"}
for _, class_name in ipairs(classes) do
    widgets[#widgets+1] = class_widgets(class_name)
end

widgets[#widgets+1] = {
    setting_id = "bot",
    type = "group",
    tab = "Colors",
    sub_widgets = {
        {
            setting_id = "bot_r",
            type = "numeric",
            default_value = 128,
            range = {0,255},
        },
        {
            setting_id = "bot_g",
            type = "numeric",
            default_value = 128,
            range = {0,255},
        },
        {
            setting_id = "bot_b",
            type = "numeric",
            default_value = 128,
            range = {0,255},
        },
    }
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
