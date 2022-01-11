#!/bin/bash

if [[ -z $1 ]] ; then
	read -p " Customer context? " custContext

elif [[ $1 == "all" ]] ; then
	ls -d /var/lib/asterisk/CCdbn/*/ | sed 's/\/var\/lib\/asterisk\/CCdbn\///g'
	exit	
else
	custContext=$1
fi

echo "Matched Cust Folders: "
ls /var/lib/asterisk/CCdbn/ | grep $custContext
echo
echo "matching recording PINs : "
cat /var/lib/asterisk/CCdbn/record_passwords.csv | grep $custContext
echo
echo "dbn_extensions.conf matching context: "
grep -B 1 -A 1 "$custContext" /etc/asterisk/dbn_extensions.conf
echo
echo "dbn_voicemail.conf matching context: "
sed -n -e "/^\[$custContext\]/,/^$/p" /etc/asterisk/dbn_voicemail.conf
echo
echo "matching accounts.csv: "
ls -d /var/lib/asterisk/CCdbn/$custContext/accounts.csv
cat /var/lib/asterisk/CCdbn/$custContext/accounts.csv
echo
echo
