#!/bin/bash

# Configuration
USER=user # user name

# The script begins here.
pac() {
  pacman -Syu --noconfirm --needed $1
}

pac "sudo nano git cmake networkmanager linux-headers openssh neofetch bashtop bat stow"
pac "bluez bluez-utils alsa-utils pipewire pipewire-alsa pipewire-pulse"

git clone https://aur.archlinux.org/yay.git
chown -R $USER yay
cd yay
su - $USER -c "makepkg -si"
su - $USER -c "yay -S ly ttf-iosevka ttf-meslo"

pac "sway waybar xorg-xwayland wofi alacritty firefox"

systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable ly.service

echo "MOZ_ENABLE_WAYLAND=1" > /etc/environment

git clone https://github.com/SocketByte/dotfiles
cd /dotfiles
stow --adopt -vt ~ *