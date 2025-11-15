#!/bin/bash
set -e

echo "================================="
echo "  Sufiarh Hyprland Dotfiles Installer"
echo "================================="

# --------------------------------------------------------
# 1. Update system
# --------------------------------------------------------
echo "[1/6] Updating system..."
sudo pacman -Syu --noconfirm

# --------------------------------------------------------
# 2. Install pacman packages
# --------------------------------------------------------
echo "[2/6] Installing packages (pacman)..."

if [ ! -f packages.txt ]; then
    echo "ERROR: packages.txt not found!"
    exit 1
fi

# bagian pacman
PKGS=$(grep -v "^\s*#" packages.txt | grep -v "^\s*$" | grep -E "^(pipewire|firefox|...)$")
sudo pacman -S --needed --noconfirm $PKGS

# bagian AUR
AUR_PKGS=$(grep -v "^\s*#" packages.txt | grep -v "^\s*$" | grep -E "^(wlogout|tofi)$")
yay -S --needed --noconfirm $AUR_PKGS


# --------------------------------------------------------
# 3. Restore dotfiles (~/.config)
# --------------------------------------------------------
echo "[3/6] Restoring ~/.config..."

mkdir -p ~/.config
rsync -avh .config/ ~/.config/

# --------------------------------------------------------
# 4. Restore SDDM themes
# --------------------------------------------------------
echo "[4/6] Restoring SDDM theme..."

if [ -d sddm/themes ]; then
    sudo mkdir -p /usr/share/sddm/themes/
    sudo cp -r sddm/themes/* /usr/share/sddm/themes/
fi

# set theme to chili
echo "[Theme]
Current=chili" | sudo tee /etc/sddm.conf.d/theme.conf

# enable display manager
sudo systemctl enable sddm.service

# --------------------------------------------------------
# 5. Enable services
# --------------------------------------------------------
echo "[5/6] Enabling core services..."

sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth || true

# --------------------------------------------------------
# 6. Final
# --------------------------------------------------------
echo "================================="
echo " Installation complete!"
echo " Reboot to apply everything."
echo "================================="
