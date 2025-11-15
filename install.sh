#!/bin/bash
set -e

echo "================================="
echo "  Sufiarh Hyprland Dotfiles Installer"
echo "================================="

# --------------------------------------------------------
# 0. Install yay if missing
# --------------------------------------------------------
if ! command -v yay &> /dev/null; then
    echo "[0/6] yay not found. Installing yay..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
fi

# --------------------------------------------------------
# 1. Update system
# --------------------------------------------------------
echo "[1/6] Updating system..."
sudo pacman -Syu --noconfirm

# --------------------------------------------------------
# 2. Install packages (pacman + aur)
# --------------------------------------------------------
echo "[2/6] Installing packages..."

if [ ! -f packages.txt ]; then
    echo "ERROR: packages.txt not found!"
    exit 1
fi

# Clean packages list (remove comments & empty lines)
PKGS=$(grep -v "^\s*#" packages.txt | grep -v "^\s*$")

# Pacman official packages (filter yang bukan AUR)
PACMAN_PKGS=$(echo "$PKGS" | grep -v -E "^(wlogout|tofi)$" || true)

# AUR packages
AUR_PKGS=$(echo "$PKGS" | grep -E "^(wlogout|tofi)$" || true)

if [ -n "$PACMAN_PKGS" ]; then
    echo "→ Installing official packages..."
    sudo pacman -S --needed --noconfirm $PACMAN_PKGS
fi

if [ -n "$AUR_PKGS" ]; then
    echo "→ Installing AUR packages..."
    yay -S --needed --noconfirm $AUR_PKGS
fi

# --------------------------------------------------------
# 3. Restore ~/.config
# --------------------------------------------------------
echo "[3/6] Restoring ~/.config..."
mkdir -p ~/.config
rsync -avh .config/ ~/.config/

# --------------------------------------------------------
# 4. Install SDDM themes
# --------------------------------------------------------
echo "[4/6] Installing SDDM themes..."

if [ -d sddm/themes ]; then
    sudo mkdir -p /usr/share/sddm/themes/
    sudo cp -r sddm/themes/* /usr/share/sddm/themes/
fi

echo "[Theme]
Current=chili" | sudo tee /etc/sddm.conf.d/theme.conf

sudo systemctl enable sddm.service

# --------------------------------------------------------
# 5. Enable services
# --------------------------------------------------------
echo "[5/6] Enabling services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth || true

# --------------------------------------------------------
# 6. Done!
# --------------------------------------------------------
echo "================================="
echo " Installation complete!"
echo " Reboot to apply everything."
echo "================================="
