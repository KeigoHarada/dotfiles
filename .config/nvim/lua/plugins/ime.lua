return {
  "keaising/im-select.nvim",
  config = function()
    local is_mac = vim.fn.has("macunix") == 1
    local cmd = is_mac and "im-select" or "zenhan.exe"

    if not is_mac and vim.fn.executable(cmd) ~= 1 then
      local candidates = {
        vim.fn.expand("~/.local/bin/zenhan.exe"),
        vim.fn.expand("$LOCALAPPDATA/zenhan/zenhan/bin64/zenhan.exe"),
        vim.fn.expand("$LOCALAPPDATA/zenhan/bin64/zenhan.exe"),
      }
      for _, candidate in ipairs(candidates) do
        if vim.fn.executable(candidate) == 1 then
          cmd = candidate
          break
        end
      end
    end

    require("im_select").setup({
      default_im_select = is_mac and "com.apple.keylayout.Australian" or "0",
      default_command = cmd,
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
