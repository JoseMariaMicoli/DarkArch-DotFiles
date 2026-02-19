# --- INSTANT PROMPT (P10k) ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- CONFIGURACIÓN OH-MY-ZSH ---
export ZSH="$HOME/.oh-my-zsh"

# Plugins de OMZ (sudo incluido aquí)
plugins=(git extract sudo web-search)

# CARGAR OH-MY-ZSH (Obligatorio para que funcionen los plugins de arriba)
source $ZSH/oh-my-zsh.sh

# --- TEMA Y APARIENCIA ---
# Priorizar la instalación local de Powerlevel10k del repositorio
if [ -f "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
else
    source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- PLUGINS EXTERNOS (Rutas de Pacman / BlackArch) ---
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh 2>/dev/null

# Búsqueda en historial con flechas
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# --- CONFIGURACIÓN DE FZF ---
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --color=16"
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# --- AUTOCOMPLETADO (TAB) ---
autoload -Uz compinit
compinit

# Cargar fzf-tab (Plugin manual - asegurar que el path sea correcto tras el stow)
if [ -f ~/.zsh-plugins/fzf-tab/fzf-tab.plugin.zsh ]; then
    source ~/.zsh-plugins/fzf-tab/fzf-tab.plugin.zsh
fi

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' completer _expand _complete _correct _approximate

# --- AJUSTES DE KITTY ---
if [ "$TERM" = "xterm-kitty" ]; then
    autoload -Uz add-zsh-hook
    function _tell_kitty_cwd() {
        printf "\e]7;file://%s%s\a" "$HOST" "$PWD"
    }
    add-zsh-hook chpwd _tell_kitty_cwd
    _tell_kitty_cwd
fi

# --- ALIAS Y VARIABLES ---
# PATH unificado y limpio
export PATH="$HOME/DarkArch-DotFiles/bin:$HOME/.local/bin:$(go env GOPATH)/bin:$PATH"

alias ls='ls --color=auto'
alias clean="sudo pacman -Sc && sudo pacman -Rs \$(pacman -Qtdq) && sudo journalctl --vacuum-time=3d && rm -rf ~/.cache/*"
alias target='_target(){ echo "$1" > ~/.config/polybar/target }; _target'
alias untarget='echo "NONE" > ~/.config/polybar/target'
alias mic-off="pactl set-source-mute @DEFAULT_SOURCE@ 1"
alias mic-on="pactl set-source-mute @DEFAULT_SOURCE@ 0"
alias john='/opt/john/run/john'

# --- TRUCO DOBLE ESC PARA SUDO ---
bindkey -M emacs '\e\e' sudo-command-line
bindkey -M viins '\e\e' sudo-command-line
bindkey -M vicmd '\e\e' sudo-command-line

# --- R&D VAULT CONTROL ---

vault-on() {
    local VAULT_PATH="$HOME/.research_vault.img"
    local MAPPER_NAME="rd_workspace"
    local MOUNT_POINT="$HOME/Workspace"

    # 1. Check if device is already mapped
    if [ -e "/dev/mapper/$MAPPER_NAME" ]; then
        echo "[-] Mapping '$MAPPER_NAME' already exists. Cleaning up stale session..."
        
        # Kill processes holding the mount point
        sudo fuser -mk "$MOUNT_POINT" 2>/dev/null
        sleep 1
        
        # Unmount and close mapper
        sudo umount -l "$MOUNT_POINT" 2>/dev/null
        sudo cryptsetup close "$MAPPER_NAME" 2>/dev/null
        
        # Final check
        if [ -e "/dev/mapper/$MAPPER_NAME" ]; then
            echo "[!] Critical Error: Mapper is still locked by the kernel."
            return 1
        fi
    fi

    # 2. Open and Mount
    echo "[+] Opening encrypted vault..."
    if sudo cryptsetup open "$VAULT_PATH" "$MAPPER_NAME"; then
        mkdir -p "$MOUNT_POINT"
        sudo mount "/dev/mapper/$MAPPER_NAME" "$MOUNT_POINT"
        echo "[*] Workspace successfully mounted at $MOUNT_POINT"
        cd "$MOUNT_POINT"
    else
        echo "[!] Failed to unlock vault."
        return 1
    fi
}

vault-off() {
    local MAPPER_NAME="rd_workspace"
    local MOUNT_POINT="$HOME/Workspace"

    echo "[*] Locking Workspace..."

    # 1. Kill potential blockers
    killall gitstatusd 2>/dev/null
    
    # 2. Kill any process inside the mount point
    sudo fuser -mk "$MOUNT_POINT" 2>/dev/null

    # 3. Unmount and Close
    if sudo umount "$MOUNT_POINT"; then
        sudo cryptsetup close "$MAPPER_NAME"
        echo "🔴 [LOCKED] Vault closed and secured."
    else
        echo "⚠️  Mount busy. Escalating to Lazy Unmount..."
        sudo umount -l "$MOUNT_POINT"
        sudo cryptsetup close "$MAPPER_NAME"
        echo "🔒 [LOCKED] Force-closed via Lazy Unmount."
    fi
    
    # Return to home
    cd "$HOME"
}