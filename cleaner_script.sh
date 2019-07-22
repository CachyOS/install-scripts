#!/bin/bash

NEW_USER=$(cat /etc/passwd | grep "/home" |cut -d: -f1 |head -1)
DISTRO_NAME=""

do_common_systemd(){

# Fix NetworkManager
systemctl enable NetworkManager -f 2>>/tmp/.errlog
systemctl disable multi-user.target 2>>/dev/null
systemctl enable vboxservice 2>>/dev/null
systemctl enable org.cups.cupsd.service 2>>/dev/null
systemctl enable avahi-daemon.service 2>>/dev/null
systemctl disable pacman-init.service choose-mirror.service

# Journal
sed -i 's/volatile/auto/g' /etc/systemd/journald.conf 2>>/tmp/.errlog

# Login manager should be set specifically

}

do_clean_archiso(){

# clean out archiso files from install 
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

lspci | grep -i "virtualbox" >/dev/null
if [[ $? == 0 ]]
    then
        :      
        # Depends on which vbox package we're installing  
        #systemctl enable vboxservice
        #pacman -Rnsdd virtualbox-host-dkms --noconfirm
    else
        pacman -Rnsdd virtualbox-guest-utils --noconfirm
        pacman -Rnsdd virtualbox-guest-modules-arch --noconfirm
        #pacman -Rnsdd virtualbox-guest-dkms --noconfirm        
        #rm /usr/lib/modules-load.d/virtualbox-guest-dkms.conf
fi

}

do_clean_offline_installer(){

# cli installer
rm -rf /vomi 2>>/tmp/.errlog
#rm -rf ${BYPASS} 2>>/tmp/.errlog
rm -rf /source 2>>/tmp/.errlog
rm -rf /src 2>>/tmp/.errlog
rmdir /bypass 2>>/tmp/.errlog
rmdir /src 2>>/tmp/.errlog
rmdir /source 2>>/tmp/.errlog
rm -rf /offline_installer

# calamares installer
# not ready yet
pacman -Rns calamares_offline --noconfirm

}

do_portergos(){

do_clean_offline_installer

export DISPLAY=:0.0
dbus-launch dconf load / < /etc/skel/dconf.conf
sudo -H -u $NEW_USER bash -c 'dbus-launch dconf load / < /etc/skel/dconf.conf'
rm /home/$NEW_USER/dconf.conf
rm /etc/skel/dconf.conf

#conky and installer icons
sed -i "/\${font sans:bold:size=8}INSTALLERS \${hr 2}/d" /home/$NEW_USER/.conky/i3_shortcuts/Gotham
sed -i "/mod+i\${goto 120}= Portergos installer/d" /home/$NEW_USER/.conky/i3_shortcuts/Gotham
sed -i "/\${font sans:bold:size=8}INSTALLERS \${hr 2}/d" /home/$NEW_USER/.conky/xfce_shortcuts/Gotham
sed -i "/mod+i\${goto 120}= Portergos installer/d" /home/$NEW_USER/.conky/xfce_shortcuts/Gotham
sed -i "/<Filename>offline_installer.desktop<\/Filename>/d" /home/$NEW_USER/.config/menus/xfce-applications.menu

sed -i "/\${font sans:bold:size=8}INSTALLERS \${hr 2}/d" /root/.conky/i3_shortcuts/Gotham
sed -i "/mod+i\${goto 120}= Portergos installer/d" /root/.conky/xfce_shortcuts/Gotham
sed -i "/\${font sans:bold:size=8}INSTALLERS \${hr 2}/d" /root/.conky/i3_shortcuts/Gotham
sed -i "/mod+i\${goto 120}= Portergos installer/d" /root/.conky/xfce_shortcuts/Gotham
sed -i "/<Filename>offline_installer.desktop<\/Filename>/d" /root/.config/menus/xfce-applications.menu

#.config/sxhkd
sed -i "/super + i/,/installer/"'d' /home/$NEW_USER/.config/sxhkd/sxhkdrc
sed -i "/super + i/,/installer/"'d' /root/.config/sxhkd/sxhkdrc

# Clean specific installer stuff
#rm -rf /offline_installer
rm -rf /etc/skel/.local/share/applications/offline_installer.desktop
rm -rf /home/$NEW_USER/.local/share/applications/offline_installer.desktop

rm -rf /home/$NEW_USER/{.xinitrc,.xsession} 2>>/tmp/.errlog
rm -rf /home/$NEW_USER/.portergos_configs/{.xinitrc_i3,.xinitrc_xfce4,.xinitrc_openbox,.welcome_screen} 2>>/tmp/.errlog
rm -rf /root/{.xinitrc,.xsession} 2>>/tmp/.errlog
rm -rf /root/.portergos_configs/{.xinitrc_i3,.xinitrc_xfce4,.xinitrc_openbox,.welcome_screen} 2>>/tmp/.errlog
rm -rf /etc/skel/{.xinitrc,.xsession} 2>>/tmp/.errlog
rm -rf /etc/skel/.portergos_configs/{.xinitrc_i3,.xinitrc_xfce4,.xinitrc_openbox,.welcome_screen} 2>>/tmp/.errlog

sed -i "/if/,/fi/"'s/^/#/' /home/$NEW_USER/.bash_profile
sed -i "/if/,/fi/"'s/^/#/' /home/$NEW_USER/.zprofile
sed -i "/if/,/fi/"'s/^/#/' /root/.bash_profile
sed -i "/if/,/fi/"'s/^/#/' /root/.zprofile

# Journal
#sed -i 's/volatile/auto/g' /etc/systemd/journald.conf 2>>/tmp/.errlog

systemctl enable sddm 2>>/dev/null

# Grub still needs polishing. Looking for a solution when using calamares for multiple distros
sed -i "s/menuentry 'Arch Linux' - /menuentry 'Arch Linux' - LTS/"g /boot/grub/grub.cfg 2>/dev/null

# Split advanced options at grub menu
echo "GRUB_DISABLE_SUBMENU=y" >> /etc/default/grub >/dev/null

}

do_endeavouros(){

# for some reason installed system uses bash
chsh -s /usr/bin/zsh
rm -rf /home/$NEW_USER/.config/qt5ct
rm -rf /home/$NEW_USER/{.xinitrc,.xsession} 2>>/tmp/.errlog
rm -rf /root/{.xinitrc,.xsession} 2>>/tmp/.errlog
rm -rf /etc/skel/{.xinitrc,.xsession} 2>>/tmp/.errlog
sed -i "/if/,/fi/"'s/^/#/' /home/$NEW_USER/.bash_profile
sed -i "/if/,/fi/"'s/^/#/' /home/$NEW_USER/.zprofile
sed -i "/if/,/fi/"'s/^/#/' /root/.bash_profile
sed -i "/if/,/fi/"'s/^/#/' /root/.zprofile

# keeping the code for now commented, to be purged in the future
# the new config folder is injected at customize_airootfs which makes this unecessary
#rm -rf /home/$NEW_USER/.config/xfce4/panel/launcher-17
#rm -rf /root/.config/xfce4/panel/launcher-17

systemctl enable lightdm 2>>/dev/null

}

do_reborn(){

do_clean_offline_installer

systemctl enable lightdm 2>>/dev/null

}

do_detect_distro(){
# Not elegant, but works

cat /etc/os-release |head -n 1 | grep "EndeavourOS"
[[ $? == 0 ]] && DISTRO_NAME="EndeavourOS"

cat /etc/os-release |head -n 1 | grep "Portergos"
[[ $? == 0 ]] && DISTRO_NAME="Portergos"

cat /etc/os-release |head -n 1 | grep "Reborn"
[[ $? == 0 ]] && DISTRO_NAME="Reborn"

}

do_apply_distro_specific(){

[[ $DISTRO_NAME == "EndeavourOS" ]] && do_endeavouros
[[ $DISTRO_NAME == "Portergos" ]] && do_portergos
[[ $DISTRO_NAME == "Reborn" ]] && do_reborn

}

########################################
########## SCRIPT STARTS HERE ##########
########################################

do_common_systemd
do_clean_archiso
#do_clean_offline_installer
do_detect_distro
do_apply_distro_specific
rm -rf /usr/bin/cleaner_script.sh

