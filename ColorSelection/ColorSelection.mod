return {
  run = function()
    fassert(rawget(_G, "new_mod"), "`ColorSelection` encountered an error loading the Darktide Mod Framework.")

    new_mod("ColorSelection", {
      mod_script       = "ColorSelection/scripts/mods/ColorSelection/ColorSelection",
      mod_data         = "ColorSelection/scripts/mods/ColorSelection/ColorSelection_data",
      mod_localization = "ColorSelection/scripts/mods/ColorSelection/ColorSelection_localization",
    })
  end,
  packages = {},
  dependencies = {
    -- ColorSelection should load AFTER these mods to preserve their text formatting
    { mod_name = "true_level", optional = true },
    { mod_name = "who_are_you", optional = true },
  }
}
