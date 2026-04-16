#!/usr/bin/env bash
# =============================================================================
# install.sh — ilyamiro-style Hyprland setup
# CachyOS / Arch Linux
# Hardware: AMD Ryzen 5 5600X · RX 6800 · 3440×1440@165Hz · FR AZERTY
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_DIR="$HOME/.config/hypr"
BACKUP_DIR="$HOME/.config/hypr.bak.$(date +%Y%m%d_%H%M%S)"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
section() { echo -e "\n${GREEN}══════════════════════════════════════${NC}"; echo -e "${GREEN}  $*${NC}"; echo -e "${GREEN}══════════════════════════════════════${NC}"; }

# =============================================================================
# 0. PREFLIGHT
# =============================================================================
section "Preflight checks"

if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}[ERROR]${NC} Do not run as root." >&2; exit 1
fi

# Ensure paru is available (CachyOS ships it; install from AUR otherwise)
if ! command -v paru &>/dev/null; then
    warn "paru not found — installing from AUR"
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru-build
    (cd /tmp/paru-build && makepkg -si --noconfirm)
    rm -rf /tmp/paru-build
fi
info "paru: $(paru --version | head -1)"

# =============================================================================
# 0. BORG / ILYAMIRO UPSTREAM
# =============================================================================
section "Upstream Assimilation"

# Call the remote Ilyamiro script for base packages and system setup
# User will manage TUI choices manually
info "Calling Ilyamiro remote install script..."
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ilyamiro/imperative-dots/master/install.sh)" || warn "Upstream script returned error, continuing with local setup."

# =============================================================================
# 1. PACMAN PACKAGES
# =============================================================================
section "Installing pacman packages"

PACMAN_PKGS=(
    # Hyprland core
    hyprland
    hyprutils
    hypridle
    hyprpaper           # fallback wallpaper daemon (swww preferred, see AUR)
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    xdg-desktop-portal
    xdg-utils

    # Wayland essentials
    wayland
    wayland-protocols
    wl-clipboard
    qt5-wayland
    qt6-wayland
    glfw-wayland

    # Bar / notifications / launcher
    waybar
    rofi-wayland
    swaync

    # Lock screen
    swaylock

    # Terminal
    kitty

    # File manager
    thunar
    thunar-archive-plugin
    file-roller
    gvfs

    # Browser
    firefox

    # System tray / network / bluetooth
    network-manager-applet
    blueman
    polkit-gnome

    # Clipboard manager
    cliphist

    # Screenshot
    grim
    slurp

    # Media control
    playerctl
    wireplumber
    pipewire
    pipewire-alsa
    pipewire-pulse

    # AMD VAAPI hardware decode
    libva-mesa-driver
    mesa-vdpau
    vulkan-radeon

    # Fonts
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
    ttf-liberation

    # Qt theming
    qt5ct
    qt6ct

    # Utilities
    brightnessctl
    imagemagick
    jq
    bc
    socat
)

paru -S --needed --noconfirm "${PACMAN_PKGS[@]}"

# =============================================================================
# 2. AUR PACKAGES
# =============================================================================
section "Installing AUR packages"

AUR_PKGS=(
    swww                      # ilyamiro's wallpaper daemon (animated transitions)
    xcursor-arc-midnight-black # ilyamiro's cursor theme
    xwaylandvideobridge        # screen sharing in Discord / Meet / Teams
)

paru -S --needed --noconfirm "${AUR_PKGS[@]}"

# =============================================================================
# 3. GOOGLE SANS FONTS (Material UI — optional, nice to have)
# =============================================================================
section "Installing Google Sans fonts"

FONT_DIR="$HOME/.local/share/fonts/GoogleSans"
if [[ ! -d "$FONT_DIR" ]]; then
    mkdir -p "$FONT_DIR"
    cp -r "$SCRIPT_DIR/../../hyprland-material-you/assets/Google Sans/." "$FONT_DIR/" 2>/dev/null \
        || warn "Google Sans not found in sibling repo — skipping"
    fc-cache -f
    info "Google Sans fonts installed to $FONT_DIR"
else
    info "Google Sans fonts already present"
fi

# =============================================================================
# 4. BACKUP EXISTING CONFIG
# =============================================================================
section "Backing up existing Hyprland config"

if [[ -d "$HYPR_DIR" ]]; then
    warn "Existing config found — backing up to $BACKUP_DIR"
    cp -r "$HYPR_DIR" "$BACKUP_DIR"
    info "Backup done: $BACKUP_DIR"
else
    info "No existing config — fresh install"
fi

# =============================================================================
# 5. DEPLOY CONFIGS
# =============================================================================
section "Deploying configs"

mkdir -p "$HYPR_DIR"

cp "$SCRIPT_DIR/hyprland.conf" "$HYPR_DIR/hyprland.conf"
info "Deployed: hyprland.conf"

cp "$SCRIPT_DIR/hypridle.conf" "$HYPR_DIR/hypridle.conf"
info "Deployed: hypridle.conf"

# Deploy Waybar
WAYBAR_CFG="$HOME/.config/waybar"
if [[ -d "$WAYBAR_CFG" ]]; then
    mv "$WAYBAR_CFG" "$WAYBAR_CFG.bak.$(date +%Y%m%d_%H%M%S)"
fi
cp -r "$SCRIPT_DIR/waybar" "$WAYBAR_CFG"
info "Deployed: Waybar config (Assimilated Arch)"

# Deploy Rofi
ROFI_CFG="$HOME/.config/rofi"
if [[ -d "$ROFI_CFG" ]]; then
    mv "$ROFI_CFG" "$ROFI_CFG.bak.$(date +%Y%m%d_%H%M%S)"
fi
cp -r "$SCRIPT_DIR/rofi" "$ROFI_CFG"
info "Deployed: Rofi config (Borg Theme)"

# =============================================================================
# 6. CURSOR SETUP
# =============================================================================
section "Configuring ArcMidnight cursor"

# GTK 3
GTK3_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
mkdir -p "$(dirname "$GTK3_SETTINGS")"
if [[ ! -f "$GTK3_SETTINGS" ]]; then
    cat > "$GTK3_SETTINGS" << 'EOF'
[Settings]
gtk-cursor-theme-name=ArcMidnight
gtk-cursor-theme-size=24
gtk-font-name=JetBrains Mono 10
EOF
    info "Created $GTK3_SETTINGS"
else
    # Update existing (non-destructive)
    if ! grep -q "gtk-cursor-theme-name" "$GTK3_SETTINGS"; then
        echo "gtk-cursor-theme-name=ArcMidnight" >> "$GTK3_SETTINGS"
        echo "gtk-cursor-theme-size=24"          >> "$GTK3_SETTINGS"
        info "Updated cursor in $GTK3_SETTINGS"
    else
        info "$GTK3_SETTINGS already has cursor config"
    fi
fi

# GTK 4
GTK4_SETTINGS="$HOME/.config/gtk-4.0/settings.ini"
mkdir -p "$(dirname "$GTK4_SETTINGS")"
if [[ ! -f "$GTK4_SETTINGS" ]]; then
    cat > "$GTK4_SETTINGS" << 'EOF'
[Settings]
gtk-cursor-theme-name=ArcMidnight
gtk-cursor-theme-size=24
EOF
    info "Created $GTK4_SETTINGS"
fi

# Hyprland cursor env (already in hyprland.conf — also set in index for DMs)
mkdir -p "$HOME/.config/environment.d"
cat > "$HOME/.config/environment.d/hyprland-cursor.conf" << 'EOF'
XCURSOR_THEME=ArcMidnight
XCURSOR_SIZE=24
EOF
info "Cursor env written to environment.d"

# =============================================================================
# 7. DIRECTORIES
# =============================================================================
section "Creating required directories"

mkdir -p ~/Pictures/Screenshots
mkdir -p ~/Pictures/wallpapers
mkdir -p ~/Pictures/Wallpapers   # alias used by some tools
info "Created ~/Pictures/{Screenshots,wallpapers,Wallpapers}"

# =============================================================================
# 8. ENABLE SERVICES
# =============================================================================
section "Enabling systemd user services"

systemctl --user enable --now pipewire.service       2>/dev/null || true
systemctl --user enable --now pipewire-pulse.service 2>/dev/null || true
systemctl --user enable --now wireplumber.service     2>/dev/null || true
info "Audio services enabled"

# =============================================================================
# 9. BORG EXTRAS (Specialized Tools)
# =============================================================================
section "Installing Borg Extras"

DEP_DIR="$SCRIPT_DIR/../dependencies"

# Kando (Radial Menu) — Using latest beta for Arch compatibility
step "Installing Kando..."
if command -v kando &>/dev/null; then
    info "Kando already installed"
else
    paru -S --needed --noconfirm kando-bin || warn "Kando installation failed"
fi

# Sherlock (App Launcher)
step "Installing Sherlock..."
if [[ -d "$DEP_DIR/sherlock" ]]; then
    (cd "$DEP_DIR/sherlock" && cargo build --release && sudo cp target/release/sherlock /usr/local/bin/)
    info "Sherlock built and installed"
fi

# Hyprmod (Config Manager)
step "Installing Hyprmod..."
if [[ -d "$DEP_DIR/hyprmod" ]]; then
    (cd "$DEP_DIR/hyprmod" && go build -o hyprmod && sudo cp hyprmod /usr/local/bin/)
    info "Hyprmod built and installed"
fi

# HyprWhspr (Voice Notes)
step "Installing HyprWhspr..."
if [[ -d "$DEP_DIR/hyprwhspr" ]]; then
    (cd "$DEP_DIR/hyprwhspr" && cargo build --release && sudo cp target/release/hyprwhspr /usr/local/bin/)
    info "HyprWhspr built and installed"
fi

# AI Quota Waybar
step "Installing AI Quota Waybar..."
if [[ -d "$DEP_DIR/ai-quota-waybar" ]]; then
    (cd "$DEP_DIR/ai-quota-waybar" && sudo cp ai-quota-waybar.py /usr/local/bin/ai-quota-waybar && sudo chmod +x /usr/local/bin/ai-quota-waybar)
    info "AI Quota script installed"
fi

# =============================================================================
# 10. POST-INSTALL NOTES
# =============================================================================
section "Done!"

cat << 'EOF'

  Next steps:
  ──────────────────────────────────────────────────────────
  1. Set a wallpaper:
       swww img ~/Pictures/wallpapers/your-wallpaper.jpg \
         --transition-type fade --transition-duration 1

  2. Verify monitor name (may not be DP-1):
       hyprctl monitors
     Then edit ~/.config/hypr/hyprland.conf line 12.

  3. Log out and select Hyprland from your display manager,
     or start it directly with:   Hyprland

  4. Key bindings:
       SUPER+Return    terminal (kitty)
       SUPER+D         app launcher (rofi)
       SUPER+F         firefox
       SUPER+E         thunar
       SUPER+A         notifications (swaync)
       SUPER+L         lock screen (swaylock)
       SUPER+Q         close window
       SUPER+1..0      switch workspace (AZERTY: &éà"'(-è_ç)
       SUPER+SHIFT+1   move window to workspace
       SUPER+arrows    focus
       SUPER+CTRL+arr  move window
       SUPER+SHIFT+arr resize
       Print           screenshot region → clipboard
       SHIFT+Print     screenshot → ~/Pictures/Screenshots/

  5. Optional — easyeffects audio processing:
       paru -S easyeffects
     Then uncomment exec-once line in hyprland.conf.

EOF
