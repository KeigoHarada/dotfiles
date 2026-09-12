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

[`.agents/.skill-lock.json`](.agents/.skill-lock.json) に記録されたスキルは、`./dotfiles` 実行時に `npx skills add <source> -g --all` によって全環境（全 OS・全 70+ AI エージェント）へ自動インストール＆シンボリックリンク同期されます。

新しいスキルを追加したい場合：
```bash
npx skills add <リポジトリ/スキル名> -g --all
git add .agents && git commit -m "feat: add <スキル名> skill"
```
これだけで、別環境で `./dotfiles` を実行した際にも自動で同じスキル構成が再現されます。

