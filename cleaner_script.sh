#!/bin/bash

# Made by fernandomaroto for EndeavourOS and Portergos

# Adapted from AIS. An excellent bit of code!

# Super ugly command now :(
# If multiples partitions are used
chroot_path=$(lsblk |grep "calamares-root" |awk '{ print $NF }' |sed -e 's/\/tmp\///' -e 's/\/.*$//' |tail -n1)

arch_chroot(){
# Use chroot not arch-chroot because of the way calamares mounts partitions
    chroot /tmp/$chroot_path /bin/bash -c "${1}"
}  

# Anything to be executed outside chroot need to be here.

# Copy any file from live environment to new system

_non_encrypted(){

# Alternative methods
#NEW_USER=$(ls $chroot_path/home |grep -v "lost+found" |)
#local NEW_USER=$(head -n1 $chroot_path/etc/sudoers.d/10-installer | awk '{print $1}')
local NEW_USER=$(cat /tmp/$chroot_path/etc/passwd | grep "/home" |cut -d: -f1 |head -1)
cp -rf /etc/skel/.bashrc /tmp/$chroot_path/home/$NEW_USER/.bashrc
chown -R $NEW_USER:users /tmp/$chroot_path/home/$NEW_USER/.bashrc

}


_copy_files(){

    local _files_to_copy=(

    /etc/os-release
    /etc/lightdm/*
    /etc/sddm.conf.d/kde_settings.conf
    /etc/pacman.d/hooks/lsb-release.hook
    /etc/pacman.d/hooks/os-release.hook
    /etc/lsb-release
    /etc/default/grub

)

    local xx

# Uses the entire file path and copies directly to / mounted point
    for xx in ${_files_to_copy[*]}; do rsync -vaRI $xx /tmp/$chroot_path; done

}

_copy_files

lsblk |grep "crypt" >/dev/null
if [ "$?" != 0 ]; then _non_encrypted; fi

# For chrooted commands edit the script bellow directly
arch_chroot "/usr/bin/chrooted_cleaner_script.sh"
