local mod = get_mod("ColorSelection")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local TextInputPassTemplates = require("scripts/ui/pass_templates/text_input_pass_templates")
local ColorUtilities = require("scripts/utilities/ui/colors")

local grid_spacing = { 10, 10 }
local preset_grid_width = 400
local preset_window_size = { preset_grid_width, 760 }
local preset_grid_size = { preset_grid_width, 760 }
local preset_element_size = { 380, 70 }
local preset_grid_settings = {
	scrollbar_width = 7,
	use_terminal_background = true,
	title_height = 70,
	top_padding = 20,
	grid_spacing = grid_spacing,
	grid_size = preset_grid_size,
	mask_size = preset_window_size,
	edge_padding = 20,
}

local players_grid_width = 400
local players_window_size = { players_grid_width, 760 }
local players_grid_size = { players_grid_width, 760 }
local players_element_size = { 350, 30 }
local players_grid_settings = {
	scrollbar_width = 7,
	use_terminal_background = true,
	title_height = 70,
	top_padding = 20,
	grid_spacing = { 0, 5 },
	grid_size = players_grid_size,
	mask_size = players_window_size,
	edge_padding = 20,
}


local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    background = {
        parent = "screen",
        scale = "fit",
        size = { 1920, 1080 },
        position = { 0, 0, 0 }
    },
    window = {
        parent = "background",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 600, 760 },
        position = { 0, 0, 0 }
    },
    preset_grid_pivot = {
        parent = "background",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 0, 0 },
        position = { -730, -380, 10 }
    },
    player_info_text = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { 550, 60 },
        position = { 0, 20, 0 }
    },
    slot_buttons_container = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { 550, 50 },
        position = { 0, 90, 0 }
    },
    slot1_button = {
        parent = "slot_buttons_container",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 100, 40 },
        position = { -220, 0, 0 }
    },
    slot2_button = {
        parent = "slot_buttons_container",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 100, 40 },
        position = { -110, 0, 0 }
    },
    slot3_button = {
        parent = "slot_buttons_container",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 100, 40 },
        position = { 0, 0, 0 }
    },
    slot4_button = {
        parent = "slot_buttons_container",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 100, 40 },
        position = { 110, 0, 0 }
    },
    bot_button = {
        parent = "slot_buttons_container",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 100, 40 },
        position = { 220, 0, 0 }
    },
    class_buttons_container = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { 550, 40 },
        position = { 0, 140, 0 }
    },
    veteran_button = {
        parent = "class_buttons_container",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 70, 30 },
        position = { -240, 0, 0 }
    },
    zealot_button = {
        parent = "class_buttons_container",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 70, 30 },
        position = { -160, 0, 0 }
    },
    psyker_button = {
        parent = "class_buttons_container",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 70, 30 },
        position = { -80, 0, 0 }
    },
    ogryn_button = {
        parent = "class_buttons_container",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 70, 30 },
        position = { 0, 0, 0 }
    },
    broker_button = {
        parent = "class_buttons_container",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 70, 30 },
        position = { 80, 0, 0 }
    },
    adamant_button = {
        parent = "class_buttons_container",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 70, 30 },
        position = { 160, 0, 0 }
    },
    cryptic_button = {
        parent = "class_buttons_container",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 70, 30 },
        position = { 240, 0, 0 }
    },
    account_id_input = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { 550, 40 },
        position = { 0, 190, 10 }
    },
    color_preview = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { 150, 150 },
        position = { 0, 250, 0 }
    },
    red_slider = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "left",
        size = { 450, 30 },
        position = { 30, 430, 5 }
    },
    red_input = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "right",
        size = { 80, 30 },
        position = { -30, 430, 10 }
    },
    green_slider = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "left",
        size = { 450, 30 },
        position = { 30, 480, 5 }
    },
    green_input = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "right",
        size = { 80, 30 },
        position = { -30, 480, 10 }
    },
    blue_slider = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "left",
        size = { 450, 30 },
        position = { 30, 530, 5 }
    },
    blue_input = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "right",
        size = { 80, 30 },
        position = { -30, 530, 10 }
    },
    hex_input = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { 200, 40 },
        position = { 0, 590, 10 }
    },
    apply_button = {
        parent = "window",
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        size = { 180, 40 },
        position = { 20, -20, 0 }
    },
    save_button = {
        parent = "window",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { 180, 40 },
        position = { 0, -20, 0 }
    },
    reset_button = {
        parent = "window",
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        size = { 180, 40 },
        position = { 20, -70, 0 }
    },
    reset_all_button = {
        parent = "window",
        vertical_alignment = "bottom",
        horizontal_alignment = "right",
        size = { 180, 40 },
        position = { -20, -70, 0 }
    },
    reset_all_slots_button = {
        parent = "window",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { 180, 40 },
        position = { 0, -70, 0 }
    },
    close_button = {
        parent = "window",
        vertical_alignment = "bottom",
        horizontal_alignment = "right",
        size = { 180, 40 },
        position = { -20, -20, 0 }
    },
    players_panel = {
        parent = "window",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 400, 760 },
        position = { 510, 0, 10 }
    },
    players_grid_pivot = {
        parent = "players_panel",
        vertical_alignment = "top",
        horizontal_alignment = "left",
        size = { 0, 0 },
        position = { 0, 0, 10 }
    },
}


local function item_change_function(content, style)
	local hotspot = content.hotspot
	local is_selected = hotspot.is_selected
	local is_focused = hotspot.is_focused
	local is_hover = hotspot.is_hover
	local default_color = style.default_color
	local selected_color = style.selected_color
	local hover_color = style.hover_color
	local color

	if is_selected or is_focused then
		color = selected_color
	elseif is_hover then
		color = hover_color
	else
		color = default_color
	end

	local progress = math.max(math.max(hotspot.anim_hover_progress or 0, hotspot.anim_select_progress or 0), hotspot.anim_focus_progress or 0)

	ColorUtilities.color_lerp(default_color, color, progress, style.color)
end

local blueprints = {
	color_box = {
		size = preset_element_size,
		pass_template = {
			{
				pass_type = "hotspot",
				content_id = "hotspot",
				style = {
					on_hover_sound = UISoundEvents.default_mouse_hover,
					on_pressed_sound = UISoundEvents.default_click,
				}
			},
			{
				pass_type = "texture",
				style_id = "background",
				value = "content/ui/materials/backgrounds/default_square",
				style = {
					default_color = Color.terminal_background(nil, true),
					selected_color = Color.terminal_background_selected(nil, true)
				},
				change_function = ButtonPassTemplates.terminal_button_change_function,
			},
			{
				pass_type = "texture",
				style_id = "background_gradient",
				value = "content/ui/materials/gradients/gradient_vertical",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					default_color = Color.terminal_background_gradient(nil, true),
					selected_color = Color.terminal_frame_selected(nil, true),
					offset = { 0, 0, 2 },
				},
				change_function = function (content, style)
					ButtonPassTemplates.terminal_button_change_function(content, style)
					ButtonPassTemplates.terminal_button_hover_change_function(content, style)
				end,
			},
			{
				value = "content/ui/materials/frames/dropshadow_medium",
				style_id = "outer_shadow",
				pass_type = "texture",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					scale_to_material = true,
					color = Color.black(100, true),
					size_addition = { 20, 20 },
					offset = { 0, 0, 3 },
				}
			},
			{
				pass_type = "rect",
				style_id = "color_icon",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "left",
					color = Color.black(255, true),
					size = { 50, 50 },
					offset = { 10, 0, 7 },
				},
			},
			{
				pass_type = "rect",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "left",
					color = Color.white(255, true),
					size = { 50, 50 },
					offset = { 10, 0, 5 },
				},
			},
			{
				style_id = "color_name",
				pass_type = "text",
				value = "",
				value_id = "color_name",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "left",
					text_vertical_alignment = "center",
					text_horizontal_alignment = "left",
					offset = { 75, 0, 10 },
					size = { preset_element_size[1] - 80, preset_element_size[2] },
					text_color = Color.terminal_text_header(255, true),
					font_type = "proxima_nova_bold",
					font_size = 21,
				},
			},
			{
				pass_type = "texture",
				style_id = "frame",
				value = "content/ui/materials/frames/frame_tile_2px",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					color = Color.terminal_frame(nil, true),
					default_color = Color.terminal_frame(nil, true),
					selected_color = Color.terminal_frame_selected(nil, true),
					hover_color = Color.terminal_frame_hover(nil, true),
					offset = { 0, 0, 2 },
				},
				change_function = item_change_function,
			},
			{
				pass_type = "texture",
				style_id = "corner",
				value = "content/ui/materials/frames/frame_corner_2px",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					color = Color.terminal_corner(nil, true),
					default_color = Color.terminal_corner(nil, true),
					selected_color = Color.terminal_corner_selected(nil, true),
					hover_color = Color.terminal_corner_hover(nil, true),
					offset = { 0, 0, 3 },
				},
				change_function = item_change_function,
			},
		},
		init = function (parent, widget, element, callback_name)
			local content = widget.content
			local style = widget.style

			content.hotspot.pressed_callback = callback_name and callback(parent, callback_name, widget, element)
			content.color_name = element.color_name
			style.color_icon.color = element.color_data
		end,
		update = function (parent, widget, input_service, dt, t, ui_renderer)
			local content = widget.content
			content.hotspot.is_selected = false
		end,
	},
	preset_header = {
		size = { 350, 40 },
		pass_template = {
			{
				pass_type = "text",
				value = "",
				value_id = "text",
				style = {
					text_vertical_alignment = "center",
					text_horizontal_alignment = "center",
					font_type = "machine_medium",
					font_size = 24,
					text_color = Color.terminal_text_header(255, true),
					offset = { 0, 0, 1 },
				},
			},
			{
				pass_type = "rect",
				style = {
					color = Color.terminal_frame(100, true),
					size = { 350, 2 },
					vertical_alignment = "bottom",
					offset = { 0, 0, 0 },
				}
			}
		},
		init = function (parent, widget, element, callback_name)
			widget.content.text = element.text
		end,
	},
	spacing_vertical = {
		size = { preset_grid_width, 20 },
	},
	player_entry = {
		size = players_element_size,
		pass_template = {
			{
				pass_type = "hotspot",
				content_id = "hotspot",
				style = {
					on_hover_sound = UISoundEvents.default_mouse_hover,
					on_pressed_sound = UISoundEvents.default_click,
				}
			},
			{
				pass_type = "rect",
				style_id = "background",
				style = {
					color = Color.terminal_background(0, true),
					offset = { 0, 0, 0 }
				},
				change_function = function (content, style)
					local hotspot = content.hotspot
					if hotspot.is_hover then
						style.color[1] = 50
					else
						style.color[1] = 0
					end
				end,
			},
			{
				pass_type = "rect",
				style_id = "color_swatch",
				style = {
					color = { 255, 255, 255, 255 },
					size = { 30, 20 },
					offset = { 10, 5, 1 },
				},
			},
			{
				style_id = "player_name",
				pass_type = "text",
				value = "",
				value_id = "player_name",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "left",
					text_vertical_alignment = "center",
					text_horizontal_alignment = "left",
					offset = { 50, 0, 2 },
					size = { players_element_size[1] - 100, players_element_size[2] },
					text_color = Color.terminal_text_body(255, true),
					font_type = "machine_medium",
					font_size = 16,
				},
			},
			{
				style_id = "account_id",
				pass_type = "text",
				value = "",
				value_id = "account_id",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "right",
					text_vertical_alignment = "center",
					text_horizontal_alignment = "right",
					offset = { -10, 0, 2 },
					size = { 80, players_element_size[2] },
					text_color = Color.terminal_text_header(180, true),
					font_type = "machine_medium",
					font_size = 12,
				},
			},
		},
		init = function (parent, widget, element, callback_name)
			local content = widget.content
			local style = widget.style

			content.hotspot.pressed_callback = callback_name and callback(parent, callback_name, widget, element)
			content.player_name = element.player_name or ""
			content.account_id = element.account_id_short or ""

			if element.color and style.color_swatch then
				local rgb = element.color
				if type(rgb) == "table" then
					local r, g, b
					if #rgb == 3 then
						r, g, b = rgb[1], rgb[2], rgb[3]
					elseif #rgb == 4 then
						r, g, b = rgb[2], rgb[3], rgb[4]
					else
						r, g, b = rgb.r or 255, rgb.g or 255, rgb.b or 255
					end
					style.color_swatch.color = { 255, r, g, b }
				end
			end
		end,
		update = function (parent, widget, input_service, dt, t, ui_renderer)
			local content = widget.content
			content.hotspot.is_selected = false
		end,
	},
}

local function create_rgb_slider_passes(label_text)
    local slider_width = 450
    return {
        {
            pass_type = "rect",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "left",
                color = { 180, 3, 3, 3 },
                offset = { 0, 0, 1 }
            }
        },
        {
            pass_type = "rect",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_background_gradient(180, true),
                size = { slider_width, 14 },
                offset = { 0, 0, 0 }
            }
        },
        {
            pass_type = "rect",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_text_header(0, true),
                size = { slider_width, 14 },
                offset = { 0, 0, 1 }
            },
            change_function = function(content, style)
                local hotspot = content.hotspot_bar
                if hotspot and hotspot.is_hover then
                    style.color[1] = 60
                else
                    style.color[1] = 0
                end
            end
        },
        {
            pass_type = "rect",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "left",
                size = { 0, 10 },
                color = Color.terminal_background_selected(255, true),
                offset = { 0, 0, 2 }
            },
            change_function = function(content, style)
                style.size[1] = (content.value or 0) * slider_width
            end
        },
        {
            pass_type = "hotspot",
            content_id = "hotspot_bar",
            content = {
                on_hover_sound = UISoundEvents.default_mouse_hover
            },
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                size = { slider_width, 30 },
                offset = { 0, 0, 0 }
            }
        },
        {
            pass_type = "logic",
            value = function(pass, renderer, style, content, position, size)
                local hotspot = content.hotspot_bar
                if not hotspot or not hotspot.is_hover then
                    return
                end


                local input_service = renderer.input_service
                if input_service then
                    local scroll_axis = input_service:get("scroll_axis")
                    if scroll_axis and scroll_axis ~= 0 then
                        local current_value = content.value or 0
                        local step = 0.02
                        content.value = math.clamp(current_value + (scroll_axis[2] * step), 0, 1)
                    end
                end
            end
        },
        {
            pass_type = "triangle",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "left",
                triangle_corners = {
                    { -6, 0 },
                    { 0, 6 },
                    { 0, -6 }
                },
                color = Color.white(180, true),
                offset = { 0, 0, 2 }
            },
            change_function = function(content, style)
                if content.hotspot_left.is_hover then
                    style.color = Color.white(255, true)
                else
                    style.color = Color.white(180, true)
                end
            end
        },
        {
            pass_type = "hotspot",
            content_id = "hotspot_left",
            content = {
                on_hover_sound = UISoundEvents.default_mouse_hover
            },
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "left",
                size = { 20, 30 },
                offset = { -5, 0, 0 }
            }
        },
        {
            pass_type = "logic",
            value = function(pass, renderer, style, content, position, size)
                local hotspot = content.hotspot_left
                if not hotspot then
                    return
                end

                local on_pressed = hotspot.on_pressed
                local is_held = hotspot.is_held


                if on_pressed then
                    Managers.ui:play_2d_sound(UISoundEvents.default_click)
                    local current_value = content.value or 0
                    content.value = math.clamp(current_value - 0.01, 0, 1)
                    hotspot._last_press_time = 0
                end


                if is_held then
                    local dt = renderer.dt
                    local last_press_time = hotspot._last_press_time or 0
                    last_press_time = last_press_time + dt
                    hotspot._last_press_time = last_press_time


                    if last_press_time > 0.5 then
                        local current_value = content.value or 0
                        local step = 0.01 * dt * 8
                        content.value = math.clamp(current_value - step, 0, 1)
                    end
                elseif hotspot.on_released then
                    hotspot._last_press_time = nil
                end
            end
        },
        {
            pass_type = "triangle",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "right",
                triangle_corners = {
                    { 6, 0 },
                    { 0, 6 },
                    { 0, -6 }
                },
                color = Color.white(255, true),
                offset = { 450, 0, 2 }
            },
            change_function = function(content, style)
                if content.hotspot_right.is_hover then
                    style.color = Color.white(255, true)
                else
                    style.color = Color.white(180, true)
                end
            end
        },
        {
            pass_type = "hotspot",
            content_id = "hotspot_right",
            content = {
                on_hover_sound = UISoundEvents.default_mouse_hover
            },
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "right",
                size = { 20, 30 },
                offset = { 5, 0, 0 }
            }
        },
        {
            pass_type = "logic",
            value = function(pass, renderer, style, content, position, size)
                local hotspot = content.hotspot_right
                if not hotspot then
                    return
                end

                local on_pressed = hotspot.on_pressed
                local is_held = hotspot.is_held


                if on_pressed then
                    Managers.ui:play_2d_sound(UISoundEvents.default_click)
                    local current_value = content.value or 0
                    content.value = math.clamp(current_value + 0.01, 0, 1)
                    hotspot._last_press_time = 0
                end


                if is_held then
                    local dt = renderer.dt
                    local last_press_time = hotspot._last_press_time or 0
                    last_press_time = last_press_time + dt
                    hotspot._last_press_time = last_press_time


                    if last_press_time > 0.5 then
                        local current_value = content.value or 0
                        local step = 0.01 * dt * 8
                        content.value = math.clamp(current_value + step, 0, 1)
                    end
                elseif hotspot.on_released then
                    hotspot._last_press_time = nil
                end
            end
        },
        {
            pass_type = "text",
            value_id = "label_text",
            value = label_text,
            style = {
                text_vertical_alignment = "center",
                text_horizontal_alignment = "left",
                font_type = "machine_medium",
                font_size = 16,
                text_color = UIHudSettings.color_tint_main_1,
                offset = { 0, -20, 2 }
            }
        }
    }
end


local widget_definitions = {
    background = UIWidget.create_definition({
        {
            pass_type = "rect",
            style = {
                color = Color.terminal_background(180, true),
                offset = { 0, 0, 0 }
            }
        }
    }, "background"),

    window = UIWidget.create_definition({
        {
            pass_type = "texture",
            value = "content/ui/materials/backgrounds/terminal_basic",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                scale_to_material = true,
                color = Color.terminal_grid_background(255, true),
                size_addition = { 20, 20 },
                offset = { 0, 0, 0 }
            }
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/frame_tile_2px",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_frame(255, true),
                offset = { 0, 0, 2 }
            }
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/frame_corner_2px",
            style = {
                vertical_alignment = "top",
                horizontal_alignment = "left",
                color = Color.terminal_corner(255, true),
                offset = { 0, 0, 3 }
            }
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/frame_corner_2px",
            style = {
                vertical_alignment = "top",
                horizontal_alignment = "right",
                color = Color.terminal_corner(255, true),
                offset = { 0, 0, 3 }
            }
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/frame_corner_2px",
            style = {
                vertical_alignment = "bottom",
                horizontal_alignment = "left",
                color = Color.terminal_corner(255, true),
                offset = { 0, 0, 3 }
            }
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/frame_corner_2px",
            style = {
                vertical_alignment = "bottom",
                horizontal_alignment = "right",
                color = Color.terminal_corner(255, true),
                offset = { 0, 0, 3 }
            }
        },
        {
            pass_type = "text",
            value = mod:localize("color_customizer_title"),
            style = {
                text_vertical_alignment = "top",
                text_horizontal_alignment = "center",
                font_type = "machine_medium",
                font_size = 24,
                text_color = Color.terminal_text_body(255, true),
                offset = { 0, 10, 4 }
            }
        }
    }, "window"),

    player_info_text = UIWidget.create_definition({
        {
            pass_type = "text",
            value_id = "text",
            value = "",
            style = {
                text_vertical_alignment = "center",
                text_horizontal_alignment = "center",
                font_type = "machine_medium",
                font_size = 16,
                text_color = Color.terminal_text_body(255, true),
                offset = { 0, 0, 1 }
            }
        }
    }, "player_info_text"),

    slot1_button = UIWidget.create_definition({
        {
            pass_type = "hotspot",
            content_id = "hotspot",
            content = {
                on_pressed_sound = UISoundEvents.default_click
            }
        },
        {
            pass_type = "rect",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_background(255, true),
                offset = { 0, 0, 0 }
            }
        },
        {
            pass_type = "rect",
            style_id = "color_swatch",
            style = {
                vertical_alignment = "top",
                horizontal_alignment = "left",
                color = { 255, 255, 255, 255 },
                size = { 100, 8 },
                offset = { 0, 0, 1 }
            }
        },
        {
            pass_type = "text",
            value = mod:localize("button_slot1"),
            style = {
                text_vertical_alignment = "center",
                text_horizontal_alignment = "center",
                font_type = "machine_medium",
                font_size = 16,
                text_color = Color.terminal_text_body(255, true),
                offset = { 0, 0, 2 }
            }
        }
    }, "slot1_button"),

    slot2_button = UIWidget.create_definition({
        {
            pass_type = "hotspot",
            content_id = "hotspot",
            content = {
                on_pressed_sound = UISoundEvents.default_click
            }
        },
        {
            pass_type = "rect",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_background(255, true),
                offset = { 0, 0, 0 }
            }
        },
        {
            pass_type = "rect",
            style_id = "color_swatch",
            style = {
                vertical_alignment = "top",
                horizontal_alignment = "left",
                color = { 255, 255, 255, 255 },
                size = { 100, 8 },
                offset = { 0, 0, 1 }
            }
        },
        {
            pass_type = "text",
            value = mod:localize("button_slot2"),
            style = {
                text_vertical_alignment = "center",
                text_horizontal_alignment = "center",
                font_type = "machine_medium",
                font_size = 16,
                text_color = Color.terminal_text_body(255, true),
                offset = { 0, 0, 2 }
            }
        }
    }, "slot2_button"),

    slot3_button = UIWidget.create_definition({
        {
            pass_type = "hotspot",
            content_id = "hotspot",
            content = {
                on_pressed_sound = UISoundEvents.default_click
            }
        },
        {
            pass_type = "rect",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_background(255, true),
                offset = { 0, 0, 0 }
            }
        },
        {
            pass_type = "rect",
            style_id = "color_swatch",
            style = {
                vertical_alignment = "top",
                horizontal_alignment = "left",
                color = { 255, 255, 255, 255 },
                size = { 100, 8 },
                offset = { 0, 0, 1 }
            }
        },
        {
            pass_type = "text",
            value = mod:localize("button_slot3"),
            style = {
                text_vertical_alignment = "center",
                text_horizontal_alignment = "center",
                font_type = "machine_medium",
                font_size = 16,
                text_color = Color.terminal_text_body(255, true),
                offset = { 0, 0, 2 }
            }
        }
    }, "slot3_button"),

    slot4_button = UIWidget.create_definition({
        {
            pass_type = "hotspot",
            content_id = "hotspot",
            content = {
                on_pressed_sound = UISoundEvents.default_click
            }
        },
        {
            pass_type = "rect",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_background(255, true),
                offset = { 0, 0, 0 }
            }
        },
        {
            pass_type = "rect",
            style_id = "color_swatch",
            style = {
                vertical_alignment = "top",
                horizontal_alignment = "left",
                color = { 255, 255, 255, 255 },
                size = { 100, 8 },
                offset = { 0, 0, 1 }
            }
        },
        {
            pass_type = "text",
            value = mod:localize("button_slot4"),
            style = {
                text_vertical_alignment = "center",
                text_horizontal_alignment = "center",
                font_type = "machine_medium",
                font_size = 16,
                text_color = Color.terminal_text_body(255, true),
                offset = { 0, 0, 2 }
            }
        }
    }, "slot4_button"),

    bot_button = UIWidget.create_definition({
        {
            pass_type = "hotspot",
            content_id = "hotspot",
            content = {
                on_pressed_sound = UISoundEvents.default_click
            }
        },
        {
            pass_type = "rect",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_background(255, true),
                offset = { 0, 0, 0 }
            }
        },
        {
            pass_type = "rect",
            style_id = "color_swatch",
            style = {
                vertical_alignment = "top",
                horizontal_alignment = "left",
                color = { 255, 255, 255, 255 },
                size = { 100, 8 },
                offset = { 0, 0, 1 }
            }
        },
        {
            pass_type = "text",
            value = mod:localize("button_bot"),
            style = {
                text_vertical_alignment = "center",
                text_horizontal_alignment = "center",
                font_type = "machine_medium",
                font_size = 16,
                text_color = Color.terminal_text_body(255, true),
                offset = { 0, 0, 2 }
            }
        }
    }, "bot_button"),

    veteran_button = UIWidget.create_definition({
        { pass_type = "hotspot", content_id = "hotspot", content = { on_pressed_sound = UISoundEvents.default_click } },
        { pass_type = "rect", style = { vertical_alignment = "center", horizontal_alignment = "center", color = Color.terminal_background(255, true), offset = { 0, 0, 0 } } },
        { pass_type = "rect", style_id = "color_swatch", style = { vertical_alignment = "top", horizontal_alignment = "left", color = { 255, 255, 255, 255 }, size = { 70, 8 }, offset = { 0, 0, 1 } } },
        { pass_type = "text", value = mod:localize("button_veteran"), style = { text_vertical_alignment = "center", text_horizontal_alignment = "center", font_type = "machine_medium", font_size = 14, text_color = Color.terminal_text_body(255, true), offset = { 0, 0, 2 } } }
    }, "veteran_button"),

    zealot_button = UIWidget.create_definition({
        { pass_type = "hotspot", content_id = "hotspot", content = { on_pressed_sound = UISoundEvents.default_click } },
        { pass_type = "rect", style = { vertical_alignment = "center", horizontal_alignment = "center", color = Color.terminal_background(255, true), offset = { 0, 0, 0 } } },
        { pass_type = "rect", style_id = "color_swatch", style = { vertical_alignment = "top", horizontal_alignment = "left", color = { 255, 255, 255, 255 }, size = { 70, 8 }, offset = { 0, 0, 1 } } },
        { pass_type = "text", value = mod:localize("button_zealot"), style = { text_vertical_alignment = "center", text_horizontal_alignment = "center", font_type = "machine_medium", font_size = 14, text_color = Color.terminal_text_body(255, true), offset = { 0, 0, 2 } } }
    }, "zealot_button"),

    psyker_button = UIWidget.create_definition({
        { pass_type = "hotspot", content_id = "hotspot", content = { on_pressed_sound = UISoundEvents.default_click } },
        { pass_type = "rect", style = { vertical_alignment = "center", horizontal_alignment = "center", color = Color.terminal_background(255, true), offset = { 0, 0, 0 } } },
        { pass_type = "rect", style_id = "color_swatch", style = { vertical_alignment = "top", horizontal_alignment = "left", color = { 255, 255, 255, 255 }, size = { 70, 8 }, offset = { 0, 0, 1 } } },
        { pass_type = "text", value = mod:localize("button_psyker"), style = { text_vertical_alignment = "center", text_horizontal_alignment = "center", font_type = "machine_medium", font_size = 14, text_color = Color.terminal_text_body(255, true), offset = { 0, 0, 2 } } }
    }, "psyker_button"),

    ogryn_button = UIWidget.create_definition({
        { pass_type = "hotspot", content_id = "hotspot", content = { on_pressed_sound = UISoundEvents.default_click } },
        { pass_type = "rect", style = { vertical_alignment = "center", horizontal_alignment = "center", color = Color.terminal_background(255, true), offset = { 0, 0, 0 } } },
        { pass_type = "rect", style_id = "color_swatch", style = { vertical_alignment = "top", horizontal_alignment = "left", color = { 255, 255, 255, 255 }, size = { 70, 8 }, offset = { 0, 0, 1 } } },
        { pass_type = "text", value = mod:localize("button_ogryn"), style = { text_vertical_alignment = "center", text_horizontal_alignment = "center", font_type = "machine_medium", font_size = 14, text_color = Color.terminal_text_body(255, true), offset = { 0, 0, 2 } } }
    }, "ogryn_button"),

    broker_button = UIWidget.create_definition({
        { pass_type = "hotspot", content_id = "hotspot", content = { on_pressed_sound = UISoundEvents.default_click } },
        { pass_type = "rect", style = { vertical_alignment = "center", horizontal_alignment = "center", color = Color.terminal_background(255, true), offset = { 0, 0, 0 } } },
        { pass_type = "rect", style_id = "color_swatch", style = { vertical_alignment = "top", horizontal_alignment = "left", color = { 255, 255, 255, 255 }, size = { 70, 8 }, offset = { 0, 0, 1 } } },
        { pass_type = "text", value = mod:localize("button_broker"), style = { text_vertical_alignment = "center", text_horizontal_alignment = "center", font_type = "machine_medium", font_size = 14, text_color = Color.terminal_text_body(255, true), offset = { 0, 0, 2 } } }
    }, "broker_button"),

    adamant_button = UIWidget.create_definition({
        { pass_type = "hotspot", content_id = "hotspot", content = { on_pressed_sound = UISoundEvents.default_click } },
        { pass_type = "rect", style = { vertical_alignment = "center", horizontal_alignment = "center", color = Color.terminal_background(255, true), offset = { 0, 0, 0 } } },
        { pass_type = "rect", style_id = "color_swatch", style = { vertical_alignment = "top", horizontal_alignment = "left", color = { 255, 255, 255, 255 }, size = { 70, 8 }, offset = { 0, 0, 1 } } },
        { pass_type = "text", value = mod:localize("button_adamant"), style = { text_vertical_alignment = "center", text_horizontal_alignment = "center", font_type = "machine_medium", font_size = 14, text_color = Color.terminal_text_body(255, true), offset = { 0, 0, 2 } } }
    }, "adamant_button"),

    cryptic_button = UIWidget.create_definition({
        { pass_type = "hotspot", content_id = "hotspot", content = { on_pressed_sound = UISoundEvents.default_click } },
        { pass_type = "rect", style = { vertical_alignment = "center", horizontal_alignment = "center", color = Color.terminal_background(255, true), offset = { 0, 0, 0 } } },
        { pass_type = "rect", style_id = "color_swatch", style = { vertical_alignment = "top", horizontal_alignment = "left", color = { 255, 255, 255, 255 }, size = { 70, 8 }, offset = { 0, 0, 1 } } },
        { pass_type = "text", value = mod:localize("button_cryptic"), style = { text_vertical_alignment = "center", text_horizontal_alignment = "center", font_type = "machine_medium", font_size = 14, text_color = Color.terminal_text_body(255, true), offset = { 0, 0, 2 } } }
    }, "cryptic_button"),

    account_id_input = UIWidget.create_definition(
        TextInputPassTemplates.terminal_input_field,
        "account_id_input",
        {
            input_text = "",
            placeholder_text = mod:localize("account_id_placeholder"),
            max_length = 36
        }
    ),

    color_preview = UIWidget.create_definition({
        {
            pass_type = "rect",
            style_id = "color_rect",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = { 255, 255, 255, 255 },
                size = { 150, 150 },
                offset = { 0, 0, 2 }
            }
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/frame_tile_2px",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_frame(255, true),
                offset = { 0, 0, 1 }
            }
        }
    }, "color_preview"),

    red_slider = UIWidget.create_definition(
        create_rgb_slider_passes(mod:localize("label_red")),
        "red_slider",
        { value = 1.0 }
    ),

    green_slider = UIWidget.create_definition(
        create_rgb_slider_passes(mod:localize("label_green")),
        "green_slider",
        { value = 1.0 }
    ),

    blue_slider = UIWidget.create_definition(
        create_rgb_slider_passes(mod:localize("label_blue")),
        "blue_slider",
        { value = 1.0 }
    ),

    red_input = UIWidget.create_definition(
        TextInputPassTemplates.terminal_input_field,
        "red_input",
        {
            input_text = "255",
            placeholder_text = "0-255",
            max_length = 3
        }
    ),

    green_input = UIWidget.create_definition(
        TextInputPassTemplates.terminal_input_field,
        "green_input",
        {
            input_text = "255",
            placeholder_text = "0-255",
            max_length = 3
        }
    ),

    blue_input = UIWidget.create_definition(
        TextInputPassTemplates.terminal_input_field,
        "blue_input",
        {
            input_text = "255",
            placeholder_text = "0-255",
            max_length = 3
        }
    ),

    hex_input = UIWidget.create_definition(
        TextInputPassTemplates.terminal_input_field,
        "hex_input",
        {
            input_text = "FFFFFF",
            placeholder_text = "FFFFFF",
            max_length = 7
        }
    ),

    apply_button = UIWidget.create_definition(
        ButtonPassTemplates.terminal_button_small,
        "apply_button",
        {
            text = mod:localize("button_apply"),
            hotspot = {
                on_pressed_sound = UISoundEvents.default_click
            }
        }
    ),

    save_button = UIWidget.create_definition(
        ButtonPassTemplates.terminal_button_small,
        "save_button",
        {
            text = mod:localize("button_save"),
            hotspot = {
                on_pressed_sound = UISoundEvents.default_click
            }
        }
    ),

    reset_button = UIWidget.create_definition(
        ButtonPassTemplates.terminal_button_small,
        "reset_button",
        {
            text = mod:localize("button_reset"),
            hotspot = {
                on_pressed_sound = UISoundEvents.default_click
            }
        }
    ),

    reset_all_button = UIWidget.create_definition(
        ButtonPassTemplates.terminal_button_small,
        "reset_all_button",
        {
            text = mod:localize("button_reset_all"),
            hotspot = {
                on_pressed_sound = UISoundEvents.default_click
            }
        }
    ),

    reset_all_slots_button = UIWidget.create_definition(
        ButtonPassTemplates.terminal_button_small,
        "reset_all_slots_button",
        {
            text = mod:localize("button_reset_all_slots"),
            hotspot = {
                on_pressed_sound = UISoundEvents.default_click
            }
        }
    ),

    close_button = UIWidget.create_definition(
        ButtonPassTemplates.terminal_button_small,
        "close_button",
        {
            text = mod:localize("button_close"),
            hotspot = {
                on_pressed_sound = UISoundEvents.default_click
            }
        }
    )
}


local legend_inputs = {
    {
        input_action = "back",
        on_pressed_callback = "_on_back_pressed",
        display_name = "loc_class_selection_button_back",
        alignment = "left_alignment"
    }
}

return {
    scenegraph_definition = scenegraph_definition,
    widget_definitions = widget_definitions,
    blueprints = blueprints,
    preset_grid_settings = preset_grid_settings,
    players_grid_settings = players_grid_settings,
    legend_inputs = legend_inputs,
}
