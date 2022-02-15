#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

while getopts c:h flag
do
	case "${flag}" in
		c) custContext=${OPTARG}; flag_mode="yes";;
		h) echo "Usage: dbntool add recording-pin -c [custContext]"; exit;;
		?) echo "invalid flag, exiting" >&2; exit;;
	esac
done

if [[ ! $flag_mode == "yes" ]] ; then
	if [[ -z $1 ]] ; then
#		read -p "Customer context to add? " custContext
		_set_custContext
	else
		custContext=$1
	fi
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
