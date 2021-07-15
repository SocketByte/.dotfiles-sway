#!/usr/bin/env bash
set -e

# Configuration
#  Partitioning
DEVICE="/dev/nvme0n1"
NVME=yes
FIRMWARE_MODE=auto # uefi, bios, auto
SWAP_SIZE=8192MiB

#  Time and date
TIMEZONE="Europe/Warsaw"

#  Network and connectivity
REFLECTOR=yes
REFLECTOR_COUNTRY="Poland"

BLUETOOTH=yes
BLUETOOTH_AUDIO=yes

#  Graphics Drivers
DRIVER="nouveau" # nouveau, amd, nvidia, nvidia-dkms, intel

#  Kernel
# Be aware that "nvidia" package won't work with custom kernels, use "nvidia-dkms" instead.
KERNEL="linux-zen" # linux, linux-hardened, linux-zen, linux-lts

#  Locale
LOCALE="en_US.UTF-8"
LOCALE_GEN="en_US.UTF-8 UTF-8"
KEYMAP="pl"

#  Users
USER_NAME=user
USER_PASSWORD=test
ROOT_PASSWORD=test

#  Bootloader
BOOTLOADER="grub"

# Colors
BLUE='\033[1;34m'
NC='\033[0m'

pac() {
  arch-chroot /mnt pacman -Syu --noconfirm --needed $1
}

echo -e "\n${BLUE}Arch Script Installer"
echo -e "   ${NC}by SocketByte\n"
read -p "Do you want to continue? [y/N] " yn
case $yn in
  [Yy]*)
    ;;
  Nn]*)
    exit
    ;;
  *)
    exit
    ;;
esac
echo -e "\n"

# Check for UEFI firmware mode, otherwise fallback to legacy BIOS
if [ -e "/sys/firmware/efi/efivars" ]; then
  PARTITION_MODE=uefi
else
  PARTITION_MODE=bios
fi

loadkeys $KEYMAP
timedatectl set-ntp true
timedatectl set-timezone $TIMEZONE

if [ -d /mnt/boot ]; then
  umount /mnt/boot
  umount /mnt
fi
for v_partition in $(parted -s ${DEVICE} print|awk '/^ / {print $1}')
do
   parted -s $DEVICE rm ${v_partition}
done

PART_PRIMARY=""
if [ $PARTITION_MODE = uefi ]; then
  parted -s $DEVICE "mklabel gpt mkpart efi fat32 2048B 261MiB mkpart swap linux-swap 261MiB $SWAP_SIZE mkpart primary ext4 $SWAP_SIZE 100% set 1 esp on"
  if [ $NVME = yes ]; then
    PART_PRIMARY="${DEVICE}p3"
  else
    PART_PRIMARY="${DEVICE}3"
  fi
else
  parted -s $DEVICE "mklabel msdos mkpart primary ext4 4MiB 512MiB mkpart primary ext4 512MiB 100% set 1 boot on"
  if [ $NVME = yes ]; then
    PART_PRIMARY="${DEVICE}p2"
  else
    PART_PRIMARY="${DEVICE}2"
  fi
fi
if [ $NVME = yes ]; then
  PART_BOOT="${DEVICE}p1"
  PART_SWAP="${DEVICE}p2"
else
  PART_BOOT="${DEVICE}1"
  PART_SWAP="${DEVICE}2"
fi

mkfs.fat -F32 $PART_BOOT

if [ $PARTITION_MODE = uefi ]; then
  mkswap $PART_SWAP
fi

mkfs.ext4 $PART_PRIMARY

mount $PART_PRIMARY /mnt

if [ $PARTITION_MODE = uefi ]; then
  swapon $PART_SWAP
fi

if [ $REFLECTOR = yes ]; then
  pacman -Sy --noconfirm --needed "reflector"
  reflector --country $REFLECTOR_COUNTRY --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
fi

pacstrap /mnt base base-devel $KERNEL linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
arch-chroot /mnt hwclock --systohc

echo "${LOCALE_GEN}" > /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=${LOCALE}" > /mnt/etc/locale.conf
echo "KEYMAP=${KEYMAP}" > /mnt/etc/vconsole.conf

echo "archlinux" > /mnt/etc/hostname
echo "127.0.0.1 localhost\n::1       localhost\n127.0.1.1 archlinux.localdomain archlinux" > /mnt/etc/hosts

case $DRIVER in
  "nouveau")
    pac "mesa"
    ;;
  "nvidia")
    pac "nvidia"
    ;;
  "nvidia-dkms")
    pac "nvidia-dkms"
    ;;
  "amd")
    pac "mesa vulkan-radeon xf86-video-amdgpu libva-mesa-driver mesa-vdpau"
    ;;
  "intel")
    pac "mesa vulkan-intel xf86-video-intel"
    ;;
esac

printf "$ROOT_PASSWORD\n$ROOT_PASSWORD" | arch-chroot /mnt passwd

arch-chroot /mnt useradd -m $USER_NAME

printf "$USER_PASSWORD\n$USER_PASSWORD" | arch-chroot /mnt passwd $USER_NAME

echo "${USER_NAME} ALL=(ALL) ALL" >> /mnt/etc/sudoers

pac "grub efibootmgr"

if [ $PARTITION_MODE = uefi ]; then
  mkdir /mnt/boot/efi
  arch-chroot /mnt mount ${PART_BOOT} /boot/efi
  arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi
else
  arch-chroot /mnt grub-install --target=i386-pc ${DEVICE}
fi

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

arch-chroot /mnt mkinitcpio -P

# Continue the installation.
./install.sh