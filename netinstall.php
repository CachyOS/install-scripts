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
    - arc-gtk-theme
    - arc-icon-theme
    - elementary-icon-theme
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
    - arc-gtk-theme
    - arc-icon-theme
    - elementary-icon-theme
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
    - arc-kde
    - kvantum-theme-arc
- name: "GNOME-Desktop"
  description: "GNOME Desktop"
  hidden: false
  selected: false
  critical: false
  packages:
    - gnome
    - gnome-extra
    - gdm
    - arc-gtk-theme
    - arc-icon-theme
    - elementary-icon-theme
