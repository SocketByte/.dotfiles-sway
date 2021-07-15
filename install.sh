#!/bin/bash

# Configuration
USER=user # user name

# The script begins here.
pac() {
  arch-chroot /mnt pacman -Syu --noconfirm --needed $1
}

pac "sudo nano git cmake networkmanager linux-headers openssh neofetch bashtop bat stow"
pac "bluez bluez-utils alsa-utils pipewire pipewire-alsa pipewire-pulse"

arch-chroot /mnt git clone https://aur.archlinux.org/yay.git
arch-chroot /mnt chown -R $USER yay
arch-chroot /mnt cd yay
arch-chroot /mnt su - $USER -c "makepkg -si"
arch-chroot /mnt su - $USER -c "yay -S ly ttf-iosevka ttf-meslo"

pac "sway waybar xorg-xwayland wofi alacritty firefox"

arch-chroot /mnt systemctl enable NetworkManager.service
arch-chroot /mnt systemctl enable bluetooth.service
arch-chroot /mnt systemctl enable ly.service

echo "MOZ_ENABLE_WAYLAND=1" > /mnt/etc/environment

arch-chroot /mnt git clone https://github.com/SocketByte/dotfiles