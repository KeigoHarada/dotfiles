# dotfiles

Keigo Harada's dotfiles and environment setup scripts.

## Quick Start (Dotfiles Manager)

`tools.json` で各ツールの対象 OS・インストール方法・設定ファイル（シンボリックリンク）を一元管理しています。

```bash
# macOS / Linux
./dotfiles [mac|linux]

# Windows (PowerShell)
.\dotfiles.ps1 windows

# 設定ファイル（シンボリックリンク）のみ反映したい場合
./dotfiles [os] -c

# プレビュー表示（dry-run）
./dotfiles [os] -n

# バックアップから元の設定ファイルに復元したい場合
./dotfiles restore
```

### ツール設定ファイル (`tools.json`)

新しくツールを追加したい場合は、[`tools.json`](tools.json) に追加するだけです（超シンプル設計）：

```json
"mytool": {
  "os": ["mac", "linux"],
  "install": {
    "mac": "brew install mytool",
    "linux": "sudo apt-get install -y mytool"
  },
  "link": {
    ".config/mytool": "~/.config/mytool"
  }
}
```

### AI エージェント スキル管理 (`skills.sh`)

[`.agents`](.agents) ディレクトリは `~/.agents` へシンボリックリンクされます。主要な AI エージェント（Antigravity, Cursor, Copilot, Cline 等）は `~/.agents/skills/` を共通参照するため、dotfiles をセットアップするだけで追加コマンドなしですぐに標準スキルが利用可能です。

新しいスキルを追加したい場合：
```bash
npx skills add <リポジトリ> -s <スキル名> -g -y
git add .agents && git commit -m "feat: add <スキル名> skill"
```

### Lazygit の AI コミット生成設定

Lazygit 上で `<c-g>` を押した際に使用する AI ツールは、設定ファイルで簡単に切り替えられます。

- 設定ファイル: [`.config/lazygit/ai.conf`](.config/lazygit/ai.conf)
- 記述例:
  ```text
  # agy (Antigravity CLI / Gemini) を使用する場合
  agy

  # GitHub Copilot (copilot / gh copilot) を使用する場合
  copilot
  ```
- 環境変数 `LAZYGIT_AI=copilot` や `git config ai.provider copilot` でも一時的に上書き可能です。

