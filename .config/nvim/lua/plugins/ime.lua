return {
  "keaising/im-select.nvim",
  config = function()
    local is_mac = vim.fn.has("macunix") == 1
    require("im_select").setup({
      default_im_select = is_mac and "com.apple.keylayout.Australian" or "0",
      default_command = is_mac and "im-select" or "zenhan.exe",
      -- InsertLeave と CmdlineLeave のみ
      set_default_events = {
        "VimEnter",
        "FocusGained",
        "InsertLeave",
        "CmdlineLeave",
      },
      -- Insertモードに戻ったときに前のIMEを復元しない
      set_previous_events = {},
    })
  end,
}
