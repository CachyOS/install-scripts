#!/bin/bash

# New version of cleaner_script
# Made by @fernandomaroto and @manuel 

#NEW_USER=$(ls $chroot_path/home |grep -v "lost+found")
NEW_USER=$(head -n1 /etc/sudoers.d/10-installer | awk '{print $1}')
#NEW_USER=$(cat /tmp/$chroot_path/etc/passwd | grep "/home" |cut -d: -f1 |head -1)

# Any failed command will just be skiped, error message may pop up but won't crash the install process

# Net-install creates the file /tmp/run_once in live environment (need to be transfered to installed system) so it can be used to detect install option


_check_internet_connection(){
    #ping -c 1 8.8.8.8 >& /dev/null   # ping Google's address
    curl --silent --connect-timeout 8 https://8.8.8.8 > /dev/null
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
    local _systemd_enable=(NetworkManager vboxservice org.cups.cupsd avahi-daemon systemd-networkd-wait-online systemd-timesyncd tlp tlp-sleep gdm lightdm sddm)   
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
        /home/$NEW_USER/{.xinitrc,.xsession,.xprofile}
        /root/{.xinitrc,.xsession,.xprofile}
        /etc/skel/{.xinitrc,.xsession,.xprofile}
    )

    local xx

    for xx in ${_files_to_remove[*]}; do rm -rf $xx; done

    find /usr/lib/initcpio -name archiso* -type f -exec rm '{}' \;

}

_clean_offline_packages(){

    local _packages_to_remove=( 
        qt5ct
        qt5-base
        calamares_current
        arch-install-scripts
        qt5-svg
        qt5-webengine
        kpmcore
        kdbusaddons 
        kcrash
        qt5-declarative
        squashfs-tools
        ddrescue
        dd_rescue
        testdisk
        qt5-tools
        kparts
        polkit-qt5
        qt5-xmlpatterns
        python-pyqt5
        python-sip-pyqt5
        pyqt5-common
        extra-cmake-modules 
        cmake
        elinks
        yaml-cpp
        syslinux
        solid
        kwidgetsaddons
        kservice
        ki18n
        kcoreaddons
        kconfig
        clonezilla
        partclone
        partimage
        ckbcomp
        gnome-boxes
        xcompmgr
        epiphany
)
    local xx
    # @ does one by one to avoid errors in the entire process
    # * can be used to treat all packages in one command
    for xx in ${_packages_to_remove[@]}; do pacman -Rnscv $xx --noconfirm; done

}

_endeavouros(){

    sed -i "/if/,/fi/"'s/^/#/' /home/$NEW_USER/.bash_profile
    sed -i "/if/,/fi/"'s/^/#/' /root/.bash_profile

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
                _clean_offline_packages
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

_remove_ucode(){
    local ucode="$1"
    pacman -Q $ucode >& /dev/null && {
        pacman -Rsn $ucode --noconfirm >/dev/null
    }
}

_clean_up(){
    if [ -x /usr/bin/device-info ] ; then
        case "$(/usr/bin/device-info --cpu)" in
            GenuineIntel) _remove_ucode amd-ucode ;;
            *)            _remove_ucode intel-ucode ;;
        esac
    fi
}

########################################
########## SCRIPT STARTS HERE ##########
########################################

_check_install_mode
_common_systemd
_endeavouros
_vbox
_clean_up
rm -rf /usr/bin/{calamares_switcher,cleaner_script.sh,chrooted_cleaner_script.sh,calamares_for_testers}
