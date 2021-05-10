#!/bin/bash

if [[ -z $1 ]] ; then
	read -p " What is the customer Context? " custContext
	else
		custContext=$1
	fi

sed -n "/$custContext/,/^$/p" /etc/asterisk/dbn_voicemail.conf	
read -p "Confirm remove context?" -n 1 -r
if [[ $REPLY =~ ^[yY]$ ]]
then	
	echo
	sed -i "/$custContext/,/^$/d" /etc/asterisk/dbn_voicemail.conf
	echo "removed context"
else
	echo
	echo "cancelling..."
	exit
fi


