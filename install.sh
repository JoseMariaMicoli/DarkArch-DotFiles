#!/bin/bash
# --- xoce's R&D Environment Deployment Script ---
# MIT License - BlackArch + i3wm + Kitty

set -e

echo "[*] Starting environment deployment..."

# 1. Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[+] Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 2. Install Powerlevel10k
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "[+] Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# 3. Download JetBrains Mono Nerd Font
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -d "$FONT_DIR/JetBrainsMono" ]; then
    echo "[+] Downloading JetBrains Mono Nerd Font..."
    mkdir -p "$FONT_DIR/JetBrainsMono"
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -o /tmp/jb.zip
    unzip /tmp/jb.zip -d "$FONT_DIR/JetBrainsMono"
    rm /tmp/jb.zip
    fc-cache -fv
fi

# 4. Apply Dotfiles with GNU Stow
echo "[+] Linking configurations with GNU Stow..."
cd ~/dotfiles
stow i3 polybar rofi picom kitty zsh bin

echo "--------------------------------------------------"
echo "DONE! Please restart your terminal or run: source ~/.zshrc"
echo "If icons look broken, set 'JetBrainsMono Nerd Font' in Kitty/Polybar."
echo "--------------------------------------------------"
