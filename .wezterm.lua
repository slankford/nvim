local wezterm = require("wezterm")

local config = wezterm.config_builder()
local act = wezterm.action

local is_windows = wezterm.target_triple:find("windows") ~= nil

config.front_end = "OpenGL" -- Or "WebGPU". Attempt graphic issue fix on mac

config.font = wezterm.font_with_fallback({ "Mononoki Nerd Font Mono", "mononoki", "JetBrainsMono Nerd Font" })
config.color_scheme = "Rosé Pine Moon (Gogh)"
config.font_size = 19

config.window_decorations = "RESIZE"

-- Windows OS config:
-- config.default_domain = "WSL:Ubuntu"
-- config.default_prog = { 'powershell.exe', '-NoLogo' }

if not is_windows then
	-- Define the background layers
	config.background = {
		-- Layer 1: The background image
		{
			source = { File = "/Users/silas/code/backgrounds/rose-pine-dawn.png" },
			horizontal_align = "Center", -- Align the image (Left, Center, Right)
			vertical_align = "Middle", -- Align the image (Top, Middle, Bottom)
			-- Optional: adjust HSB and opacity
			-- hsb = { brightness = 0.5, saturation = 1.0, hue = 1.0 },
		},
		-- Layer 2: A semi-transparent color overlay for better text visibility (optional)
		{
			source = { Color = "#171624" }, -- Rose pine moon dark overlay
			-- rose pine moon bg color: 232136
			height = "100%",
			width = "100%",
			opacity = 0.95, -- Adjust opacity as needed
		},
	}
else
	-- Windows specific settings
	--
end

local function basename(path)
	return path and path:match("([^/\\]+)$") or ""
end

local function is_vim(pane)
	local proc = basename(pane:get_foreground_process_name()):lower()
	local is_local_nvim = proc == "nvim"
	local is_ssh = proc == "ssh"
	local is_remote_nvim = pane:get_user_vars().IS_NVIM == "true"
	return is_local_nvim or (is_ssh and is_remote_nvim)
	-- return pane:get_user_vars().IS_NVIM == "true"
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

---- CUSTOM PANE ROTATION LOGIC
local function get_lr_pair(tab)
	local infos = tab:panes_with_info()
	if #infos ~= 2 then
		return nil
	end
	local a, b = infos[1], infos[2]
	-- Must be side-by-side (same row, different columns)
	if a.top ~= b.top or a.left == b.left then
		return nil
	end
	local left, right = a, b
	if a.left > b.left then
		left, right = b, a
	end
	return left, right
end
local function smart_rotate_lr(direction)
	return wezterm.action_callback(function(window, pane)
		local tab = window:active_tab()
		local left_before, right_before = get_lr_pair(tab)
		-- Fallback to normal rotate for non-2-pane or non-left/right layouts
		if not left_before then
			window:perform_action(act.RotatePanes(direction), pane)
			return
		end
		-- Remember desired width by pane identity (content-based sizing)
		local desired_width = {
			[left_before.pane:pane_id()] = left_before.width,
			[right_before.pane:pane_id()] = right_before.width,
		}
		window:perform_action(act.RotatePanes(direction), pane)
		-- Give layout a tiny moment to settle before measuring again
		wezterm.sleep_ms(10)
		local left_after, _ = get_lr_pair(tab)
		if not left_after then
			return
		end
		local target_left_width = desired_width[left_after.pane:pane_id()]
		if not target_left_width then
			return
		end
		local diff = target_left_width - left_after.width
		if diff == 0 then
			return
		end
		left_after.pane:activate()
		window:perform_action(act.AdjustPaneSize({ diff > 0 and "Right" or "Left", math.abs(diff) }), left_after.pane)
	end)
end
---- END CUSTOM PANE ROTATION LOGIC

local split_mods = is_windows and "CTRL|ALT" or "CTRL|CMD"
local pane_resizes_mods = is_windows and "CTRL" or "SHIFT"

config.keys = {

	-- Pain navigation
	{ key = "h", mods = split_mods, action = smart_nav("h", "Left") },
	{ key = "j", mods = split_mods, action = smart_nav("j", "Down") },
	{ key = "k", mods = split_mods, action = smart_nav("k", "Up") },
	{ key = "l", mods = split_mods, action = smart_nav("l", "Right") },

	-- Pane splits (avoid Ctrl+Shift+V paste conflict on Windows)
	{ key = "v", mods = split_mods, action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "s", mods = split_mods, action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- rotate pains
	{ key = "LeftArrow", mods = split_mods, action = smart_rotate_lr("CounterClockwise") },
	{ key = "RightArrow", mods = split_mods, action = smart_rotate_lr("Clockwise") },

	-- Pain resizes
	{ key = "LeftArrow", mods = pane_resizes_mods, action = split_resize_or_send("Left", 3) },
	{ key = "RightArrow", mods = pane_resizes_mods, action = split_resize_or_send("Right", 3) },
	{ key = "UpArrow", mods = pane_resizes_mods, action = split_resize_or_send("Up", 2) },
	{ key = "DownArrow", mods = pane_resizes_mods, action = split_resize_or_send("Down", 2) },

	-- Better tab nav
	{ key = "l", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "h", mods = "CTRL", action = act.ActivateTabRelative(-1) },
	-- Better window nav
	{ key = "]", mods = split_mods, action = act.ActivateWindowRelative(1) },
	{ key = "[", mods = split_mods, action = act.ActivateWindowRelative(-1) },

	-- Zoom in on current pane, toggle
	{ key = "z", mods = split_mods, action = act.TogglePaneZoomState },

	-- Move current pane to new tab
	{
		key = "m",
		mods = split_mods,
		action = wezterm.action_callback(function(_window, pane)
			pane:move_to_new_tab()
		end),
	},
	-- Move current pane to new window
	{
		key = "Enter",
		mods = split_mods,
		action = wezterm.action_callback(function(_window, pane)
			pane:move_to_new_window()
		end),
	},

	-- Close the current pane (if it's the last pane, it closes the tab)
	{ key = "w", mods = split_mods, action = act.CloseCurrentPane({ confirm = false }) },

	-- Rename tab
	{
		key = "r",
		mods = split_mods,
		action = act.PromptInputLine({
			description = "Rename tab",
			action = wezterm.action_callback(function(window, _pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		key = "e",
		mods = split_mods,
		action = wezterm.action_callback(function(window, _pane)
			window:active_tab():set_title("")
		end),
	},

	-- Overwrite ctrl+u/d for scrolling
	{ key = "d", mods = "CTRL", action = maybe_scroll("d", 0.5) },
	{ key = "u", mods = "CTRL", action = maybe_scroll("u", -0.5) },
}

return config
