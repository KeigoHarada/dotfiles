# dotfiles

Keigo Harada's dotfiles and environment setup scripts.

## Setup Scripts

This repository contains setup scripts to configure development environments for WSL and macOS.

### For macOS
The macOS setup script installs:
- [Homebrew](https://brew.sh/)
- `curl`, `git`, `zsh`
- `tmux`, `neovim`, `lazygit`
- [nvm](https://github.com/nvm-sh/nvm) & Node.js (LTS)
- Antigravity CLI (agy)
- Symlinks for `.config/.zshrc` and `.config/nvim` configuration files

To run the macOS setup:
```bash
./setup_mac.sh
```

### For WSL (Ubuntu)
The WSL setup script installs:
- `curl`, `git`, `zsh`, `tmux`
- `neovim` (latest stable tarball)
- `lazygit` (via github releases)
- [nvm](https://github.com/nvm-sh/nvm) & Node.js (LTS)
- GitHub Copilot CLI

To run the WSL setup:
```bash
./setup_wsl.sh
```
