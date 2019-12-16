#!/bin/bash

# DOWNLOAD ME !!

# wget https://github.com/endeavouros-team/install-scripts/raw/master/calamares_branding.sh && chmod +x calamares_branding.sh && ./calamares_branding.sh

_check_internet_connection(){
    ping -c 1 8.8.8.8 >& /dev/null   # ping Google's address
}

_update_branding(){

    local URL="https://github.com/endeavouros-team/calamares_branding.git"

    git clone $URL
    sudo cp -praf calamares_branding/branding/endeavouros/* /usr/share/calamares/branding/endeavouros/
    rm -rf calamares_branding

}

################################
###### SCRIPT STARTS HERE ######
################################

_check_internet_connection && _update_branding
