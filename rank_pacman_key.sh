#!/bin/bash

# Made by @fernandomaroto

# This script is temporary untill pacstrap module is fully implemented as bash script

TIME="time_servers.log"
if [ ! -d rank ]; then mkdir rank; fi
cd rank

# Feel free to suggest mirrors to be added or removed bellow
servers_array=(

"keys.openpgp.org"
"pgp.mit.edu"
"keyring.debian.org"
"keyserver.ubuntu.com"
"zimmermann.mayfirst.org"
"pool.sks-keyservers.net"
"na.pool.sks-keyservers.net"
"eu.pool.sks-keyservers.net"
"oc.pool.sks-keyservers.net"
"p80.pool.sks-keyservers.net"
"ipv4.pool.sks-keyservers.net"
"ipv6.pool.sks-keyservers.net"
"subset.pool.sks-keyservers.net"

)

_run(){
rm -rf $TIME.* 
for server in "${servers_array[@]}"
do
    ping -c 1 $server 2>&1 > $TIME.$server

done

rm -rf $(grep -r "100% packet loss" * |awk '{ print $1 }' | sed 's/:.*//g')

# unfortunately this sometimes generates some type of server door like 2001:470:1:116::6 and pacman-key doesn't work, so need to get the original url again :(
RANK_BEST=$(grep "time=" * | sort -k8 --version-sort | uniq -u | head -n 1 | awk '{ print $4 }')

FINAL=$(grep -n "$RANK_BEST" * |grep "PING" |sed s'/^.*PING //' |sed s'/(.*//')

sudo pacman-key --refresh-keys --keyserver $FINAL

}

_run
