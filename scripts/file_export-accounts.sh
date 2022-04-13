#!/bin/bash

if [[ -z $1 ]] ; then
        read -p " Customer context? " custContext
else
        custContext=$1
fi

#reorder accounts before export
cd /var/lib/asterisk/CCdbn/$custContext/
#removing accounts file backup, using git instead
#cp -p accounts.csv _accounts.csv
cat _accounts.csv | grep -n '' | sed -E 's/:[0-9]+//g' > accounts.csv


cp /var/lib/asterisk/CCdbn/$custContext/accounts.csv /home/chris.bright/htmlchris/"$custContext"-dbn.$(date +"%Y%m%d").csv
chmod 644 /home/chris.bright/htmlchris/"$custContext"-dbn.$(date +"%Y%m%d").csv
echo "$custContext/accounts.csv copied to htmlchris/ as "$custContext"-dbn.$(date +"%Y%m%d").csv"
echo
echo "$custContext Accounts available via http link below (CCVPN must be on):
http://172.31.36.3/chris/$custContext"-dbn.$(date +"%Y%m%d").csv""
echo
dbntool show get-printout "$custContext"
