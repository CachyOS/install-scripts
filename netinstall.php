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
