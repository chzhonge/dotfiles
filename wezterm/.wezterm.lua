-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- ==== OS Detection ====
local is_windows = wezterm.target_triple:find("windows") ~= nil

-- ==== Common Settings ====
config.debug_key_events = true
config.scrollback_lines = 9000
config.keys = {}

if is_windows then
  -- ==== Windows: Use Wezterm Native Tabs/Panes (Mimicking Tmux) ====
  config.default_prog = { 'powershell.exe', '-NoLogo' }
  
  -- Load the tmux-like configuration from windows.lua
  local windows = require 'windows'
  windows.apply_to_config(config)
else
  -- ==== MacOS/Others: Use Real Tmux ====
  -- Disable Wezterm tab bar to let tmux handle the status line and tabs.
  config.enable_tab_bar = false
  config.window_decorations = "TITLE | RESIZE"

  -- Keybindings for Mac
  config.keys = {
    -- Disable default CMD-m (Hide) to avoid accidental triggers
    {
      key = 'm',
      mods = 'CMD',
      action = wezterm.action.DisableDefaultAssignment,
    },
  }
end

return config
