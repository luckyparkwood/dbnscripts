#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

if [[ -z $1 ]] ; then
#	read -p "Customer context to add? " custContext
	_set_custContext
else
	custContext=$1
fi

if grep -q "$custContext" /var/lib/asterisk/CCdbn/record_passwords.csv; then
	echo "Customer context $custContext already exists. Try again."
	exit
else
	echo " No match found for $custContext"
fi

custPin=$(date +%s%N | cut -c15-19)
echo "Random PIN $custPIN generated"
if grep -q "$custPin" /var/lib/asterisk/CCdbn/record_passwords.csv; then
	echo "custPIN $custPin already exists. Try again."
	exit
else
	echo "No match found for $custPin"
	echo "Adding PIN $custPin for $custContext"
	echo "$custPin,$custContext" >> /var/lib/asterisk/CCdbn/record_passwords.csv;
	echo "done"
fi
