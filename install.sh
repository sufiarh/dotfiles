#!/bin/bash
set -e

echo "================================="
echo "  Sufiarh Hyprland Dotfiles Installer"
echo "================================="


# --------------------------------------------------------
# 0. Ensure yay exists
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

# Clean list
PKGS=$(grep -v "^\s*#" packages.txt | grep -v "^\s*$")

# Packages that are from AUR only
AUR_ONLY="wlogout tofi"

PACMAN_PKGS=$(echo "$PKGS" | grep -v -E "$(echo $AUR_ONLY | sed 's/ /|/g')" || true)
AUR_PKGS=$(echo "$PKGS"   | grep -E "$(echo $AUR_ONLY | sed 's/ /|/g')" || true)


# --------------------------------------------------------
# 2A. Prevent conflicts (fix wlogout-git conflict)
# --------------------------------------------------------
if pacman -Q wlogout-git &>/dev/null; then
    echo "⚠ Removing conflicting package: wlogout-git"
    yay -R --noconfirm wlogout-git
fi


# --------------------------------------------------------
# 2B. Install pacman packages
# --------------------------------------------------------
if [ -n "$PACMAN_PKGS" ]; then
    echo "→ Installing official packages..."
    sudo pacman -S --needed --noconfirm $PACMAN_PKGS
fi


# --------------------------------------------------------
# 2C. Install aur packages
# --------------------------------------------------------
if [ -n "$AUR_PKGS" ]; then
    echo "→ Installing AUR packages..."
    yay -S --needed --noconfirm $AUR_PKGS
fi


# --------------------------------------------------------
# 3. Restore ~/.config
# --------------------------------------------------------
echo "[3/6] Restoring ~/.config..."

sudo pacman -S --needed --noconfirm rsync

mkdir -p ~/.config
rsync -avh .config/ ~/.config/


# --------------------------------------------------------
# 4. Install SDDM theme
# --------------------------------------------------------
echo "[4/6] Installing SDDM theme..."

if [ -d sddm/themes ]; then
    sudo mkdir -p /usr/share/sddm/themes/
    sudo cp -r sddm/themes/* /usr/share/sddm/themes/
fi

sudo mkdir -p /etc/sddm.conf.d
echo "[Theme]
Current=chili" | sudo tee /etc/sddm.conf.d/theme.conf

sudo systemctl enable sddm.service


# --------------------------------------------------------
# 5. Enable services
# --------------------------------------------------------
echo "[5/6] Enabling services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth.service || true


# --------------------------------------------------------
# 6. Finish
# --------------------------------------------------------
echo "================================="
echo " Installation complete!"
echo " Reboot to apply everything."
echo "================================="
