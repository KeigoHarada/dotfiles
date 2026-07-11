local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- カラースキーム (Neovimに合わせてTokyo Nightに)
config.color_scheme = 'Tokyo Night'

-- フォント設定 (お使いのNerd Fontに合わせて変更してください)
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Regular' })
config.font_size = 14.0

-- ウィンドウの見た目 (透け感とブラー)
config.window_background_opacity = 0.85
config.macos_window_background_blur = 30

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
}

return config
