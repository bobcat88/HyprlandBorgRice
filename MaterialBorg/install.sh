#!/usr/bin/env bash
# =============================================================================
# install.sh — Material You Hyprland setup
# CachyOS / Arch Linux
# Hardware: AMD Ryzen 5 5600X · RX 6800 · 3440×1440@165Hz · FR AZERTY
# Requires: Hyprland ≥ 0.53.0
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_DIR="$HOME/.config/hypr"
BACKUP_DIR="$HOME/.config/hypr.bak.$(date +%Y%m%d_%H%M%S)"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
step()    { echo -e "${CYAN}[STEP]${NC} $*"; }
section() { echo -e "\n${GREEN}══════════════════════════════════════${NC}"; echo -e "${GREEN}  $*${NC}"; echo -e "${GREEN}══════════════════════════════════════${NC}"; }

# Parse flags
INSTALL_HYPRYOU=false
for arg in "$@"; do
    [[ "$arg" == "--with-hypryou" ]] && INSTALL_HYPRYOU=true
done

# =============================================================================
# 0. PREFLIGHT
# =============================================================================
section "Preflight checks"

if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}[ERROR]${NC} Do not run as root." >&2; exit 1
fi

if ! command -v paru &>/dev/null; then
    warn "paru not found — installing from AUR"
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru-build
    (cd /tmp/paru-build && makepkg -si --noconfirm)
    rm -rf /tmp/paru-build
fi
info "paru: $(paru --version | head -1)"

# Check Hyprland version if already installed
if command -v hyprctl &>/dev/null; then
    HYPR_VER=$(hyprctl version 2>/dev/null | grep -oP 'v\d+\.\d+\.\d+' | head -1 || echo "unknown")
    info "Hyprland current: $HYPR_VER (need ≥ 0.53.0 for match: syntax)"
fi

# =============================================================================
# 1. PACMAN PACKAGES
# =============================================================================
section "Installing pacman packages"

PACMAN_PKGS=(
    # Hyprland core (ensure latest — need ≥ 0.53.0)
    hyprland
    hyprutils
    hypridle
    hyprsunset              # blue light filter (material-you autostart)
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

    # Clipboard
    cliphist

    # Screenshot
    grim
    slurp

    # Media
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

    # Qt theming (material-you: QT_QPA_PLATFORMTHEME=qt5ct)
    qt5ct
    qt6ct
    kvantum
    kvantum-qt5

    # GTK (material-you: adw-gtk-theme)
    adw-gtk-theme
    gtk4

    # Python runtime (for hypryou)
    python
    python-gobject
    python-pyvips
    python-pywayland
    python-cairo
    python-pam
    cython
    libgirepository

    # Build tools
    dart-sass

    # System utils
    brightnessctl
    upower
    networkmanager
    imagemagick
    jq
    bc
    socat
)

paru -S --needed --noconfirm "${PACMAN_PKGS[@]}"

# =============================================================================
# 2. AUR PACKAGES — base
# =============================================================================
section "Installing AUR packages (base)"

AUR_BASE=(
    swww                       # animated wallpaper daemon (hypryou integrates with it)
    xcursor-arc-midnight-black # cursor
    xwaylandvideobridge        # screen sharing bridge
    python-materialyoucolor-git # color generation engine
)

paru -S --needed --noconfirm "${AUR_BASE[@]}"

# =============================================================================
# 3. HYPRYOU (optional — the full Material You shell)
# =============================================================================
if [[ "$INSTALL_HYPRYOU" == true ]]; then
    section "Installing hypryou (full Material You shell)"

    warn "hypryou replaces waybar/swaync/rofi with its own GTK4 UI."
    warn "After install: uncomment 'exec-once = hypryou-start' in hyprland.conf"
    warn "              uncomment 'source = ~/.cache/hypryou/colors/...' in hyprland.conf"

    AUR_HYPRYOU=(
        hypryou
        ttf-material-symbols-variable-git
        libastal-bluetooth-git
        libastal-wireplumber-git
    )
    paru -S --needed --noconfirm "${AUR_HYPRYOU[@]}"

    info "hypryou installed. Wallpapers go in ~/Pictures/wallpapers/"
    info "First launch: hypryou-start (or log in to Hyprland)"
else
    section "Skipping hypryou (pass --with-hypryou to install)"
    info "Stack: waybar + swaync + rofi (no dynamic colors without hypryou)"
    info "Dynamic colors available after: ./install.sh --with-hypryou"
fi

# =============================================================================
# 4. GOOGLE SANS FONTS (bundled in the cloned repo)
# =============================================================================
section "Installing Google Sans fonts"

FONT_BASE="$SCRIPT_DIR/../../hyprland-material-you/assets"
FONT_DST="$HOME/.local/share/fonts"

for family in "Google Sans" "Google Sans Display" "Google Sans Text"; do
    src="$FONT_BASE/$family"
    dst="$FONT_DST/$family"
    if [[ -d "$src" ]]; then
        mkdir -p "$dst"
        cp "$src/"*.ttf "$dst/"
        info "Installed: $family"
    else
        warn "$family not found at $src — skipping"
    fi
done
fc-cache -f
info "Font cache refreshed"

# =============================================================================
# 5. BACKUP EXISTING CONFIG
# =============================================================================
section "Backing up existing Hyprland config"

if [[ -d "$HYPR_DIR" ]]; then
    warn "Existing config found — backing up to $BACKUP_DIR"
    cp -r "$HYPR_DIR" "$BACKUP_DIR"
    info "Backup: $BACKUP_DIR"
else
    info "No existing config — fresh install"
fi

# =============================================================================
# 6. DEPLOY CONFIGS
# =============================================================================
section "Deploying configs"

mkdir -p "$HYPR_DIR"

cp "$SCRIPT_DIR/hyprland.conf" "$HYPR_DIR/hyprland.conf"
info "Deployed: hyprland.conf"

cp "$SCRIPT_DIR/hypridle.conf" "$HYPR_DIR/hypridle.conf"
info "Deployed: hypridle.conf"

# Deploy Waybar (MaterialBorg style:Rounded + No Glow)
WAYBAR_CFG="$HOME/.config/waybar"
if [[ -d "$WAYBAR_CFG" ]]; then
    mv "$WAYBAR_CFG" "$WAYBAR_CFG.bak.$(date +%Y%m%d_%H%M%S)"
fi
cp -r "$SCRIPT_DIR/waybar" "$WAYBAR_CFG"
info "Deployed: Waybar config (MaterialBorg + Assimilated Arch)"

# Deploy Rofi
ROFI_CFG="$HOME/.config/rofi"
if [[ -d "$ROFI_CFG" ]]; then
    mv "$ROFI_CFG" "$ROFI_CFG.bak.$(date +%Y%m%d_%H%M%S)"
fi
cp -r "$SCRIPT_DIR/rofi" "$ROFI_CFG"
info "Deployed: Rofi config (Borg Theme)"

# Create hypryou user config dir (harmless even without hypryou)
mkdir -p "$HOME/.config/hypryou"
if [[ ! -f "$HOME/.config/hypryou/settings.json" ]]; then
    # Write sane defaults matching config.py (kb_layout fr, ArcMidnight cursor)
    cat > "$HOME/.config/hypryou/settings.json" << 'EOF'
{
    "input.kb_layout": "fr",
    "input.accel_profile": "flat",
    "input.repeat_rate": 25,
    "input.repeat_delay": 600,
    "cursor.name": "ArcMidnight",
    "cursor.size": 24,
    "appearance.dark_mode": true,
    "appearance.scheme": "tonal_spot",
    "is_24hr_clock": true,
    "blur.enabled": true,
    "blur.xray": true,
    "blur.size": 4,
    "blur.passes": 3,
    "shadow.enabled": true,
    "hyprland.gaps_in": 5,
    "hyprland.gaps_out": 12,
    "hyprland.border_size": 0,
    "hyprland.decoration.rounding": 16,
    "hyprland.decoration.rounding_power": 2.0,
    "hyprsunset.temperature": 4500,
    "idle.ac.lock": 300,
    "idle.ac.dpms": 60,
    "idle.ac.sleep": 0
}
EOF
    info "Created ~/.config/hypryou/settings.json with FR AZERTY + ArcMidnight defaults"
fi

# =============================================================================
# 7. CURSOR SETUP
# =============================================================================
section "Configuring ArcMidnight cursor"

GTK3_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
mkdir -p "$(dirname "$GTK3_SETTINGS")"
if [[ ! -f "$GTK3_SETTINGS" ]]; then
    cat > "$GTK3_SETTINGS" << 'EOF'
[Settings]
gtk-cursor-theme-name=ArcMidnight
gtk-cursor-theme-size=24
gtk-font-name=Google Sans 10
gtk-theme-name=adw-gtk3-dark
gtk-icon-theme-name=Adwaita
EOF
    info "Created $GTK3_SETTINGS"
else
    grep -q "gtk-cursor-theme-name" "$GTK3_SETTINGS" \
        || { echo "gtk-cursor-theme-name=ArcMidnight"; echo "gtk-cursor-theme-size=24"; } >> "$GTK3_SETTINGS"
    info "Updated $GTK3_SETTINGS"
fi

GTK4_SETTINGS="$HOME/.config/gtk-4.0/settings.ini"
mkdir -p "$(dirname "$GTK4_SETTINGS")"
if [[ ! -f "$GTK4_SETTINGS" ]]; then
    cat > "$GTK4_SETTINGS" << 'EOF'
[Settings]
gtk-cursor-theme-name=ArcMidnight
gtk-cursor-theme-size=24
gtk-theme-name=adw-gtk4-dark
EOF
    info "Created $GTK4_SETTINGS"
fi

# Gsettings (for apps that read gnome schema)
gsettings set org.gnome.desktop.interface cursor-theme 'ArcMidnight' 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-size 24               2>/dev/null || true
info "gsettings cursor updated"

mkdir -p "$HOME/.config/environment.d"
cat > "$HOME/.config/environment.d/hyprland-cursor.conf" << 'EOF'
XCURSOR_THEME=ArcMidnight
XCURSOR_SIZE=24
EOF

# =============================================================================
# 8. ADW-GTK DARK THEME LINK (GTK 4 app theming)
# =============================================================================
section "Linking adw-gtk4-dark theme"

GTK4_THEME_DST="$HOME/.config/gtk-4.0/gtk.css"
GTK4_THEME_SRC="/usr/share/themes/adw-gtk4-dark/gtk-4.0/gtk.css"
if [[ -f "$GTK4_THEME_SRC" ]] && [[ ! -f "$GTK4_THEME_DST" ]]; then
    ln -sf "$GTK4_THEME_SRC" "$GTK4_THEME_DST"
    info "Linked adw-gtk4-dark theme"
fi

# =============================================================================
# 9. DIRECTORIES
# =============================================================================
section "Creating required directories"

mkdir -p ~/Pictures/Screenshots
mkdir -p ~/Pictures/wallpapers     # primary (hypryou reads this first)
mkdir -p ~/Pictures/Wallpapers     # alias
mkdir -p ~/wallpaper               # hypryou legacy fallback
info "Wallpaper dirs: ~/Pictures/wallpapers  ~/Pictures/Wallpapers  ~/wallpaper"

# =============================================================================
# 10. ENABLE SERVICES
# =============================================================================
section "Enabling systemd user services"

systemctl --user enable --now pipewire.service       2>/dev/null || true
systemctl --user enable --now pipewire-pulse.service 2>/dev/null || true
systemctl --user enable --now wireplumber.service     2>/dev/null || true
info "Audio services enabled"

# =============================================================================
# 11. BORG EXTRAS (Specialized Tools)
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
# 12. POST-INSTALL NOTES
# =============================================================================
section "Done!"

cat << EOF

  ┌─────────────────────────────────────────────────────────────────┐
  │  Material You Hyprland — setup complete                         │
  └─────────────────────────────────────────────────────────────────┘

  hypryou installed: $INSTALL_HYPRYOU

  Next steps:
  ──────────────────────────────────────────────────────────────────
  1. Add a wallpaper:
       cp your-wallpaper.jpg ~/Pictures/wallpapers/

  2. Verify monitor connector (may not be DP-1):
       hyprctl monitors
     Edit ~/.config/hypr/hyprland.conf → monitor line

  3. Log in to Hyprland from your display manager.

$(if [[ "$INSTALL_HYPRYOU" == true ]]; then
cat << 'HYPRYOU'
  4. HYPRYOU (dynamic colors):
     a. Uncomment in ~/.config/hypr/hyprland.conf:
          source = ~/.cache/hypryou/colors/colors-hyprland.conf
          exec-once = hypryou-start
     b. Log in — hypryou will auto-generate colors from your wallpaper.
     c. Use the hypryou sidebar to change wallpapers live.

  5. Adjust color temperature:
       hyprsunset -t 4000   # warmer
       hyprsunset -t 6500   # daylight / off
HYPRYOU
else
cat << 'NOHYPRYOU'
  4. DYNAMIC COLORS (optional):
     Re-run with --with-hypryou flag:
       ./install.sh --with-hypryou
     Then uncomment two lines in ~/.config/hypr/hyprland.conf:
       source = ~/.cache/hypryou/colors/colors-hyprland.conf
       exec-once = hypryou-start

  5. Static wallpaper (without hypryou):
       swww img ~/Pictures/wallpapers/foo.jpg --transition-type fade
NOHYPRYOU
fi)

  Key bindings:
  ──────────────────────────────────────────────────────────────────
    SUPER+Return / K   terminal (kitty)
    SUPER+D            app launcher (rofi)
    SUPER+F            firefox
    SUPER+E            thunar
    SUPER+A            notifications (swaync)
    SUPER+L            lock screen (swaylock)
    SUPER+Q            close window
    SUPER+G            fullscreen
    SUPER+SHIFT+F      toggle float
    SUPER+S            scratchpad toggle
    SUPER+1..0         switch workspace (AZERTY: & é " ' ( - è _ ç à)
    SUPER+SHIFT+1      move window to workspace
    SUPER+arrows       focus
    SUPER+CTRL+arrows  move window
    SUPER+SHIFT+arrows resize
    Print              screenshot region → clipboard
    SHIFT+Print        screenshot → ~/Pictures/Screenshots/
    SUPER+Print        fullscreen → clipboard

EOF
