local wezterm = require 'wezterm'

local module = {}

function module.apply_to_config(config)
  config.leader = { key = '`', mods = 'NONE', timeout_milliseconds = 1000 }

  config.colors = {
    tab_bar = {
      background = 'black',
      active_tab = {
        bg_color = 'black',
        fg_color = 'red',
      },
      inactive_tab = {
        bg_color = 'black',
        fg_color = 'white',
      },
      new_tab = {
        bg_color = 'black',
        fg_color = 'white',
      },
    }
  }

  local windows_keys = {
    -- ==== Window/Tab Management ====
    { key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = '`', mods = 'LEADER', action = wezterm.action.ActivateLastTab },
    { key = 'Backspace', mods = 'LEADER', action = wezterm.action.ActivateLastTab },
    { key = 'H', mods = 'LEADER|SHIFT', action = wezterm.action.MoveTabRelative(-1) },
    { key = 'L', mods = 'LEADER|SHIFT', action = wezterm.action.MoveTabRelative(1) },
    { key = 'A', mods = 'LEADER|SHIFT', action = wezterm.action.PromptInputLine {
        description = 'Enter new name for tab',
        action = wezterm.action_callback(function(window, pane, line)
          if line then window:active_tab():set_title(line) end
        end),
    }},
    { key = '/', mods = 'LEADER', action = wezterm.action.PromptInputLine {
        description = 'Enter new name for tab',
        action = wezterm.action_callback(function(window, pane, line)
          if line then window:active_tab():set_title(line) end
        end),
    }},

    -- ==== Pane (Split) Management ====
    { key = 'S', mods = 'LEADER|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = '|', mods = 'LEADER|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },

    -- ==== Pane Resizing ====
    { key = ',', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { 'Left', 1 } },
    { key = '.', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { 'Right', 1 } },
    { key = '-', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { 'Down', 1 } },
    { key = '=', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { 'Up', 1 } },

    -- ==== Pane/Tab Closing ====
    { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = true } },
    { key = '&', mods = 'LEADER|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = true } },

    -- ==== Session (Window) ====
    { key = 'n', mods = 'LEADER|CTRL', action = wezterm.action.SpawnWindow },
  }

  for _, win_key in ipairs(windows_keys) do
    table.insert(config.keys, win_key)
  end

  -- ==== Numbered Tab Switching (1-9) ====
  for i = 1, 9 do
    table.insert(config.keys, {
      key = tostring(i),
      mods = 'LEADER',
      action = wezterm.action.ActivateTab(i - 1),
    })
  end

  -- ==== Tmux-like Tab Bar ====
  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = true
  config.show_tab_index_in_tab_bar = false

  wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
    local index = tab.tab_index + 1
    local title = tab.active_pane.title
    if tab.tab_title and #tab.tab_title > 0 then
      title = tab.tab_title
    end

    local str = tab.is_active and string.format(" %s ", title) or string.format(" %d-%s ", index, title)
    return { { Text = str } }
  end)

  wezterm.on('update-status', function(window, pane)
    local date = wezterm.strftime '%Y.%m.%d %H:%M '
    window:set_right_status(wezterm.format {
      { Foreground = { Color = 'yellow' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = date },
    })

    window:set_left_status(wezterm.format {
      { Foreground = { Color = 'magenta' } },
      { Text = ' Deric ' },
      { DefaultForeground = { } },
      { Foreground = { Color = 'red' } },
      { Text = '| ' },
      { Foreground = { Color = 'cyan' } },
      { Text = '上班這件事 ' },
    })
  end)
end

return module
