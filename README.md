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
