local wezterm = require 'wezterm'

local module = {}

function module.apply_to_config(config)
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
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
  config.show_new_tab_button_in_tab_bar = false

  local function tab_text(tab, max_width)
    local index = tab.tab_index + 1
    local title = tab.active_pane.title
    if tab.tab_title and #tab.tab_title > 0 then
      title = tab.tab_title
    end

    local str = tab.is_active and string.format(" %s ", title) or string.format(" %d-%s ", index, title)
    return wezterm.truncate_right(str, max_width)
  end

  wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
    return { { Text = tab_text(tab, max_width) } }
  end)

  wezterm.on('update-status', function(window, pane)
    local date = wezterm.strftime '%Y.%m.%d %H:%M '
    local conf = window:effective_config()
    local tabs = window:mux_window():tabs_with_info()
    local tabs_width = 0
    for _, item in ipairs(tabs) do
      tabs_width = tabs_width + wezterm.column_width(tab_text({
        tab_index = item.index,
        is_active = item.is_active,
        tab_title = item.tab:get_title(),
        active_pane = { title = item.tab:active_pane():get_title() },
      }, conf.tab_max_width))
    end
    -- Center the tabs in the window, leaving room for the clock on the right.
    -- Use the full tab width so splitting panes does not change the alignment.
    local columns = window:active_tab():get_size().cols
    local centered_start = math.floor((columns - tabs_width) / 2)
    local latest_start = columns - wezterm.column_width(date) - tabs_width
    local padding = string.rep(' ', math.max(0, math.min(centered_start, latest_start)))
    window:set_right_status(wezterm.format {
      { Foreground = { Color = 'yellow' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = date },
    })

    window:set_left_status(padding)
  end)
end

return module
