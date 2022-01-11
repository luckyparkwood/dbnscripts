#!/bin/bash


if [[ -z $1 ]] ; then
	read -p 'Customer context to search: ' custContext
else 
custContext="$1"
fi


# no longer need to print a header
#sed -n 1,2p /var/lib/asterisk/CCdbn/record_passwords.csv 
cat /var/lib/asterisk/CCdbn/record_passwords.csv | grep $custContext || echo "no match" >&2

#temp=$1 
#sed -n 1,2p /var/lib/asterisk/CCdbn/record_passwords.csv 
#cat /var/lib/asterisk/CCdbn/record_passwords.csv | grep $temp | cut -c1-5=custPIN
#sed -e 2's/$/$custPIN/' /var/lib/asterisk/CCdbn/record_passwords.csv  

