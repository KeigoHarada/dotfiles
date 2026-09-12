# dotfiles

Keigo Harada's dotfiles and environment setup scripts.

## Quick Start (Dotfiles Manager)

`tools.json` で各ツールの対象 OS・インストール方法・設定ファイル（シンボリックリンク）を一元管理しています。

```bash
# macOS のセットアップ（ツールインストール & シンボリックリンク反映）
./dotfiles mac

# Linux のセットアップ
./dotfiles linux

# Windows のセットアップ
./dotfiles windows

# 設定ファイル（シンボリックリンク）のみ反映したい場合
./dotfiles mac -c

# プレビュー表示（dry-run）
./dotfiles mac -n

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

[`.agents/.skill-lock.json`](.agents/.skill-lock.json) に記録されたスキルは、`./dotfiles` 実行時に `npx skills add <source> -g -y` によって共通ディレクトリ（`~/.agents/skills/`）へ自動インストール＆同期されます。主要な AI エージェント（Antigravity, Cursor, Copilot, Cline 等）はここを共通参照するため、使っていないエージェントの不要フォルダが作られることもありません。

新しいスキルを追加したい場合：
```bash
npx skills add <リポジトリ/スキル名> -g -y
git add .agents && git commit -m "feat: add <スキル名> skill"
```
これだけで、別環境で `./dotfiles` を実行した際にも自動で同じスキル構成が再現されます。

### Lazygit の AI コミット生成設定

Lazygit 上で `<c-g>` を押した際に使用する AI ツールは、設定ファイルで簡単に切り替えられます。

- 設定ファイル: [`.config/lazygit/ai.conf`](.config/lazygit/ai.conf)
- 記述例:
  ```text
  # agy (Antigravity CLI / Gemini) を使用する場合
  agy

  # GitHub Copilot (gh copilot / github-copilot-cli) を使用する場合
  copilot
  ```
- 環境変数 `LAZYGIT_AI=copilot` や `git config ai.provider copilot` でも一時的に上書き可能です。

