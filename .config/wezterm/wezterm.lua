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

-- キーバインドの例
config.keys = {
  -- クリップボード連携
  { key = 'c', mods = 'SUPER', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'SUPER', action = wezterm.action.PasteFrom 'Clipboard' },

  -- agyなどでの改行（複数行入力）用に Cmd + j を Option + Enter (Alt + Enter) にマッピング
  -- ※ Vimライク移動と競合するため、CTRL+j のマッピングはMac環境では無効化するか、SUPERのみにします
  { key = 'j', mods = 'SUPER', action = wezterm.action.SendKey { key = 'Enter', mods = 'ALT' } },
  -- { key = 'j', mods = 'CTRL', action = wezterm.action.SendKey { key = 'Enter', mods = 'ALT' } },

  -- Cmd + [ を Esc にマッピング
  -- ※ Mac側でCmdとCtrlを入れ替えている場合、WezTermがどちらで認識するか
  -- 分かれることがあるため、念のため SUPER(Cmd) と CTRL 両方に割り当てています
  { key = '[', mods = 'SUPER', action = wezterm.action.SendKey { key = 'Escape' } },
  { key = '[', mods = 'CTRL', action = wezterm.action.SendKey { key = 'Escape' } },
  -- Mac専用の Cmd+a / Cmd+b のマッピングは下部の is_mac ブロックに移動しました
}

-- Mac専用の設定
local is_mac = wezterm.target_triple:find('darwin') ~= nil
if is_mac then
  -- Vimライクなカーソル移動 (Ctrl + h/j/k/l)
  table.insert(config.keys, { key = 'h', mods = 'CTRL', action = wezterm.action.SendKey { key = 'LeftArrow' } })
  table.insert(config.keys, { key = 'j', mods = 'CTRL', action = wezterm.action.SendKey { key = 'DownArrow' } })
  table.insert(config.keys, { key = 'k', mods = 'CTRL', action = wezterm.action.SendKey { key = 'UpArrow' } })
  table.insert(config.keys, { key = 'l', mods = 'CTRL', action = wezterm.action.SendKey { key = 'RightArrow' } })

  -- Cmd + a を Ctrl + a にマッピング (herdrプレフィックス用)
  table.insert(config.keys, { key = 'a', mods = 'SUPER', action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' } })
  -- Cmd + g を Ctrl + g にマッピング (LazygitのAIコミット用 / "Generate"のg)
  table.insert(config.keys, { key = 'g', mods = 'SUPER', action = wezterm.action.SendKey { key = 'g', mods = 'CTRL' } })
end

return config
