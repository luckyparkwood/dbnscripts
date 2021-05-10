#!/bin/bash

if [[ -z $1 ]] ; then
        read -p " Customer context? " custContext
else
        custContext=$1
fi

cp /var/lib/asterisk/CCdbn/$custContext/accounts.csv /home/chris.bright/htmlchris/"$custContext"-dbn.$(date +"%Y%m%d").csv
echo "$custContext/accounts.csv copied to htmlchris/ as "$custContext"-dbn.$(date +"%Y%m%d").csv"
echo
echo "$custContext Accounts available via http link below (CCVPN must be on):
http://172.31.36.3/chris/$custContext"-dbn.$(date +"%Y%m%d").csv""
echo
dbntool show get-printout "$custContext"
