#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

echo "run with custContext as var1 to search within accounts.csv"

if [[ -z $1 ]] ; then
	for f in "$(grep -o -E "[0-9]{11}" /etc/asterisk/dbn_voicemail.conf | uniq -d )" 
	do grep "$f" /etc/asterisk/dbn_voicemail.conf ; done
else
	custContext="$1"
	_cust_dircheck "$custContext"
	if [[ $? == 1 ]] ; then
		echo "dir not found, exiting"
		exit
	else
	for f in "$(grep -o -E "[0-9]{11}" /var/lib/asterisk/CCdbn/$custContext/accounts.csv | uniq -d )" 
	do grep "$f" /etc/asterisk/dbn_voicemail.conf ; done
	fi
fi





