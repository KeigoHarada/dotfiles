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

      -- WSL環境の場合、Windows側のユーザーディレクトリ配下を動的探索
      if vim.fn.has("wsl") == 1 then
        local wsl_patterns = {
          "/mnt/c/Users/*/.local/bin/zenhan.exe",
          "/mnt/c/Users/*/AppData/Local/zenhan/zenhan/bin64/zenhan.exe",
          "/mnt/c/Users/*/AppData/Local/zenhan/bin64/zenhan.exe",
          "/mnt/c/Users/*/AppData/Local/zenhan/**/zenhan.exe",
        }
        for _, pat in ipairs(wsl_patterns) do
          local matches = vim.fn.glob(pat, false, true)
          for _, m in ipairs(matches) do
            table.insert(candidates, m)
          end
        end
      end

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

    -- SSH接続時でも手元のWezTermなどの端末にIMEオフを通知 (OSC 1337: SetUserVar=ime=off)
    vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
      group = vim.api.nvim_create_augroup("im-select-osc", { clear = true }),
      callback = function()
        -- base64("off") == "b2Zm"
        vim.fn.chansend(vim.v.stderr, "\x1b]1337;SetUserVar=ime=b2Zm\x07")
      end,
    })
  end,
}
