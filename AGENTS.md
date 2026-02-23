# AGENTS.md

This file contains guidelines for agentic coding agents working in this Neovim configuration repository.

## Repository Overview

This is a personal Neovim configuration using Lua, organized with lazy.nvim as the plugin manager. The configuration follows a modular structure with separate directories for configuration files, plugins, LSP servers, and utilities.

## Build/Test/Lint Commands

This is a Neovim configuration - there are no traditional build/test commands. To validate changes:

```bash
# Check Neovim configuration syntax
nvim --headless -c "lua require('config.lazy')" -c "q"

# Run health checks for plugins
nvim --headless -c "checkhealth" -c "q"

# Test LSP configuration
nvim --headless -c "LspInfo" -c "q"

# Update plugins
nvim --headless -c "Lazy sync" -c "q"

# Clean plugins
nvim --headless -c "Lazy clean" -c "q"
```

## Code Style Guidelines

### File Structure
- `init.lua` - Entry point that bootstraps lazy.nvim
- `lua/config/` - Core Neovim configuration (options, keymaps, autocmds)
- `lua/plugins/` - Plugin specifications for lazy.nvim
- `lua/servers/` - LSP server configurations
- `lua/utils/` - Utility functions (LSP helpers, diagnostics)

### Lua Conventions
- Use 2 spaces for indentation (configured in options.lua:17-20)
- Use `local` for all variable declarations
- Module pattern: `local M = {}` at top, `return M` at bottom
- Prefer `vim.keymap.set` over deprecated `vim.api.nvim_set_keymap`
- Use vim.tbl_contains() for table membership checks
- Error handling with `pcall()` for potentially failing operations

### Import/Require Pattern
```lua
-- Standard format
local module_name = require("path.to.module")
local utils = require("utils.lsp")

-- For plugin specs, use return {} pattern
return {
  "plugin/repo",
  dependencies = { ... },
  config = function() ... end
}
```

### Naming Conventions
- Files: snake_case (e.g., `keymaps.lua`, `autocmds.lua`)
- Variables: snake_case for local variables
- Functions: snake_case for local functions
- Modules: PascalCase for plugin names, snake_case for local modules
- Keymaps: Use descriptive names with `<leader>` prefix for custom mappings

### LSP Configuration
- Server configs go in `lua/servers/` with descriptive names (e.g., `lua_ls.lua`, `pyright.lua`)
- Use the `on_attach` function from `utils/lsp.lua` for consistent keymap setup
- LSP capabilities should be configured per-server basis
- Use `efm-langserver` for formatting with formatters configured externally

### Plugin Configuration
- All plugins managed through lazy.nvim in `lua/plugins/`
- Use plugin dependencies array for required dependencies
- Plugin configurations should be in the `config` function
- Disable netrw in lazy.nvim setup (already configured)
- Use optional dependencies with lazy loading where appropriate

### Keymap Guidelines
- Use `<leader>` prefix for custom keymaps
- Include `desc` field for all keymaps for which-key integration
- Separate VSCode and Neovim keymaps using `if vim.g.vscode then`
- Center screen when jumping/searching (use `zzzv` pattern)
- Use consistent keymap patterns across similar operations
- Keep plugin-specific keymaps in the plugin file under `lua/plugins/` (inside plugin `config`/`keys`), not in `lua/config/keymaps.lua`
- Keep only core/editor keymaps (that work without optional plugins) in `lua/config/keymaps.lua`

### Autocmd Structure
- Create augroup with descriptive name using `vim.api.nvim_create_augroup()`
- Use clear pattern: `local group_name = vim.api.nvim_create_augroup("GroupName", {})`
- Autocmds should be in `lua/config/autocmds.lua` unless plugin-specific
- Use `callback = function() ... end` pattern for autocmd handlers

### Error Handling
- Use `pcall()` for operations that might fail (file operations, LSP calls)
- Check client existence in LSP functions: `if not client then return end`
- Use `vim.defer_fn()` for delayed operations (formatting after imports)

### Documentation Style
- Use header comments with TITLE, ABOUT, LINKS sections
- Keep comments concise and explanatory
- Document keymap purposes in desc fields
- Use consistent comment style across files

### Performance Considerations
- Use lazy loading for heavy plugins
- Set up autocmds with specific patterns rather than "*" when possible
- Use buffer-local keymaps and options where appropriate
- Defer expensive operations with `vim.defer_fn()` when needed

### Testing Changes
1. Restart Neovim to test configuration changes
2. Use `:checkhealth` to verify plugin health
3. Test keymaps in both normal and visual modes
4. Verify LSP functionality with `:LspInfo`
5. Check for errors with `:messages`

## Common Patterns

### Adding a New Plugin
```lua
-- lua/plugins/new_plugin.lua
return {
  "author/plugin-name",
  dependencies = { "required/dependency" },
  config = function()
    -- Plugin configuration
  end,
}
```

### Adding LSP Server
```lua
-- lua/servers/new_server.lua
return {
  settings = {
    -- Server-specific settings
  },
  on_attach = require("utils.lsp").on_attach,
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
}
```

This configuration prioritizes performance, maintainability, and consistency across all components.
