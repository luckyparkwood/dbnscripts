#!/bin/bash

echo "List of files that will be affected:"
find /etc/asterisk/dbn_*.* -type f -mtime +90 -print
find /root/cloudcall_voicemail_full.tar.* -mtime +90 -print
read -p "Confirm delete DBN backup files older than 90 days? THIS CANNOT BE UNDONE" -n 1 -r
if [[ $REPLY =~ ^[yY]$ ]] ; then
	echo
	find /etc/asterisk/dbn_*.*  -type f -mtime +90 -print | xargs rm -f
	find /root/cloudcall_voicemail_full.tar.*  -mtime +90 -print | xargs rm -f
	echo "Files deleted."
else
	echo
	echo "Cancelling..."
fi
