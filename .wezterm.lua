local wezterm = require("wezterm")

local config = wezterm.config_builder()
local act = wezterm.action

config.front_end = "OpenGL" -- Or "WebGPU". Attempt graphic issue fix on mac

config.font = wezterm.font("Mononoki Nerd Font Mono")
config.color_scheme = "Rosé Pine Moon (Gogh)"
config.font_size = 19

config.window_decorations = "RESIZE"

-- Windows OS config:
-- config.default_domain = "WSL:Ubuntu"

-- Define the background layers
config.background = {
	-- Layer 1: The background image
	{
		source = { File = "/Users/silas/code/backgrounds/tengoku-overtop.png" },
		horizontal_align = "Center", -- Align the image (Left, Center, Right)
		vertical_align = "Middle", -- Align the image (Top, Middle, Bottom)
		-- Optional: adjust HSB and opacity
		-- hsb = { brightness = 0.5, saturation = 1.0, hue = 1.0 },
	},
	-- Layer 2: A semi-transparent color overlay for better text visibility (optional)
	{
		source = { Color = "#000000" }, -- Black overlay
		height = "100%",
		width = "100%",
		opacity = 0.6, -- Adjust opacity as needed
	},
}

local function is_vim(pane)
	return pane:get_user_vars().IS_NVIM == "true"
end

local function smart_nav(key, direction)
	return wezterm.action_callback(function(window, pane)
		if is_vim(pane) then
			window:perform_action(act.SendKey({ key = key, mods = "CTRL" }), pane)
		else
			window:perform_action(act.ActivatePaneDirection(direction), pane)
		end
	end)
end

local function split_resize_or_send(direction, delta)
	return wezterm.action_callback(function(window, pane)
		if is_vim(pane) then
			-- Let Neovim receive Shift+Arrow
			local key_for_dir = {
				Left = "LeftArrow",
				Right = "RightArrow",
				Up = "UpArrow",
				Down = "DownArrow",
			}
			window:perform_action(act.SendKey({ key = key_for_dir[direction], mods = "SHIFT" }), pane)
		else
			-- WezTerm pane resize everywhere else
			window:perform_action(act.AdjustPaneSize({ direction, delta }), pane)
		end
	end)
end

local function in_opencode(pane)
	local p = (pane:get_foreground_process_name() or ""):lower()
	return p:find("opencode", 1, true) ~= nil
end

local function maybe_scroll(key, pages)
	return wezterm.action_callback(function(window, pane)
		window:perform_action(
			in_opencode(pane) and act.ScrollByPage(pages) or act.SendKey({ key = key, mods = "CTRL" }),
			pane
		)
	end)
end

local is_windows = wezterm.target_triple:find("windows") ~= nil
local split_mods = is_windows and "CTRL|ALT" or "CTRL|SHIFT"

config.keys = {

	-- Pain navigation
	{ key = "h", mods = "CTRL", action = smart_nav("h", "Left") },
	{ key = "j", mods = "CTRL", action = smart_nav("j", "Down") },
	{ key = "k", mods = "CTRL", action = smart_nav("k", "Up") },
	{ key = "l", mods = "CTRL", action = smart_nav("l", "Right") },

	-- Pane splits (avoid Ctrl+Shift+V paste conflict on Windows)
	{ key = "v", mods = split_mods, action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "s", mods = split_mods, action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- rotate pains
	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = act.RotatePanes("CounterClockwise") },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = act.RotatePanes("Clockwise") },

	-- Pain resizes
	{ key = "LeftArrow", mods = "SHIFT", action = split_resize_or_send("Left", 3) },
	{ key = "RightArrow", mods = "SHIFT", action = split_resize_or_send("Right", 3) },
	{ key = "UpArrow", mods = "SHIFT", action = split_resize_or_send("Up", 2) },
	{ key = "DownArrow", mods = "SHIFT", action = split_resize_or_send("Down", 2) },

	-- Better tab nav
	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	-- Better window nav
	{ key = "]", mods = "CTRL|SHIFT", action = act.ActivateWindowRelative(1) },
	{ key = "[", mods = "CTRL|SHIFT", action = act.ActivateWindowRelative(-1) },

	-- Zoom in on current pane, toggle
	{ key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },

	-- Move current pane to new tab
	{
		key = "m",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(_window, pane)
			pane:move_to_new_tab()
		end),
	},
	-- Move current pane to new window
	{
		key = "Enter",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(_window, pane)
			pane:move_to_new_window()
		end),
	},

	-- Rename tab
	{
		key = "R",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Rename tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		key = "E",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			window:active_tab():set_title("")
		end),
	},

	-- Overwrite ctrl+u/d for scrolling
	{ key = "d", mods = "CTRL", action = maybe_scroll("d", 0.5) },
	{ key = "u", mods = "CTRL", action = maybe_scroll("u", -0.5) },
}
return config
