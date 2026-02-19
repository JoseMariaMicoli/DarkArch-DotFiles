#!/bin/bash
# --- xoce's R&D Environment Deployment Script ---
# Repo: DarkArch-DotFiles
# MIT License - BlackArch + i3wm + Kitty

set -e

# Detect the script's directory dynamically
BASEDIR=$(cd "$(dirname "$0")" && pwd)

echo "[*] Starting DarkArch environment deployment from: $BASEDIR"

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
    rm -f /tmp/jb.zip
    fc-cache -fv
fi

# 4. Cleanup existing configs to avoid Stow conflicts
echo "[-] Cleaning up existing config files to prevent conflicts..."
rm -f "$HOME/.zshrc" "$HOME/.p10k.zsh"
# Only remove directories if they are NOT symlinks already
for dir in i3 polybar rofi picom kitty; do
    if [ -d "$HOME/.config/$dir" ] && [ ! -L "$HOME/.config/$dir" ]; then
        rm -rf "$HOME/.config/$dir"
    fi
done

# 5. Apply Dotfiles with GNU Stow
echo "[+] Linking configurations with GNU Stow..."
cd "$BASEDIR"
# Added -R to restow and --adopt to handle minor mismatches
stow -R i3 polybar rofi picom kitty zsh bin

echo "--------------------------------------------------"
echo "DONE! DarkArch environment is now active."
echo "Please restart your terminal or run: source ~/.zshrc"
echo "If icons look broken, verify JetBrainsMono NF is selected in Kitty."
echo "--------------------------------------------------"