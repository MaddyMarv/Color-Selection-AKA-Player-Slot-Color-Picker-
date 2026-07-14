local loc = {
  mod_name = {
    en = "Color Selection",
  },

  mod_description = {
    en = "Customize player colors in your game. Set default colors for each slot or create custom colors for specific players. Compatibility: For best results with TrueLevel and WhoAreYou mods, ensure ColorSelection loads AFTER them in your mod load order.",
  },

  general_settings = {
    en = "General Settings",
  },

  open_color_customizer_bind = {
    en = "Open Color Menu",
  },
  open_color_customizer_bind_tooltip = {
    en = "Press this key to open the color customization menu where you can edit slot colors and create custom colors for specific players.",
  },

  color_outlines = {
    en = "Color Player Outlines",
  },
  color_outlines_tooltip = {
    en = "Color the 3D player outlines (holograms visible through walls) using their customized slot colors. Requires a mod like PlayerOutlines that forces the game to render outlines.",
  },

  color_by_class = {
    en = "Color by Class",
  },
  color_by_class_tooltip = {
    en = "Override the default slot colors with the player's class (archetype) color. Custom Account ID colors will still take priority.",
  },

  player_color_header = {
    en = "Slot 1 Color (You)",
  },
  slot1_color_tooltip = {
    en = "This is your default color. You always occupy Slot 1 in any game you host or join.",
  },
  player2_color_header = {
    en = "Slot 2 Color",
  },
  slot2_color_tooltip = {
    en = "Default color for the player in Slot 2. You can also override this for specific players using the Color Menu.",
  },
  player3_color_header = {
    en = "Slot 3 Color",
  },
  slot3_color_tooltip = {
    en = "Default color for the player in Slot 3. You can also override this for specific players using the Color Menu.",
  },
  player4_color_header = {
    en = "Slot 4 Color",
  },
  slot4_color_tooltip = {
    en = "Default color for the player in Slot 4. You can also override this for specific players using the Color Menu.",
  },

  label_red = {
    en = "Red",
  },
  label_green = {
    en = "Green",
  },
  label_blue = {
    en = "Blue",
  },

  -- UI Element Name Coloring
  ui_coloring_header = {
    en = "UI Element Name Coloring",
  },

  color_hud_names = {
    en = "Color HUD Names",
  },

  color_hud_names_tooltip = {
    en = "Color player names in the team HUD panels (bottom-left corner).\nYour name and teammates' names will show in their custom slot colors.\nLevel/Havoc information from other mods will retain their separate colors.",
  },

  color_nameplate_names = {
    en = "Color Nameplate Names",
  },

  color_nameplate_names_tooltip = {
    en = "Color player names in floating nameplates (above heads in-game).\nThe class icon is always colored. Enable this to also color the player's name.\nLevel/Havoc information from other mods will retain their separate colors.",
  },

  color_chat_names = {
    en = "Color Chat Names",
  },

  color_chat_names_tooltip = {
    en = "Color player names in chat messages. Each player's messages will appear in their assigned color.",
  },

  color_lobby_names = {
    en = "Color Lobby Names",
  },

  color_lobby_names_tooltip = {
    en = "Color player names in the mission lobby (ready-up screen before starting a mission).",
  },

  color_scoreboard_names = {
    en = "Color Scoreboard Names",
  },

  color_scoreboard_names_tooltip = {
    en = "Color player names in the scoreboard (Tab menu/Tactical Overlay).",
  },

  color_combat_feed = {
    en = "Color Combat Feed",
  },

  color_combat_feed_tooltip = {
    en = "Color player names in the combat feed notifications (right side of screen).",
  },

  color_all_ui_names_tooltip = {
    en = "Color player names in this UI element. Colors are applied at the source, so they appear consistently across all game menus.",
  },

  -- Bot Color
  bot_color_header = {
    en = "Bot Color",
  },
  
  color_bots = {
    en = "Color Bots",
  },

  color_bots_tooltip = {
    en = "When enabled, bots will use the color specified below. When disabled, they will use the default game color.",
  },

  bot_color_tooltip = {
    en = "All bots will use this color. This ensures bots don't conflict with human player colors.",
  },

  -- Debug Mode
  debug_mode_group = {
    en = "Debug Mode",
  },

  debug_mode = {
    en = "Enable Debug Logging",
  },

  debug_mode_tooltip = {
    en = "When enabled, shows debug messages in console for troubleshooting slot assignments and color mappings. Turn this off for normal gameplay.",
  },

  -- Color Customizer
  color_customizer_title = {
    en = "Player Color Customizer",
  },
  player_id_label = {
    en = "Player ID",
  },
  account_id_placeholder = {
    en = "Enter Account ID",
  },
  button_apply = {
    en = "Apply",
  },
  button_save = {
    en = "Save",
  },
  button_close = {
    en = "Close",
  },
  button_reset = {
    en = "Reset",
  },
  button_reset_all = {
    en = "Reset All Players",
  },
  button_reset_all_slots = {
    en = "Reset All Slots",
  },
  button_list_players = {
    en = "List Players",
  },
  players_list_title = {
    en = "Customized Players",
  },
  page_info = {
    en = "Page %d / %d",
  },
  button_prev_page = {
    en = "Prev",
  },
  button_next_page = {
    en = "Next",
  },
  no_customized_players = {
    en = "No customized players",
  },
  error_no_account_id = {
    en = "Please enter an Account ID",
  },
  error_invalid_account_id = {
    en = "Invalid Account ID format (expected UUID)",
  },
  color_applied = {
    en = "Color applied successfully",
  },
  color_saved = {
    en = "Color saved successfully",
  },
  color_reset = {
    en = "Player color reset to slot-based color",
  },
  color_reset_all = {
    en = "All custom player ID colors have been reset",
  },
  slots_reset_all = {
    en = "All slot colors have been reset to defaults",
  },
  copy_account_id_button = {
    en = "Copy Account ID",
  },
  account_id_copied = {
    en = "Account ID copied to clipboard",
  },
  button_slot1 = {
    en = "Slot 1 (You)",
  },
  button_slot2 = {
    en = "Slot 2",
  },
  button_slot3 = {
    en = "Slot 3",
  },
  button_slot4 = {
    en = "Slot 4",
  },
  button_bot = {
    en = "Bot",
  },
  button_veteran = { en = "Vet" },
  button_zealot = { en = "Zea" },
  button_psyker = { en = "Psy" },
  button_ogryn = { en = "Ogr" },
  button_broker = { en = "Scum" },
  button_adamant = { en = "Arb" },
  button_cryptic = { en = "Skit" },
  slot_color_loaded = {
    en = "Slot {#color(255,255,255)}%s{#reset()} color loaded",
  },
  slot_color_saved = {
    en = "Slot {#color(255,255,255)}%s{#reset()} color saved",
  },
  editing_slot = {
    en = "Editing Slot {#color(255,255,255)}%s{#reset()}",
  },
  slot_color_reset = {
    en = "Slot {#color(255,255,255)}%s{#reset()} color reset to default",
  },
  
  -- Slot Settings
  slot1 = {
    en = "Slot 1 (Local Player)",
  },
  slot1_preset = {
    en = "Color Preset",
  },
  slot1_r = {
    en = "Red",
  },
  slot1_g = {
    en = "Green",
  },
  slot1_b = {
    en = "Blue",
  },
  
  slot2 = {
    en = "Slot 2",
  },
  slot2_preset = {
    en = "Color Preset",
  },
  slot2_r = {
    en = "Red",
  },
  slot2_g = {
    en = "Green",
  },
  slot2_b = {
    en = "Blue",
  },
  
  slot3 = {
    en = "Slot 3",
  },
  slot3_preset = {
    en = "Color Preset",
  },
  slot3_r = {
    en = "Red",
  },
  slot3_g = {
    en = "Green",
  },
  slot3_b = {
    en = "Blue",
  },
  
  slot4 = {
    en = "Slot 4",
  },
  slot4_preset = {
    en = "Color Preset",
  },
  slot4_r = {
    en = "Red",
  },
  slot4_g = {
    en = "Green",
  },
  slot4_b = {
    en = "Blue",
  },
  
  bot = {
    en = "Bot Color",
  },
  bot_preset = {
    en = "Color Preset",
  },
  bot_r = {
    en = "Red",
  },
  bot_g = {
    en = "Green",
  },
  bot_b = {
    en = "Blue",
  },
  
  veteran = { en = "Veteran Color" },
  veteran_preset = { en = "Color Preset" },
  veteran_r = { en = "Red" },
  veteran_g = { en = "Green" },
  veteran_b = { en = "Blue" },

  zealot = { en = "Zealot Color" },
  zealot_preset = { en = "Color Preset" },
  zealot_r = { en = "Red" },
  zealot_g = { en = "Green" },
  zealot_b = { en = "Blue" },

  psyker = { en = "Psyker Color" },
  psyker_preset = { en = "Color Preset" },
  psyker_r = { en = "Red" },
  psyker_g = { en = "Green" },
  psyker_b = { en = "Blue" },

  ogryn = { en = "Ogryn Color" },
  ogryn_preset = { en = "Color Preset" },
  ogryn_r = { en = "Red" },
  ogryn_g = { en = "Green" },
  ogryn_b = { en = "Blue" },
  
  broker = { en = "Hive Scum Color" },
  broker_preset = { en = "Color Preset" },
  broker_r = { en = "Red" },
  broker_g = { en = "Green" },
  broker_b = { en = "Blue" },

  adamant = { en = "Arbites Color" },
  adamant_preset = { en = "Color Preset" },
  adamant_r = { en = "Red" },
  adamant_g = { en = "Green" },
  adamant_b = { en = "Blue" },

  cryptic = { en = "Skitarii Color" },
  cryptic_preset = { en = "Color Preset" },
  cryptic_r = { en = "Red" },
  cryptic_g = { en = "Green" },
  cryptic_b = { en = "Blue" },

  enable_debug_mode = {
    en = "Enable Debug Logging",
  },
}

-- Add colored "Default" text for each slot's default color
local default_slot_colors = {
    {r = 226, g = 210, b = 117}, -- Slot 1 yellow
    {r = 180, g = 88,  b = 108}, -- Slot 2 red
    {r = 84,  g = 172, b = 121}, -- Slot 3 green
    {r = 126, g = 153, b = 230}, -- Slot 4 blue
    {r = 128, g = 128, b = 128}, -- Bot gray
}

for slot = 1, 4 do
    local c = default_slot_colors[slot]
    local text = string.format("{#color(%s,%s,%s)}Default{#reset()}", c.r, c.g, c.b)
    loc["default_slot" .. slot] = { en = text }
end

-- Bot default
local bot_c = default_slot_colors[5]
loc.default_bot = { en = string.format("{#color(%s,%s,%s)}Default{#reset()}", bot_c.r, bot_c.g, bot_c.b) }

-- Class defaults
local default_class_colors = {
    veteran = {r = 84,  g = 172, b = 121},
    zealot  = {r = 180, g = 88,  b = 108},
    psyker  = {r = 126, g = 153, b = 230},
    ogryn   = {r = 226, g = 210, b = 117},
    broker  = {r = 217, g = 104, b = 41},
    adamant = {r = 138, g = 43,  b = 226},
    cryptic = {r = 32,  g = 178, b = 170},
}
for class_name, c in pairs(default_class_colors) do
    loc["default_" .. class_name] = { en = string.format("{#color(%s,%s,%s)}Default{#reset()}", c.r, c.g, c.b) }
end

-- Generic default (fallback)
loc.default = { en = "Default" }

-- Auto-generate localization for all color names from Color.list
-- Display each color name in its actual color (like True Level does)
for _, color_name in ipairs(Color.list) do
    local c = Color[color_name](255, true)
    local text = string.format("{#color(%s,%s,%s)}%s{#reset()}", c[2], c[3], c[4], string.gsub(color_name, "_", " "))
    loc[color_name] = { en = text }
end

return loc
