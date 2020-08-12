#!/bin/bash

# Made by @fernandomaroto.
# Modified by @manuel.

# This script is temporary until pacstrap module is fully implemented as bash script

# NOTE: requires package 'time' to be installed !!!
# Note2: requires program 'keyserver_rank'

_run(){
    if [ ! -x /usr/bin/time ] ; then
        echo "ERROR: package 'time' must be installed for $0."
        return 1
    fi
    if [ ! -x /usr/bin/keyserver_rank ] ; then
        echo "ERROR: program 'keyserver_rank' must be installed for $0."
        return 1
    fi

    local servers_array=(    # Feel free to suggest mirrors to be added or removed bellow

        ############ These don't work:
        #  "keys.openpgp.org"
        ## "pgp.mit.edu"
        #  "keyring.debian.org"
        ## "subset.pool.sks-keyservers.net"
        #  "ipv6.pool.sks-keyservers.net"

        ############ These do work:
        "ipv4.pool.sks-keyservers.net"
        "keyserver.ubuntu.com"
        "zimmermann.mayfirst.org"
        "pool.sks-keyservers.net"
        "na.pool.sks-keyservers.net"
        "eu.pool.sks-keyservers.net"
        "oc.pool.sks-keyservers.net"
        "p80.pool.sks-keyservers.net"
    )
    local server
    local cmdresult
    local timeresult
    local log=$(mktemp)
    
    for server in "${servers_array[@]}"
    do
        timeresult="$(/usr/bin/time -f %e /usr/bin/keyserver_rank $server $log 2>&1 | tail -n 1)"
        echo "$timeresult" >> $log
    done
    cat $log | sort -k 3 | column -t
    local fastest=$(cat $log | grep -v -w FAIL | sort -k 3 | head -n 1 | awk '{print $1}')
    printf "\nFastest is: $fastest\n" >&2
    rm -f $log

    sudo pacman-key --refresh-keys --keyserver $fastest
}

_run
