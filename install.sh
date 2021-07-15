#!/bin/bash
set -e

# Configuration
USER_NAME=user # user name

EXTENSIONS=(
rocketseat.theme-omni
ms-vscode.cpptools
esbenp.prettier-vscode
dbaeumer.vscode-eslint
golang.go
ms-vscode.cmake-tools
steoates.autoimport
)

# The script begins here.
pac() {
  pacman -Syu --noconfirm --needed $1
}

# Utilities
pac "sudo nano git cmake networkmanager linux-headers noto-fonts-emoji openssh neofetch bashtop bat stow zsh wget wl-clipboard"
pac "bluez bluez-utils alsa-utils pipewire pipewire-alsa pipewire-pulse blueberry"

# Yay, fonts and other AUR tools
git clone https://aur.archlinux.org/yay.git
chown -R $USER_NAME yay
sudo --user=$USER_NAME sh -c "cd /yay && makepkg -si"
sudo --user=$USER_NAME sh -c "yay --noconfirm -S ly ttf-iosevka ttf-meslo visual-studio-code-bin via-bin"

# Sway & desktop tools
pac "sway waybar slurp grim xorg-xwayland wofi alacritty firefox telegram-desktop discord"

# Services
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable ly.service

# Environment
echo "MOZ_ENABLE_WAYLAND=1\nLIBSEAT_BACKEND=logind" > /etc/environment

# Zsh + Oh My Zsh
export RUNZSH=no
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# Dotfiles symlink farm
cd /home/$USER_NAME/.dotfiles
mkdir -p /home/$USER_NAME/.config
mkdir -p /home/$USER_NAME/.images
stow --adopt -vt /home/$USER_NAME/.config .config
stow --adopt -vt /home/$USER_NAME/.images .images
stow --adopt -vt /home/$USER_NAME zsh

# VSCode extensions
for i in ${EXTENSIONS[@]}; do
  sudo --user=$USER_NAME sh -c "code --force --install-extension $i"
done

# Cleaning up and rebooting
rm -rf /install.sh

echo "Script has finished. Please reboot your PC using 'reboot' command."
exit
