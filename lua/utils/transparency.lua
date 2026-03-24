local M = {}

local defaults = {
  enabled = true,
  colorscheme = "rose-pine",
}

local core_groups = {
  "Normal",
  "NormalNC",
  "SignColumn",
  "EndOfBuffer",
  "NormalFloat",
  "FloatBorder",
  "FloatTitle",
  "FloatFooter",
  "FloatShadow",
  "FloatShadowThrough",
  "StatusLine",
  "StatusLineNC",
  "StatusLineTerm",
  "StatusLineTermNC",
  "WinSeparator",
  "VertSplit",
  "LineNr",
  "CursorLineNr",
  "CursorLine",
  "CursorColumn",
  "FoldColumn",
  "Pmenu",
  "PmenuSel",
  "PmenuSbar",
  "PmenuThumb",
  "TabLine",
  "TabLineFill",
  "TabLineSel",
  "WinBar",
  "WinBarNC",
  "MsgArea",
  "MsgSeparator",
  "NvimTreeNormal",
  "NvimTreeNormalNC",
  "NotifyBackground",
  "IlluminatedWordText",
  "IlluminatedWordRead",
  "IlluminatedWordWrite",
  "LspReferenceText",
  "LspReferenceRead",
  "LspReferenceWrite",
  "TelescopeNormal",
  "TelescopeBorder",
  "TelescopePromptNormal",
  "TelescopePromptBorder",
  "TelescopePromptTitle",
  "TelescopeResultsTitle",
  "TelescopePreviewTitle",
  "TelescopeSelection",
}

local prefix_groups = {
  "Notify",
  "Telescope",
}

local function clear_bg(group)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if not ok then
    return
  end

  hl.bg = "none"
  hl.ctermbg = "none"
  pcall(vim.api.nvim_set_hl, 0, group, hl)
end

local function clear_matching(prefix)
  local groups = vim.fn.getcompletion(prefix, "highlight")
  for _, group in ipairs(groups) do
    clear_bg(group)
  end
end

function M.apply()
  if not vim.g.transparent_enabled then
    return
  end

  for _, group in ipairs(core_groups) do
    clear_bg(group)
  end

  for _, prefix in ipairs(prefix_groups) do
    clear_matching(prefix)
  end
end

local function refresh_ui()
  local scheme = vim.g.colors_name or M.colorscheme or defaults.colorscheme
  pcall(vim.cmd.colorscheme, scheme)

  if vim.g.transparent_enabled then
    M.apply()
  end

  pcall(vim.api.nvim_exec_autocmds, "User", { pattern = "TransparencyToggle" })
end

function M.enable()
  vim.g.transparent_enabled = true
  refresh_ui()
end

function M.disable()
  vim.g.transparent_enabled = false
  refresh_ui()
end

function M.toggle()
  vim.g.transparent_enabled = not vim.g.transparent_enabled
  refresh_ui()
  vim.notify("Transparency " .. (vim.g.transparent_enabled and "ON" or "OFF"), vim.log.levels.INFO)
end

function M.setup(opts)
  opts = vim.tbl_extend("force", defaults, opts or {})
  M.colorscheme = opts.colorscheme

  if vim.g.transparent_enabled == nil then
    vim.g.transparent_enabled = opts.enabled
  end

  local group = vim.api.nvim_create_augroup("TransparencyOverrides", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = M.apply,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = M.apply,
  })

  vim.api.nvim_create_user_command("TransparencyEnable", M.enable, {})
  vim.api.nvim_create_user_command("TransparencyDisable", M.disable, {})
  vim.api.nvim_create_user_command("TransparencyToggle", M.toggle, {})
end

return M
