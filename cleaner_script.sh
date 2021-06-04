#!/bin/bash

# Made by fernandomaroto for EndeavourOS and Portergos

# Adapted from AIS. An excellent bit of code!
# Anything to be executed outside chroot need to be here.

# modified to run with common calamares shelprocess module specifications (joekamprad 4.6.2021 calamares-next) 

# Copy any file from live environment to new system

cp -rf /etc/skel/.bashrc @@ROOT@@/home/@@USER@@/.bashrc
cp -rf /etc/environment @@ROOT@@/etc/environment

_copy_files(){
    local config_file

    if [ -x @@ROOT@@/usr/bin/sddm ] ; then
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

        rsync -vaRI $config_file @@ROOT@@          # Uses the entire file path and copies directly to / mounted point:
    fi

    if [ -x @@ROOT@@/usr/bin/lightdm ] ; then        
        config_file=/etc/lightdm/lightdm-gtk-greeter.conf   # this file is already in the ISO, no need to fetch

        echo "====> Copying DM config file $config_file to target"

        rsync -vaRI $config_file @@ROOT@@          # Uses the entire file path and copies directly to / mounted point:
    fi

    local file=/usr/lib/endeavouros-release
    if [ -r $file ] ; then
        if [ ! -r @@ROOT@@$file ] ; then
            echo "====> Copying $file to target"
            rsync -vaRI $file @@ROOT@@
        fi
    else
        echo "Error: file $file does not exist, copy failed!"
        return
    fi
    
    # /home/liveuser/setup.url contains the URL to personal setup.sh

    if [ -r /home/liveuser/setup.url ] ; then
        local URL="$(cat /home/liveuser/setup.url)"
        if (wget -q -O /home/liveuser/setup.sh "$URL") ; then
            cp /home/liveuser/setup.sh @@ROOT@@/tmp/   # into /tmp/setup.sh of chrooted
        fi
    fi

    # Communicate to chrooted system if
    # - nvidia card is detected
    # - livesession is running nvidia driver

    local nvidia_file=@@ROOT@@/tmp/nvidia-info.bash
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


    # /etc/os-release /etc/lsb-release removed, using sed now at chrooted script
    # /etc/default/grub # Removed from above since cleaner scripts are moved to last step at calamares
    # https://forum.endeavouros.com/t/calamares-3-2-24-needs-testing/4941/37
    # /etc/pacman.d/hooks/lsb-release.hook
    # /etc/pacman.d/hooks/os-release.hook
}

_copy_files

# For chrooted commands edit the chrooted_cleaner_script.sh directly
