local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- カラースキーム (Neovimに合わせてTokyo Nightに)
config.color_scheme = 'Tokyo Night'

-- フォント設定 (お使いのNerd Fontに合わせて変更してください)
config.font = wezterm.font_with_fallback {
  { family = 'JetBrainsMono Nerd Font', weight = 'Bold' },
  { family = 'Hiragino Sans' }, -- 日本語の文字化け防止用フォールバック
}
config.font_size = 14.0

-- ウィンドウの見た目 (透け感とブラー)
config.window_background_opacity = 0.75
config.macos_window_background_blur = 5

-- ウィンドウの余白を追加してスタイリッシュに
config.window_padding = {
  left = '1cell',
  right = '1cell',
  top = '0.5cell',
  bottom = '0.5cell',
}

-- タイトルバーを非表示にしてスッキリさせる (Mac用)
config.window_decorations = "RESIZE"

-- 非アクティブなペインを少し暗くする (画面分割時におしゃれ)
config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.7,
}

-- カーソルの見た目を点滅するブロックに
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 500

-- タブバーの設定 (下に配置して控えめに)
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

-- キーバインドの設定
config.keys = {}
local is_mac = wezterm.target_triple:find('darwin') ~= nil

if is_mac then
  -- ============================================================
  -- OS側のCmd/Ctrl入れ替えを打ち消す設定
  -- 物理Ctrl → ターミナルCtrl / 物理Cmd → WezTermアプリ操作
  -- ============================================================

  -- [A] 物理Ctrl (OS: SUPER) → ターミナルへ CTRL として送信
  for i = 97, 122 do -- a-z
    local k = string.char(i)
    table.insert(config.keys, { key = k, mods = 'SUPER', action = wezterm.action.SendKey { key = k, mods = 'CTRL' } })
  end
  table.insert(config.keys, { key = ']', mods = 'SUPER', action = wezterm.action.SendKey { key = ']', mods = 'CTRL' } })
  table.insert(config.keys, { key = '\\', mods = 'SUPER', action = wezterm.action.SendKey { key = '\\', mods = 'CTRL' } })

  -- [A'] 特殊マッピング（ループより後に書いて上書き）
  table.insert(config.keys, { key = 'j', mods = 'SUPER', action = wezterm.action.SendKey { key = 'Enter', mods = 'ALT' } })

  -- Escape / Ctrl-[ で手元(Mac)のIMEを英語にしつつEscapeを送信 (ローカルおよびSSH先のNeovimでも有効)
  local im_select_path = '/opt/homebrew/bin/im-select'
  wezterm.on('escape-and-turn-off-ime-mac', function(window, pane)
    wezterm.background_child_process { im_select_path, 'com.apple.keylayout.Australian' }
    window:perform_action(wezterm.action.SendKey { key = 'Escape' }, pane)
  end)

  table.insert(config.keys, { key = 'Escape', action = wezterm.action.EmitEvent 'escape-and-turn-off-ime-mac' })
  table.insert(config.keys, { key = '[', mods = 'SUPER', action = wezterm.action.EmitEvent 'escape-and-turn-off-ime-mac' })
  table.insert(config.keys, { key = '[', mods = 'CTRL', action = wezterm.action.EmitEvent 'escape-and-turn-off-ime-mac' })

  -- [B] 物理Cmd (OS: CTRL) → WezTermデフォルトのCMDショートカットをCTRLで使えるように
  -- タブ操作
  table.insert(config.keys, { key = 't', mods = 'CTRL', action = wezterm.action.SpawnTab 'CurrentPaneDomain' })
  table.insert(config.keys, { key = 'w', mods = 'CTRL', action = wezterm.action.CloseCurrentPane { confirm = true } })
  table.insert(config.keys, { key = 'n', mods = 'CTRL', action = wezterm.action.SpawnWindow })
  -- コピー＆ペースト
  table.insert(config.keys, { key = 'c', mods = 'CTRL', action = wezterm.action.CopyTo 'Clipboard' })
  table.insert(config.keys, { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' })
  -- 検索・ユーティリティ
  table.insert(config.keys, { key = 'f', mods = 'CTRL', action = wezterm.action.Search { CaseInSensitiveString = '' } })
  table.insert(config.keys, { key = 'q', mods = 'CTRL', action = wezterm.action.QuitApplication })
  table.insert(config.keys, { key = 'Enter', mods = 'CTRL', action = wezterm.action.ToggleFullScreen })
  -- ペイン操作
  table.insert(config.keys, { key = 'd', mods = 'CTRL', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } })
  table.insert(config.keys, { key = 'd', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } })
  table.insert(config.keys, { key = 'z', mods = 'CTRL|SHIFT', action = wezterm.action.TogglePaneZoomState })
  -- Shift付きユーティリティ（H/J/K/Lが矢印キーのため）
  table.insert(config.keys, { key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action.ClearScrollback 'ScrollbackAndViewport' })
  table.insert(config.keys, { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ShowDebugOverlay })
  -- タブ移動
  table.insert(config.keys, { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) })
  table.insert(config.keys, { key = 'RightArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(1) })
  -- タブ番号で直接切替
  for i = 1, 9 do
    table.insert(config.keys, { key = tostring(i), mods = 'CTRL', action = wezterm.action.ActivateTab(i - 1) })
  end

  -- [C] 物理Cmd (OS: CTRL) でVimライク矢印移動（後勝ちでH/J/K/Lを矢印に）
  table.insert(config.keys, { key = 'h', mods = 'CTRL', action = wezterm.action.SendKey { key = 'LeftArrow' } })
  table.insert(config.keys, { key = 'j', mods = 'CTRL', action = wezterm.action.SendKey { key = 'DownArrow' } })
  table.insert(config.keys, { key = 'k', mods = 'CTRL', action = wezterm.action.SendKey { key = 'UpArrow' } })
  table.insert(config.keys, { key = 'l', mods = 'CTRL', action = wezterm.action.SendKey { key = 'RightArrow' } })

else
  -- Windows向けの設定
  wezterm.on('escape-and-turn-off-ime-win', function(window, pane)
    wezterm.background_child_process { 'zenhan.exe', '0' }
    window:perform_action(wezterm.action.SendKey { key = 'Escape' }, pane)
  end)

  config.keys = {
    { key = 'c', mods = 'SUPER', action = wezterm.action.CopyTo 'Clipboard' },
    { key = 'v', mods = 'SUPER', action = wezterm.action.PasteFrom 'Clipboard' },
    { key = 'j', mods = 'SUPER', action = wezterm.action.SendKey { key = 'Enter', mods = 'ALT' } },
    { key = 'Escape', action = wezterm.action.EmitEvent 'escape-and-turn-off-ime-win' },
    { key = '[', mods = 'SUPER', action = wezterm.action.EmitEvent 'escape-and-turn-off-ime-win' },
    { key = '[', mods = 'CTRL', action = wezterm.action.EmitEvent 'escape-and-turn-off-ime-win' },
  }

  wezterm.on('turn-off-ime-and-send-prefix', function(window, pane)
    wezterm.background_child_process { 'zenhan.exe', '0' }
    window:perform_action(wezterm.action.SendKey { key = 'a', mods = 'CTRL' }, pane)
  end)

  table.insert(config.keys, { 
    key = 'a', 
    mods = 'CTRL', 
    action = wezterm.action.EmitEvent 'turn-off-ime-and-send-prefix' 
  })
end

return config
