#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

read -p "Customer context? " custContext
_cust_dircheck "$custContext"
if [[ $? -eq 1 ]] ; then
	echo "Customer not found, exiting"
	exit
fi


fileAccounts="/var/lib/asterisk/CCdbn/$custContext/accounts.csv"
fileVoicemail="/etc/asterisk/dbn_voicemail.conf"

read -p "Change field from?: " changeFrom
read -p "Change field to?: " changeTo

echo "Accounts.csv FROM:"
grep "$changeFrom" $fileAccounts 
echo "Accounts.csv TO:"
sed "s/$changeFrom/$changeTo/" $fileAccounts | grep "$changeTo"

echo "dbn_voicemail.conf FROM:"
grep "$changeFrom" $fileVoicemail
echo "dbn_voicemail.conf TO:"
sed "s/$changeFrom/$changeTo/" $fileVoicemail | grep "$changeTo"

read -p "Confirm changes? This cannot be undone!" -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]] ; then
		echo
		sed -i "s/$changeFrom/$changeTo/" $fileAccounts | grep "$changeTo"
		sed -i "s/$changeFrom/$changeTo/" $fileVoicemail | grep "$changeTo"
	else
		echo "Cancelling..."
	fi										
