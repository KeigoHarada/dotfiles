#!/usr/bin/env bash
# =============================================================================
# WSL Development Environment Setup Script
# =============================================================================
# Tools: curl, git, zsh, neovim, node.js, github copilot cli, tmux, lazygit
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Colors & Helpers
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
section() { echo -e "\n${BOLD}${CYAN}==> $*${RESET}"; }

# -----------------------------------------------------------------------------
# Privilege check
# -----------------------------------------------------------------------------
if [[ $EUID -eq 0 ]]; then
  error "このスクリプトを root で実行しないでください。sudo は内部で必要な箇所のみ使用します。"
  exit 1
fi

# -----------------------------------------------------------------------------
# Package index update
# -----------------------------------------------------------------------------
section "パッケージリストを更新"
sudo apt-get update -qq
success "apt update 完了"

# -----------------------------------------------------------------------------
# 1. curl
# -----------------------------------------------------------------------------
section "curl"
if command -v curl &>/dev/null; then
  warn "curl は既にインストール済みです ($(curl --version | head -1))"
else
  sudo apt-get install -y curl
  success "curl をインストールしました"
fi

# -----------------------------------------------------------------------------
# 2. git
# -----------------------------------------------------------------------------
section "git"
if command -v git &>/dev/null; then
  warn "git は既にインストール済みです ($(git --version))"
else
  sudo apt-get install -y git
  success "git をインストールしました"
fi

# -----------------------------------------------------------------------------
# 3. zsh
# -----------------------------------------------------------------------------
section "zsh"
if command -v zsh &>/dev/null; then
  warn "zsh は既にインストール済みです ($(zsh --version))"
else
  sudo apt-get install -y zsh
  success "zsh をインストールしました"
fi

# -----------------------------------------------------------------------------
# 4. tmux
# -----------------------------------------------------------------------------
section "tmux"
if command -v tmux &>/dev/null; then
  warn "tmux は既にインストール済みです ($(tmux -V))"
else
  sudo apt-get install -y tmux
  success "tmux をインストールしました"
fi

# -----------------------------------------------------------------------------
# 5. neovim (最新安定版を AppImage で導入)
# -----------------------------------------------------------------------------
section "neovim"
if command -v nvim &>/dev/null; then
  warn "neovim は既にインストール済みです ($(nvim --version | head -1))"
else
  info "neovim の最新安定版をダウンロード中..."
  NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
  NVIM_TMP="$(mktemp -d)"
  curl -fsSL "$NVIM_URL" -o "$NVIM_TMP/nvim.tar.gz"
  sudo tar -C /usr/local -xzf "$NVIM_TMP/nvim.tar.gz" --strip-components=1
  rm -rf "$NVIM_TMP"
  success "neovim をインストールしました ($(nvim --version | head -1))"
fi

# -----------------------------------------------------------------------------
# 6. Node.js (nvm 経由で LTS)
# -----------------------------------------------------------------------------
section "Node.js (nvm 経由)"
if command -v node &>/dev/null; then
  warn "Node.js は既にインストール済みです ($(node --version))"
else
  if [[ ! -d "$HOME/.nvm" ]]; then
    info "nvm をインストール中..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
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

# nvm の初期化設定を .bashrc / .zshrc へ追記（未追加の場合のみ）
NVM_INIT='export NVM_DIR="$HOME/.nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"\n[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"'
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [[ -f "$RC" ]] && ! grep -q "NVM_DIR" "$RC"; then
    echo "" >> "$RC"
    echo "# nvm (Node Version Manager)" >> "$RC"
    printf "%b\n" "$NVM_INIT" >> "$RC"
    info "nvm の初期化設定を $RC に追記しました"
  fi
done

# -----------------------------------------------------------------------------
# 7. GitHub Copilot CLI  (@githubnext/github-copilot-cli)
# -----------------------------------------------------------------------------
section "GitHub Copilot CLI"
if npm list -g @github/copilot &>/dev/null 2>&1; then
  warn "GitHub Copilot CLI は既にインストール済みです"
else
  # npm がセッションで使えることを確認
  if ! command -v npm &>/dev/null; then
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"
  fi
  info "GitHub Copilot CLI をグローバルインストール中..."
  npm install -g @github/copilot
  success "GitHub Copilot CLI をインストールしました"
fi

# -----------------------------------------------------------------------------
# 8. lazygit
# -----------------------------------------------------------------------------
section "lazygit"
if command -v lazygit &>/dev/null; then
  warn "lazygit は既にインストール済みです ($(lazygit --version | head -1))"
else
  info "lazygit の最新バージョンを取得中..."
  LAZYGIT_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
  LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  LAZYGIT_TMP="$(mktemp -d)"
  curl -fsSL "$LAZYGIT_URL" -o "$LAZYGIT_TMP/lazygit.tar.gz"
  tar -xzf "$LAZYGIT_TMP/lazygit.tar.gz" -C "$LAZYGIT_TMP"
  sudo install "$LAZYGIT_TMP/lazygit" /usr/local/bin/lazygit
  rm -rf "$LAZYGIT_TMP"
  success "lazygit v${LAZYGIT_VERSION} をインストールしました"
fi

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo -e "${BOLD}${GREEN}======================================"
echo -e "  セットアップ完了！"
echo -e "======================================${RESET}"
echo ""
echo -e "${BOLD}インストール済みツール:${RESET}"

print_version() {
  local name="$1"
  local cmd="$2"
  if command -v "$cmd" &>/dev/null; then
    printf "  ${GREEN}✓${RESET} %-22s %s\n" "$name" "$($cmd 2>&1 | head -1)"
  else
    printf "  ${YELLOW}?${RESET} %-22s (シェル再起動後に確認してください)\n" "$name"
  fi
}

print_version "curl"    "curl --version"
print_version "git"     "git --version"
print_version "zsh"     "zsh --version"
print_version "tmux"    "tmux -V"
print_version "neovim"  "nvim --version"
print_version "node"    "node --version"
print_version "npm"     "npm --version"
print_version "lazygit" "lazygit --version"

echo ""
echo -e "${YELLOW}NOTE:${RESET} Node.js / npm のパスを反映するにはシェルを再起動してください。"
echo -e "      GitHub Copilot CLI の認証: ${BOLD}github-copilot-cli auth${RESET}"
echo ""
