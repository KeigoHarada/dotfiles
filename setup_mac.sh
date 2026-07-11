#!/usr/bin/env bash
# ==========================================
# macOS Development Environment Setup Script
# ==========================================
# Tools: Homebrew, curl, git, zsh, neovim, node.js, agy, tmux, lazygit, im-select
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
  error "このスクリプトを root (sudo) で実行しないでください。"
  exit 1
fi

# ==========================================
# 0. Homebrew
# ==========================================
section "Homebrew"
if command -v brew &>/dev/null; then
  warn "Homebrew は既にインストール済みです ($(brew --version | head -1))"
else
  info "Homebrew をインストール中..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # パスを通す処理 (Apple Silicon / Intel Mac の両対応)
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  success "Homebrew をインストールしました"
fi

# Homebrew のアップデート
info "Homebrew をアップデート中..."
brew update

# ==========================================
# 1-4. Basic Tools (curl, git, zsh, tmux)
# ==========================================
section "Basic Tools (curl, git, zsh, tmux)"
for pkg in curl git zsh tmux; do
  if brew list "$pkg" &>/dev/null; then
    warn "$pkg は既にインストール済みです"
  else
    brew install "$pkg"
    success "$pkg をインストールしました"
  fi
done

# ==========================================
# 4.5. oh-my-zsh
# ==========================================
section "oh-my-zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  warn "oh-my-zsh は既にインストール済みです"
else
  info "oh-my-zsh をインストール中..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  if [ "$SHELL" != "$(which zsh)" ] && [ "$SHELL" != "/bin/zsh" ]; then
    info "デフォルトシェルを zsh に変更します..."
    chsh -s "$(which zsh)" || warn "デフォルトシェルの変更に失敗しました。手動で設定してください。"
  fi
  success "oh-my-zsh をインストールしました"
fi

# ==========================================
# 4.6. Zsh Plugins & fzf
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
  brew install fzf
  $(brew --prefix)/opt/fzf/install --all
  success "fzf をインストールしました"
else
  warn "fzf は既にインストール済みです"
fi

# ==========================================
# 5. neovim
# ==========================================
section "neovim"
if command -v nvim &>/dev/null; then
  warn "neovim は既にインストール済みです ($(nvim --version | head -1))"
else
  brew install neovim
  success "neovim をインストールしました"
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

  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  info "Node.js LTS をインストール中..."
  nvm install --lts
  nvm use --lts
  nvm alias default 'lts/*'
  success "Node.js をインストールしました ($(node --version))"
fi

# nvm の初期化設定を .zshrc へ追記 (未追加の場合のみ)
NVM_INIT='export NVM_DIR="$HOME/.nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'
RC="$HOME/.zshrc"
if [[ -f "$RC" ]] && ! grep -q "NVM_DIR" "$RC"; then
  echo "" >> "$RC"
  echo "# nvm (Node Version Manager)" >> "$RC"
  printf "%b\n" "$NVM_INIT" >> "$RC"
  info "nvm の初期化設定を $RC に追記しました"
fi

# ==========================================
# 7. Antigravity CLI (agy)
# ==========================================
section "Antigravity CLI (agy)"
if command -v agy &>/dev/null; then
  warn "Antigravity CLI (agy) は既にインストール済みです"
else
  info "Antigravity CLI をインストール中..."
  curl -fsSL https://antigravity.google/cli/install.sh | bash
  success "Antigravity CLI をインストールしました"
fi

# ==========================================
# 8. libicu (marksman LSP) は macOS の場合 built-in で対応可能なためスキップ
# ==========================================
info "libicu は macOS では標準ライブラリで対応可能なためスキップします"

# ==========================================
# 9. prettier (Markdown フォーマッター)
# ==========================================
section "prettier"
if command -v prettier &>/dev/null; then
  warn "prettier は既にインストール済みです ($(prettier --version))"
else
  if ! command -v npm &>/dev/null; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
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
  info "lazygit をインストール中..."
  brew install lazygit
  success "lazygit をインストールしました"
fi

# ==========================================
# 11. im-select (zenhan 代替)
# ==========================================
section "im-select (zenhan 代替)"
if command -v im-select &>/dev/null; then
  warn "im-select は既にインストール済みです"
else
  info "im-select をインストール中..."
  brew tap daipeihust/tap
  brew install im-select
  success "im-select をインストールしました"
fi

# ==========================================
# 12. WezTerm
# ==========================================
section "WezTerm"
if brew list --cask wezterm &>/dev/null; then
  warn "WezTerm は既にインストール済みです"
else
  info "WezTerm をインストール中..."
  brew install --cask wezterm
  success "WezTerm をインストールしました"
fi

# ==========================================
# 13. JetBrainsMono Nerd Font
# ==========================================
section "JetBrainsMono Nerd Font"
if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
  warn "JetBrainsMono Nerd Font は既にインストール済みです"
else
  info "JetBrainsMono Nerd Font をインストール中..."
  brew install --cask font-jetbrains-mono-nerd-font
  success "JetBrainsMono Nerd Font をインストールしました"
fi

# ==========================================
# 14. Dotfiles の配置
# ==========================================
section "Dotfiles の配置 (コピー)"
info "設定ファイルを配置しています..."

# .zshrc
cp -f "$HOME/dotfiles/.config/.zshrc" "$HOME/.zshrc"

# .config 内の各ディレクトリ
mkdir -p "$HOME/.config/nvim" "$HOME/.config/tmux" "$HOME/.config/wezterm"
cp -R "$HOME/dotfiles/.config/nvim/"* "$HOME/.config/nvim/" 2>/dev/null || true
cp -R "$HOME/dotfiles/.config/tmux/"* "$HOME/.config/tmux/" 2>/dev/null || true
cp -R "$HOME/dotfiles/.config/wezterm/"* "$HOME/.config/wezterm/" 2>/dev/null || true

success "すべての設定ファイルをコピーしました"

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

print_version "Homebrew"   "brew --version"
print_version "curl"       "curl --version"
print_version "git"        "git --version"
print_version "zsh"        "zsh --version"
print_version "tmux"       "tmux -V"
print_version "neovim"     "nvim --version"
print_version "node"       "node --version"
print_version "npm"        "npm --version"
print_version "lazygit"    "lazygit --version"
print_version "agy"        "agy --version"
print_version "im-select"  "im-select"
print_version "WezTerm"    "wezterm --version"

echo ""
echo -e "${YELLOW}NOTE:${RESET} Node.js / npm などのパスを反映するにはシェルを再起動してください。"
echo -e "          Antigravity CLI の認証: ${BOLD}agy auth${RESET}"
echo ""
