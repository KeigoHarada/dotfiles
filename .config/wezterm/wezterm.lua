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
  -- ※ こちらも修飾キー入れ替えを考慮して SUPER と CTRL 両方に割り当てます
  { key = 'j', mods = 'SUPER', action = wezterm.action.SendKey { key = 'Enter', mods = 'ALT' } },
  { key = 'j', mods = 'CTRL', action = wezterm.action.SendKey { key = 'Enter', mods = 'ALT' } },

  -- Cmd + [ を Esc にマッピング
  -- ※ Mac側でCmdとCtrlを入れ替えている場合、WezTermがどちらで認識するか
  -- 分かれることがあるため、念のため SUPER(Cmd) と CTRL 両方に割り当てています
  { key = '[', mods = 'SUPER', action = wezterm.action.SendKey { key = 'Escape' } },
  { key = '[', mods = 'CTRL', action = wezterm.action.SendKey { key = 'Escape' } },
  -- Cmd + a を Ctrl + a にマッピング (Mac用・herdrプレフィックス用)
  { key = 'a', mods = 'SUPER', action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' } },
}

return config
