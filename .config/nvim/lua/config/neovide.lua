local global = vim.g
local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
if normal_bg then
	global.neovide_title_background_color = string.format("#%06x", normal_bg)
else
	global.neovide_title_background_color = "#0f1117"
end
vim.o.guifont = "Maple Mono NF:h13"
global.neovide_opacity = 0.5
global.neovide_window_blurred = true
global.neovide_floating_blur_amount_x = 2.0
global.neovide_floating_blur_amount_y = 2.0
global.neovide_normal_opacity = 0.5
global.neovide_title_text_color = "pink"
global.neovide_theme = "auto"
global.neovide_refresh_rate = 0
global.neovide_no_idle = true
global.neovide_remember_window_size = true
global.neovide_confirm_quit = true
global.neovide_input_use_logo = true
global.neovide_cursor_vfx_mode = "railgun"
global.neovide_cursor_animation_length = 0.08
global.neovide_cursor_trail_size = 0.5
global.neovide_scroll_animation_length = 0.05
