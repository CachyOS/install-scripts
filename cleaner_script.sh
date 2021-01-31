#!/bin/bash

# Made by fernandomaroto for EndeavourOS and Portergos

# Adapted from AIS. An excellent bit of code!

if [ -f /tmp/chrootpath.txt ]
then 
    chroot_path=$(cat /tmp/chrootpath.txt |sed 's/\/tmp\///')
else 
    chroot_path=$(lsblk |grep "calamares-root" |awk '{ print $NF }' |sed -e 's/\/tmp\///' -e 's/\/.*$//' |tail -n1)
fi

if [ -z "$chroot_path" ] ; then
    echo "Fatal error: cleaner_script.sh: chroot_path is empty!"
fi

if [ -f /tmp/new_username.txt ]
then
    NEW_USER=$(cat /tmp/new_username.txt)
else
    #NEW_USER=$(compgen -u |tail -n -1)
    NEW_USER=$(cat /tmp/$chroot_path/etc/passwd | grep "/home" |cut -d: -f1 |head -1)
fi

arch_chroot(){
# Use chroot not arch-chroot because of the way calamares mounts partitions
    chroot /tmp/$chroot_path /bin/bash -c "${1}"
}  

# Anything to be executed outside chroot need to be here.

# Copy any file from live environment to new system

cp -rf /etc/skel/.bashrc /tmp/$chroot_path/home/$NEW_USER/.bashrc

_copy_files(){
    local config_file

    if [ -x /tmp/$chroot_path/usr/bin/sddm ] ; then
        # Fetch sddm (Qt-based) config.
        # This is for online install only, because offline install is set to use lightdm.

        config_file=/etc/sddm.conf.d/kde_settings.conf

        echo "====> Fetching DM config file $config_file"

        local qt_sddm_config=https://raw.githubusercontent.com/endeavouros-team/install-scripts/master/sddm.conf.d/kde_settings.conf
        mkdir -p $(dirname $config_file)
        wget -q --timeout=10 -O $config_file $qt_sddm_config || {
            echo "Error: fetching sddm config failed!"
            return
        }

        echo "====> Copying DM config file $config_file to target"

        rsync -vaRI $config_file /tmp/$chroot_path          # Uses the entire file path and copies directly to / mounted point:
    fi

    if [ -x /tmp/$chroot_path/usr/bin/lightdm ] ; then        
        config_file=/etc/lightdm/lightdm-gtk-greeter.conf   # this file is already in the ISO, no need to fetch

        echo "====> Copying DM config file $config_file to target"

        rsync -vaRI $config_file /tmp/$chroot_path          # Uses the entire file path and copies directly to / mounted point:
    fi

    local file=/usr/lib/endeavouros-release
    if [ -r $file ] ; then
        if [ ! -r /tmp/$chroot_path$file ] ; then
            echo "====> Copying $file to target"
            rsync -vaRI $file /tmp/$chroot_path
        fi
    else
        echo "Error: file $file does not exist, copy failed!"
        return
    fi

    # /etc/os-release /etc/lsb-release removed, using sed now at chrooted script
    # /etc/default/grub # Removed from above since cleaner scripts are moved to last step at calamares
    # https://forum.endeavouros.com/t/calamares-3-2-24-needs-testing/4941/37
    # /etc/pacman.d/hooks/lsb-release.hook
    # /etc/pacman.d/hooks/os-release.hook
}

_copy_files

# For chrooted commands edit the script bellow directly
arch_chroot "/usr/bin/chrooted_cleaner_script.sh"
