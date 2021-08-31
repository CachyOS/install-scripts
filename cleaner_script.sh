#!/bin/bash

# Made by fernandomaroto for CachyOS and Portergos
# Adapted from AIS. An excellent bit of code!
# ISO-NEXT specific cleanup removals and additions (08-2021) @killajoe and @manuel

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
cp -rf /etc/environment /tmp/$chroot_path/etc/environment
#cp -rf /home/liveuser/.gnupg/gpg.conf /tmp/$chroot_path/etc/pacman.d/gnupg/gpg.conf

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

    # /home/liveuser/setup.url contains the URL to personal setup.sh

    if [ -r /home/liveuser/setup.url ] ; then
        local URL="$(cat /home/liveuser/setup.url)"
        if (wget -q -O /home/liveuser/setup.sh "$URL") ; then
            cp /home/liveuser/setup.sh /tmp/$chroot_path/tmp/   # into /tmp/setup.sh of chrooted
        fi
    fi

    # Communicate to chrooted system if
    # - nvidia card is detected
    # - livesession is running nvidia driver

    local nvidia_file=/tmp/$chroot_path/tmp/nvidia-info.bash
    local card=no
    local driver=no
    local lspci="$(lspci -k)"

    if [ -n "$(echo "$lspci" | grep -P 'VGA|3D|Display' | grep -w NVIDIA)" ] ; then
        card=yes
        [ -n "$(lsmod | grep -w nvidia)" ]                                                   && driver=yes
        [ -n "$(echo "$lspci" | grep -wA2 NVIDIA | grep "Kernel driver in use: nvidia")" ]   && driver=yes
    fi
    echo "nvidia_card=$card"     >> $nvidia_file
    echo "nvidia_driver=$driver" >> $nvidia_file
}

_copy_files
