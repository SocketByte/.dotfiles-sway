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
sudo --user=$USER sh -c "cd /yay && makepkg -si"
sudo --user=$USER sh -c "yay --noconfirm -S ly ttf-iosevka ttf-meslo"

pac "sway waybar xorg-xwayland wofi alacritty firefox"

systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable ly.service

echo "MOZ_ENABLE_WAYLAND=1" > /etc/environment

cd /home/$USER/.dotfiles
stow --adopt -vt /home/$USER/.config .config
stow --adopt -vt /home/$USER/.images .images

rm -rf install.sh