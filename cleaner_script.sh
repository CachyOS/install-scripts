#!/bin/bash

NEW_USER=$(cat /etc/passwd | grep "/home" |cut -d: -f1 |head -1)
DISTRO_NAME=""

do_check_internet_connection(){
    ping -c 1 8.8.8.8 >& /dev/null   # ping Google's address
}

do_arch_news_latest_headline(){
    # gets the latest Arch news headline for 'kalu' config file news.conf
    local info=$(mktemp)
    wget -q -T 10 -O $info https://www.archlinux.org/ && \
        { grep 'title="View full article:' $info | sed -e 's|&gt;|>|g' -e 's|^.*">[ ]*||' -e 's|</a>$||' | head -n 1 ; }
    rm -f $info
}

do_config_for_app(){
    # handle configs for apps here; called from distro specific function

    local app="$1"    # name of the app

    case "$app" in
        kalu)
            mkdir -p /etc/skel/.config/kalu
            printf "Last=" >> /etc/skel/.config/kalu/news.conf
            do_arch_news_latest_headline >> /etc/skel/.config/kalu/news.conf
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

do_common_systemd(){

systemctl enable NetworkManager -f 2>>/tmp/.errlog
systemctl disable multi-user.target 2>>/dev/null
systemctl enable vboxservice 2>>/dev/null
systemctl enable org.cups.cupsd.service 2>>/dev/null
systemctl enable avahi-daemon.service 2>>/dev/null
systemctl disable pacman-init.service choose-mirror.service

# Journal
sed -i 's/volatile/auto/g' /etc/systemd/journald.conf 2>>/tmp/.errlog

}

do_clean_archiso(){

rm -f /etc/sudoers.d/g_wheel 2>>/tmp/.errlog
rm -f /var/lib/NetworkManager/NetworkManager.state 2>>/tmp/.errlog
sed -i 's/.*pam_wheel\.so/#&/' /etc/pam.d/su 2>>/tmp/.errlog
find /usr/lib/initcpio -name archiso* -type f -exec rm '{}' \;
rm -Rf /etc/systemd/system/{choose-mirror.service,pacman-init.service,etc-pacman.d-gnupg.mount,getty@tty1.service.d}
rm -Rf /etc/systemd/scripts/choose-mirror
rm -f /etc/systemd/system/getty@tty1.service.d/autologin.conf
rm -f /root/{.automated_script.sh,.zlogin}
rm -f /etc/mkinitcpio-archiso.conf
rm -Rf /etc/initcpio
rm -Rf /etc/udev/rules.d/81-dhcpcd.rules

}

do_vbox(){

# Detects if running in vbox
local xx

lspci | grep -i "virtualbox" >/dev/null
if [[ $? == 0 ]]
    then
        :      
    else
        for xx in virtualbox-guest-utils virtualbox-guest-modules-arch virtualbox-guest-dkms ; do
            test -n "$(pacman -Q $xx 2>/dev/null)" && pacman -Rnsdd $xx --noconfirm
        done
        rm -f /usr/lib/modules-load.d/virtualbox-guest-dkms.conf
fi

}

do_display_manager(){
# no problem if any of them fails
systemctl -f enable gdm
systemctl -f enable lightdm
systemctl -f enable sddm
pacman -R gnome-software --noconfirm
pacman -Rsc gnome-boxes --noconfirm

}

do_endeavouros(){

rm -rf /home/$NEW_USER/.config/qt5ct
rm -rf /home/$NEW_USER/{.xinitrc,.xsession} 2>>/tmp/.errlog
rm -rf /root/{.xinitrc,.xsession} 2>>/tmp/.errlog
rm -rf /etc/skel/{.xinitrc,.xsession} 2>>/tmp/.errlog
sed -i "/if/,/fi/"'s/^/#/' /home/$NEW_USER/.bash_profile
sed -i "/if/,/fi/"'s/^/#/' /home/$NEW_USER/.zprofile
sed -i "/if/,/fi/"'s/^/#/' /root/.bash_profile
sed -i "/if/,/fi/"'s/^/#/' /root/.zprofile

do_display_manager

do_check_internet_connection && {
    #do_config_for_app update-mirrorlist
    do_config_for_app kalu
}

chmod 750 /root
}



########################################
########## SCRIPT STARTS HERE ##########
########################################

do_common_systemd
do_clean_archiso
do_endeavouros
rm -rf /usr/bin/calamares_switcher
rm -rf /usr/bin/cleaner_script.sh

