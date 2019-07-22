- name: "EndeavourOS-system-default"
  description: "base system"
  hidden: false
  selected: true
  critical: false
    - endeavouros-keyring
    - endeavouros-mirrorlist
    - xf86-video-vesa
    - xorg-server
    - xorg-xinit
    - linux-firmware
    - grub2-theme-endeavouros
    - firefox
    - firefox-ublock-origin
    - xf86-input-libinput
    - xf86-input-synaptics
    - xf86-video-amdgpu
    - xf86-video-ati
    - xf86-video-fbdev
    - xf86-video-intel
    - xf86-video-vesa
    - xorg-server
    - xf86-video-nouveau
    - gvfs
    - gvfs-mtp
    - gvfs-afc
    - gvfs-goa
    - gvfs-google
    - gvfs-gphoto2
    - gvfs-nfs
    - gvfs-smb
    - libwnck3
    - grml-zsh-config
    - networkmanager
    - openssh
    - upower
    - hwinfo
    - python
    - solid
    - ttf-dejavu
    - gnu-free-fonts
    - ttf-liberation
    - ttf-bitstream-vera
    - ttf-ubuntu-font-family
    - noto-fonts
    - noto-fonts-cjk
    - ttf-croscore
    - ttf-carlito
    - ttf-caladea
    - terminus-font
    - alsa-utils
    - alsa-plugins
    - alsa-firmware
    - hardinfo
    - pavucontrol
    - ffmpegthumbnailer
    - poppler-glib
    - libgsf 
    - libopenraw
    - freetype2
    - gst-libav
    - gst-plugins-bad
    - gst-plugins-ugly
    - kalu
    - yay
    - virtualbox-guest-utils
    - virtualbox-guest-modules-arch
- name: "XFCE4-Desktop"
  description: "install the xfce4 Desktop"
  hidden: false
  selected: false
  critical: false
  packages:
    - adwaita-icon-theme
    - xfce4
    - xfce4-goodies
    - xfce4-pulseaudio-plugin
    - lightdm
    - light-locker
    - lightdm-gtk-greeter-settings
    - galculator
- name: "MATE-Desktop"
  description: "MATE Desktop"
  hidden: false
  selected: false
  critical: false
  packages:
    - mate
    - mate-extra
    - lightdm
    - light-locker
    - lightdm-gtk-greeter-settings
- name: "KDE-Desktop"
  description: "KDE-Plasma Desktop"
  hidden: false
  selected: false
  critical: false
  packages:
    - plasma
    - plasma-wayland-session
    - kde-applications
    - powerdevil
    - sddm
    - sddm-kcm
- name: "GNOME-Desktop"
  description: "GNOME Desktop"
  hidden: false
  selected: false
  critical: false
  packages:
    - gnome
    - gnome-extra
    - gdm
