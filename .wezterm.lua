local wezterm = require("wezterm")

local config = wezterm.config_builder()
local act = wezterm.action

config.font = wezterm.font("Mononoki Nerd Font Mono")
config.color_scheme = "Rosé Pine Moon (Gogh)"
config.font_size = 19

config.window_decorations = "RESIZE"

-- config.colors = {

-- }

-- config.window_background_opacity = 0.9
-- config.macos_window_background_blur = 10
--
--

-- 🔥 Smart pane navigation helpers
local function is_vim(pane)
	local process_name = pane:get_foreground_process_name() or ""
	process_name = process_name:lower()
	return process_name:find("nvim") or process_name:find("vim")
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

config.keys = {

	-- Pain navigation
	{ key = "h", mods = "CTRL", action = smart_nav("h", "Left") },
	{ key = "j", mods = "CTRL", action = smart_nav("j", "Down") },
	{ key = "k", mods = "CTRL", action = smart_nav("k", "Up") },
	{ key = "l", mods = "CTRL", action = smart_nav("l", "Right") },

	-- Pain splits
	{ key = "v", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "s", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Pain resizes
	{ key = "LeftArrow", mods = "SHIFT", action = split_resize_or_send("Left", 3) },
	{ key = "RightArrow", mods = "SHIFT", action = split_resize_or_send("Right", 3) },
	{ key = "UpArrow", mods = "SHIFT", action = split_resize_or_send("Up", 2) },
	{ key = "DownArrow", mods = "SHIFT", action = split_resize_or_send("Down", 2) },

	-- Better tab nav
	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

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
}
return config
