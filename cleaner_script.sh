#!/bin/bash

# Made by fernandomaroto for EndeavourOS and Portergos

# Adapted from AIS. An excellent bit of code!

chroot_path=$(lsblk |grep "/tmp/calamares-root" |grep -v "efi" |awk '{ print $7 }')

arch_chroot(){
# Use chroot not arch-chroot because of the way calamares mounts partitions
    chroot $chroot_path /bin/bash -c "${1}"
}  

# Anything to be executed outside chroot need to be here.

# Copy any file from live environment to new system

local _files_to_copy=(

/etc/os-release
/etc/lightdm/*
/etc/sddm.conf.d/kde_settings.conf


)

local xx

for xx in ${_files_to_copy[*]}; do rsync -vaRI $xx $chroot_path; done

#cp -f /etc/os-release $chroot_path/etc/os-release
#cp -rf /etc/lightdm $chroot_path/etc
#cp -rf /etc/sddm.conf $chroot_path/etc
#rsync -vaRI /etc/os-release /etc/lightdm/* /etc/sddm.conf.d/kde_settings.conf $chroot_path

# For chrooted commands edit the script bellow directly
arch_chroot "/usr/bin/chrooted_cleaner_script.sh"
