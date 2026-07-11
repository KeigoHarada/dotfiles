#!/usr/bin/env bash
# ==========================================
# WSL Development Environment Setup Script
# ==========================================
# Tools: curl, git, zsh, neovim, node.js, github copilot cli, tmux, lazygit
# ==========================================

set -euo pipefail

# ==========================================
# Colors & Helpers
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[OK]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
section() { echo -e "\n${BOLD}${CYAN}==> $*${RESET}"; }

# ==========================================
# Privilege check
# ==========================================
if [[ $EUID -eq 0 ]]; then
  error "このスクリプトを root で実行しないでください。sudo は内部で必要な箇所のみ使用します。"
  exit 1
fi

# ==========================================
# Package index update & Basic build tools
# ==========================================
section "パッケージリストを更新と基本ツールのインストール"
sudo apt-get update -qq
sudo apt-get install -y build-essential
success "apt update & build-essential 完了"

# ==========================================
# 1. curl
# ==========================================
section "curl"
if command -v curl &>/dev/null; then
  warn "curl は既にインストール済みです ($(curl --version | head -1))"
else
  sudo apt-get install -y curl
  success "curl をインストールしました"
fi

# ==========================================
# 2. git
# ==========================================
section "git"
if command -v git &>/dev/null; then
  warn "git は既にインストール済みです ($(git --version))"
else
  sudo apt-get install -y git
  success "git をインストールしました"
fi

# ==========================================
# 3. zsh
# ==========================================
section "zsh"
if command -v zsh &>/dev/null; then
  warn "zsh は既にインストール済みです ($(zsh --version))"
else
  sudo apt-get install -y zsh
  success "zsh をインストールしました"
fi

# ==========================================
# 3.5. oh-my-zsh
# ==========================================
section "oh-my-zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  warn "oh-my-zsh は既にインストール済みです"
else
  info "oh-my-zsh をインストール中..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  if [ "$SHELL" != "$(which zsh)" ] && [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
    info "デフォルトシェルを zsh に変更します (パスワードを求められる場合があります)..."
    chsh -s "$(which zsh)" || warn "デフォルトシェルの変更に失敗しました。手動で設定してください。"
  fi
  success "oh-my-zsh をインストールしました"
fi

# ==========================================
# 3.6. Zsh Plugins & fzf
# ==========================================
section "Zsh Plugins & fzf"
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  info "zsh-autosuggestions をインストール中..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  info "zsh-syntax-highlighting をインストール中..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if ! command -v fzf &>/dev/null; then
  info "fzf をインストール中..."
  sudo apt-get install -y fzf
  success "fzf をインストールしました"
else
  warn "fzf は既にインストール済みです"
fi

# ==========================================
# 4. tmux
# ==========================================
section "tmux"
if command -v tmux &>/dev/null; then
  warn "tmux は既にインストール済みです ($(tmux -V))"
else
  sudo apt-get install -y tmux
  success "tmux をインストールしました"
fi

# ==========================================
# 5. neovim (Nightly版を導入)
# ==========================================
section "neovim"
if command -v nvim &>/dev/null; then
  warn "neovim は既にインストール済みです ($(nvim --version | head -1))"
else
  info "neovimのNightly版(最新開発版)をダウンロード中..."
  NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz"
  NVIM_TMP="$(mktemp -d)"
  curl -fsSL "$NVIM_URL" -o "$NVIM_TMP/nvim.tar.gz"
  sudo tar -C /usr/local -xzf "$NVIM_TMP/nvim.tar.gz" --strip-components=1
  rm -rf "$NVIM_TMP"
  success "neovim をインストールしました ($(nvim --version | head -1))"
fi

# ==========================================
# 6. Node.js (nvm 経由で LTS)
# ==========================================
section "Node.js (nvm 経由)"
if command -v node &>/dev/null; then
  warn "Node.js は既にインストール済みです ($(node --version))"
else
  if [ ! -d "$HOME/.nvm" ]; then
    info "nvm をインストール中..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
  fi

  # nvm を現在のセッションで使えるようにする
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  source "$NVM_DIR/nvm.sh"

  info "Node.js LTS をインストール中..."
  nvm install --lts
  nvm use --lts
  nvm alias default 'lts/*'
  success "Node.js をインストールしました ($(node --version))"
fi

# nvm の初期化設定を .bashrc / .zshrc へ追記 (未追加の場合のみ)
NVM_INIT='export NVM_DIR="$HOME/.nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [[ -f "$RC" ]] && ! grep -q "NVM_DIR" "$RC"; then
    echo "" >> "$RC"
    echo "# nvm (Node Version Manager)" >> "$RC"
    printf "%b\n" "$NVM_INIT" >> "$RC"
    info "nvm の初期化設定を $RC に追記しました"
  fi
done

# ==========================================
# 7. GitHub Copilot CLI (@githubnext/github-copilot-cli)
# ==========================================
section "GitHub Copilot CLI"
if npm list -g @githubnext/github-copilot-cli &>/dev/null 2>&1; then
  warn "GitHub Copilot CLI は既にインストール済みです"
else
  # npm がセッションで使えることを確認
  if ! command -v npm &>/dev/null; then
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"
  fi
  info "GitHub Copilot CLI をグローバルインストール中..."
  npm install -g @githubnext/github-copilot-cli
  success "GitHub Copilot CLI をインストールしました"
fi

# ==========================================
# 8. libicu (marksman LSP の依存パッケージ)
# ==========================================
section "libicu"
if ldconfig -p 2>/dev/null | grep -q libicu; then
  warn "libicu は既にインストール済みです"
else
  sudo apt-get install -y libicu-dev
  success "libicu をインストールしました"
fi

# ==========================================
# 9. prettier (Markdown フォーマッター)
# ==========================================
section "prettier"
if command -v prettier &>/dev/null; then
  warn "prettier は既にインストール済みです ($(prettier --version))"
else
  if ! command -v npm &>/dev/null; then
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"
  fi
  info "prettier をグローバルインストール中..."
  npm install -g prettier
  success "prettier をインストールしました ($(prettier --version))"
fi

# ==========================================
# 10. lazygit
# ==========================================
section "lazygit"
if command -v lazygit &>/dev/null; then
  warn "lazygit は既にインストール済みです ($(lazygit --version | head -1))"
else
  info "lazygit の最新バージョンを取得中..."
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \
    grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
  LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  LAZYGIT_TMP="$(mktemp -d)"
  curl -fsSL "$LAZYGIT_URL" -o "$LAZYGIT_TMP/lazygit.tar.gz"
  tar -xzf "$LAZYGIT_TMP/lazygit.tar.gz" -C "$LAZYGIT_TMP"
  sudo install "$LAZYGIT_TMP/lazygit" /usr/local/bin/lazygit
  rm -rf "$LAZYGIT_TMP"
  success "lazygit v${LAZYGIT_VERSION} をインストールしました"
fi

# ==========================================
# 11. Herdr
# ==========================================
section "Herdr"
if command -v herdr &>/dev/null; then
  warn "Herdr は既にインストール済みです ($(herdr --version | head -1))"
else
  info "Herdr の最新バージョンを取得中..."
  HERDR_VERSION=$(curl -s "https://api.github.com/repos/ogulcancelik/herdr/releases/latest" | \
    grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
  HERDR_URL="https://github.com/ogulcancelik/herdr/releases/download/v${HERDR_VERSION}/herdr-linux-x86_64"
  HERDR_TMP="$(mktemp -d)"
  curl -fsSL "$HERDR_URL" -o "$HERDR_TMP/herdr"
  chmod +x "$HERDR_TMP/herdr"
  sudo install "$HERDR_TMP/herdr" /usr/local/bin/herdr
  rm -rf "$HERDR_TMP"
  success "Herdr v${HERDR_VERSION} をインストールしました"
fi

# ==========================================
# 12. Windows Tools (zenhan)
# ==========================================
section "Windows Tools (zenhan)"
if command -v powershell.exe &>/dev/null; then
  if powershell.exe -Command "Get-Command zenhan.exe -ErrorAction SilentlyContinue" | grep -q "zenhan.exe"; then
    warn "zenhan は既にインストール済みです"
  else
    info "Windows側に zenhan をインストール中..."
    SCRIPT_PATH="$(dirname "$0")/install_zenhan.ps1"
    if [[ -f "$SCRIPT_PATH" ]]; then
      WIN_SCRIPT_PATH=$(wslpath -w "$SCRIPT_PATH")
      powershell.exe -ExecutionPolicy Bypass -File "$WIN_SCRIPT_PATH"
      success "zenhan のインストールスクリプトを実行しました"
    else
      warn "install_zenhan.ps1 が見つかりませんでした。スキップします。"
    fi
  fi
else
  warn "powershell.exe が見つかりません。WSL環境でないか、パスが通っていません。"
fi

# ==========================================
# 13. Dotfiles の配置
# ==========================================
section "Dotfiles の配置 (コピー)"
info "設定ファイルを配置しています..."

# .zshrc
cp -f "$HOME/dotfiles/.config/.zshrc" "$HOME/.zshrc"

# .config 内の各ディレクトリ
mkdir -p "$HOME/.config/nvim" "$HOME/.config/tmux" "$HOME/.config/herdr" "$HOME/.config/lazygit"
cp -R "$HOME/dotfiles/.config/nvim/"* "$HOME/.config/nvim/" 2>/dev/null || true
cp -R "$HOME/dotfiles/.config/tmux/"* "$HOME/.config/tmux/" 2>/dev/null || true
cp -R "$HOME/dotfiles/.config/herdr/"* "$HOME/.config/herdr/" 2>/dev/null || true
cp -R "$HOME/dotfiles/.config/lazygit/"* "$HOME/.config/lazygit/" 2>/dev/null || true

success "設定ファイルをコピーしました (WezTermを除く)"

# ==========================================
# Summary
# ==========================================
echo ""
echo -e "${BOLD}${GREEN}==========================================${RESET}"
echo -e "${BOLD}${GREEN}セットアップ完了！${RESET}"
echo -e "${BOLD}${GREEN}==========================================${RESET}"
echo ""

print_version() {
  local name="$1"
  local cmd="$2"
  if command -v "$cmd" &>/dev/null; then
    printf "  ${GREEN}%-22s${RESET} %-22s %s\n" "$name" "$($cmd 2>&1 | head -1)"
  else
    printf "  ${YELLOW}%-22s${RESET} %-22s (シェル再起動後に確認してください)\n" "$name"
  fi
}

print_version "curl"       "curl --version"
print_version "git"        "git --version"
print_version "zsh"        "zsh --version"
print_version "tmux"       "tmux -V"
print_version "neovim"     "nvim --version"
print_version "node"       "node --version"
print_version "npm"        "npm --version"
print_version "lazygit"    "lazygit --version"
print_version "Herdr"      "herdr --version"

echo ""
echo -e "${YELLOW}NOTE:${RESET} Node.js / npm のパスを反映するにはシェルを再起動してください。"
echo -e "          Github Copilot CLI の認証: ${BOLD}github-copilot-cli auth${RESET}"
echo ""
