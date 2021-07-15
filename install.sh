#!/bin/bash

# Configuration
USER_NAME=user # user name

# The script begins here.
pac() {
  pacman -Syu --noconfirm --needed $1
}

pac "sudo nano git cmake networkmanager linux-headers openssh neofetch bashtop bat stow"
pac "bluez bluez-utils alsa-utils pipewire pipewire-alsa pipewire-pulse"

git clone https://aur.archlinux.org/yay.git
chown -R $USER_NAME yay
sudo --user=$USER_NAME sh -c "cd /yay && makepkg -si"
sudo --user=$USER_NAME sh -c "yay --noconfirm -S ly ttf-iosevka ttf-meslo"

pac "sway waybar xorg-xwayland wofi alacritty firefox"

systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable ly.service

echo "MOZ_ENABLE_WAYLAND=1" > /etc/environment

cd /home/$USER_NAME/.dotfiles
stow --adopt -vt /home/$USER_NAME/.config .config
stow --adopt -vt /home/$USER_NAME/.images .images

rm -rf install.sh