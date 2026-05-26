#!/bin/bash
# chezmoi run_once script — install packages and tools on a new machine
set -e

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "oh-my-zsh already installed"
    return
  fi
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
}

install_zsh_plugins() {
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$zsh_custom/plugins"

  # zsh-autosuggestions
  if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
  fi

  # zsh-syntax-highlighting
  if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_custom/plugins/zsh-syntax-highlighting"
  fi

  # fzf-tab
  if [[ ! -d "$zsh_custom/plugins/fzf-tab" ]]; then
    git clone https://github.com/Aloxaf/fzf-tab "$zsh_custom/plugins/fzf-tab"
  fi

  # powerlevel10k
  if [[ ! -d "$zsh_custom/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k "$zsh_custom/themes/powerlevel10k"
  fi
}

install_fzf() {
  if command -v fzf &>/dev/null; then
    echo "fzf already installed"
    return
  fi
  if [[ ! -d "$HOME/.fzf" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-bash
  fi
}

install_lazygit() {
  if command -v lazygit &>/dev/null; then
    echo "lazygit already installed"
    return
  fi
  local version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  mkdir -p "$HOME/.local/bin"
  mv lazygit "$HOME/.local/bin/"
  rm lazygit.tar.gz
}

install_neovim() {
  if command -v nvim &>/dev/null; then
    # Check version meets LazyVim requirement (>= 0.9.0)
    local ver=$(nvim --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+' | head -1)
    if [[ -n "$ver" && "$(echo "$ver >= 0.9" | bc 2>/dev/null || echo 0)" -eq 1 ]]; then
      echo "neovim $ver already installed (meets >= 0.9.0 requirement)"
      return
    fi
    echo "neovim $ver is too old for LazyVim (needs >= 0.9.0), upgrading..."
  fi

  # Use AppImage — self-contained, works on any glibc version
  curl -LO "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
  chmod +x nvim-linux-x86_64.appimage
  mkdir -p "$HOME/.local/bin"
  mv nvim-linux-x86_64.appimage "$HOME/.local/bin/nvim"

  # Extract appimage to get full runtime if needed
  "$HOME/.local/bin/nvim" --version
}

install_base_packages() {
  # minimal deps: zsh + git must be installed before oh-my-zsh
  local SUDO=""
  [[ "$(id -u)" -eq 0 ]] || SUDO="sudo -n"

  if command -v apt-get &>/dev/null; then
    $SUDO apt-get update -qq
    $SUDO apt-get install -y -qq zsh git tmux fzf ripgrep fd-find bat tree htop unzip wget curl jq xclip 2>/dev/null || true
    mkdir -p "$HOME/.local/bin"
    [[ -f "$HOME/.local/bin/fd" ]] || ln -s "$(which fdfind 2>/dev/null)" "$HOME/.local/bin/fd" 2>/dev/null || true
    [[ -f "$HOME/.local/bin/bat" ]] || ln -s "$(which batcat 2>/dev/null)" "$HOME/.local/bin/bat" 2>/dev/null || true
  elif command -v dnf &>/dev/null; then
    $SUDO dnf install -y zsh git tmux fzf ripgrep bat tree htop unzip wget curl jq 2>/dev/null || true
  elif command -v yum &>/dev/null; then
    $SUDO yum install -y zsh git tmux fzf ripgrep bat tree htop unzip wget curl jq 2>/dev/null || true
  elif command -v apk &>/dev/null; then
    $SUDO apk add zsh git tmux fzf ripgrep bat tree htop unzip wget curl jq 2>/dev/null || true
  elif command -v pacman &>/dev/null; then
    $SUDO pacman -S --noconfirm zsh git tmux fzf ripgrep bat tree htop unzip wget curl jq 2>/dev/null || true
  else
    echo "!!! zsh and git are required. Install them manually, then re-run chezmoi apply."
    echo "!!! https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH"
    exit 1
  fi
}

# Main
echo "=== Setting up new machine ==="

install_base_packages

install_oh_my_zsh
install_zsh_plugins
install_fzf
install_neovim
install_lazygit

echo "=== Setup complete ==="
echo "Run: chsh -s $(which zsh)    # to change default shell"
echo "Run: p10k configure          # to re-run powerlevel10k wizard"
