#!/bin/bash


read -p "Confirm to overwrite existing backup files? " -n 1 -r
echo #(optional) move to a new line 
if [[ $REPLY =~ ^[Yy]$ ]] 
	then
	echo 
	cd /var/lib/asterisk/CCdbn/
	cp ./record_passwords.csv ./record_passwords.csv.backup
	echo "record_passwords.csv backed up successfully"

	cd /etc/asterisk/
	cp ./dbn_extensions.conf ./dbn_extensions.conf.$(date +"%Y%m%d")
	echo "dbn_extensions.conf backed up as dbn_extensions.conf.$(date +"%Y%m%d")"
	cp ./dbn_voicemail.conf ./dbn_voicemail.conf.$(date +"%Y%m%d")
	echo "dbn_voicemail.conf backed up as dbn_voicemail.conf.$(date +"%Y%m%d")"

	cd /root/
	echo "Backing up cloudcall_voicemail_full.tar ..."
	cp cloudcall_voicemail_full.tar cloudcall_voicemail_full.tar.$(date +"%Y%m%d")
	echo "cp cloudcall_voicemail_full.tar backed up as cloudcall_voicemail_full.tar.$(date +"%Y%m%d")"
	
else
	echo "cancelling..."
	exit
fi
