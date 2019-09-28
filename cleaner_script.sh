#!/bin/bash

# New version of cleaner_script
# Made by @fernandomaroto and @manuel 

NEW_USER=$(cat /etc/passwd | grep "/home" |cut -d: -f1 |head -1)

# Any failed command will just be skiped, error message may pop up but won't crash the install process

# Net-install creates the file /tmp/run_once in live environment (need to be transfered to installed system) so it can be used to detect install option


_check_internet_connection(){
    ping -c 1 8.8.8.8 >& /dev/null   # ping Google's address
}

_arch_news_latest_headline(){
    # gets the latest Arch news headline for 'kalu' config file news.conf
    local info=$(mktemp)
    wget -q -T 10 -O $info https://www.archlinux.org/ && \
        { grep 'title="View full article:' $info | sed -e 's|&gt;|>|g' -e 's|^.*">[ ]*||' -e 's|</a>$||' | head -n 1 ; }
    rm -f $info
}

_config_for_app(){
    # handle configs for apps here; called from distro specific function

    local app="$1"    # name of the app

    case "$app" in
        kalu)
            mkdir -p /etc/skel/.config/kalu
            printf "Last=" >> /etc/skel/.config/kalu/news.conf
            _arch_news_latest_headline >> /etc/skel/.config/kalu/news.conf
            ;;
        update-mirrorlist)
            test -x /usr/bin/$app && {
                /usr/bin/$app
            }
            ;;
        # add other apps here!
        *)
            ;;
    esac
}

_vbox(){

    # Detects if running in vbox
    # packages must be in this order otherwise guest-utils pulls dkms, which takes longer to be installed
    local _vbox_guest_packages=(virtualbox-guest-modules-arch virtualbox-guest-utils)   
    local xx

    lspci | grep -i "virtualbox" >/dev/null
    if [[ $? == 0 ]]
    then
        # If using net-install detect VBox and install the packages
        if [ -f /tmp/run_once ]                  
        then
            for xx in ${_vbox_guest_packages[*]}
            do pacman -S $xx --noconfirm
            done
        fi   
        : 
    else
        for xx in ${_vbox_guest_packages[*]} ; do
            test -n "$(pacman -Q $xx 2>/dev/null)" && pacman -Rnsdd $xx --noconfirm
        done
        rm -f /usr/lib/modules-load.d/virtualbox-guest-dkms.conf
    fi
}

_common_systemd(){
    local _systemd_enable=(NetworkManager vboxservice org.cups.cupsd avahi-daemon gdm lightdm sddm)   
    local _systemd_disable=(multi-user.target pacman-init)           

    local xx
    for xx in ${_systemd_enable[*]}; do systemctl enable -f $xx; done

    local yy
    for yy in ${_systemd_disable[*]}; do systemctl disable -f $yy; done
}

_sed_stuff(){

    # Journal for offline. Turn volatile (for iso) into a real system.
    sed -i 's/volatile/auto/g' /etc/systemd/journald.conf 2>>/tmp/.errlog
    sed -i 's/.*pam_wheel\.so/#&/' /etc/pam.d/su
}

_clean_archiso(){

    local _files_to_remove=(                               
        /etc/sudoers.d/g_wheel
        /var/lib/NetworkManager/NetworkManager.state
        /etc/systemd/system/{choose-mirror.service,pacman-init.service,etc-pacman.d-gnupg.mount,getty@tty1.service.d}
        /etc/systemd/scripts/choose-mirror
        /etc/systemd/system/getty@tty1.service.d/autologin.conf
        /root/{.automated_script.sh,.zlogin}
        /etc/mkinitcpio-archiso.conf
        /etc/initcpio
        /etc/udev/rules.d/81-dhcpcd.rules
        /usr/bin/{calamares_switcher,cleaner_script.sh}
        /home/$NEW_USER/.config/qt5ct
        /home/$NEW_USER/{.xinitrc,.xsession}
        /root/{.xinitrc,.xsession}
        /etc/skel/{.xinitrc,.xsession}
    )

    local xx

    for xx in ${_files_to_remove[*]}; do rm -rf $xx; done

    find /usr/lib/initcpio -name archiso* -type f -exec rm '{}' \;

}

_endeavouros(){

    sed -i "/if/,/fi/"'s/^/#/' /home/$NEW_USER/.bash_profile
    sed -i "/if/,/fi/"'s/^/#/' /root/.bash_profile

    pacman -R gnome-software --noconfirm
    pacman -Rsc gnome-boxes --noconfirm

    _check_internet_connection && {
        #_config_for_app update-mirrorlist # calamares does it for online install. For offline welcome screen at first boot
        _config_for_app kalu
    }

}

_check_install_mode(){

    if [ -f /tmp/run_once ] ; then
        local INSTALL_OPTION="ONLINE_MODE"
    else
        local INSTALL_OPTION="OFFLINE_MODE"
    fi

    case "$INSTALL_OPTION" in
        OFFLINE_MODE)
                _clean_archiso
                _sed_stuff
            ;;

        ONLINE_MODE)
                # not implemented yet. For now run functions at "SCRIPT STARTS HERE"
                :
                # all systemd are enabled - can be specific offline/online in the future
            ;;
        *)
            ;;
    esac
}

########################################
########## SCRIPT STARTS HERE ##########
########################################

_check_install_mode
_common_systemd
_endeavouros
_vbox
rm -rf /usr/bin/{calamares_switcher,cleaner_script.sh}
