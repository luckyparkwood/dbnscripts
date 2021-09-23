#!/bin/bash

_adddate() {
	while IFS= read -r line; do
		printf '%s %s\n' "$(date)" "$line";
	done
}


tar -cvf /var/lib/asterisk/CCdbn-$(date +"%Y%m%d").tar /var/lib/asterisk/CCdbn/
tar -cvf /etc/asterisk/dbn_extensions-$(date +"%Y%m%d").tar /etc/asterisk/dbn_extensions.conf
tar -cvf /etc/asterisk/dbn_voicemail-$(date +"%Y%m%d").tar /etc/asterisk/dbn_voicemail.conf
tar -cvf /var/spool/asterisk/dbn_vmrecordings-$(date +"%Y%m%d").tar /var/spool/asterisk/voicemail/

find /var/lib/asterisk/ -maxdepth 1 -name "*.tar" -mtime +7 -delete -printf "File %p deleted.\n" | _adddate >> /var/log/dbntool/removal_logs.txt 2>> /var/log/dbntool/errors.txt
find /var/spool/asterisk/ -maxdepth 1 -name "*.tar" -mtime +7 -delete -printf "File %p deleted.\n" | _adddate >> /var/log/dbntool/removal_logs.txt 2>> /var/log/dbntool/errors.txt
find /etc/asterisk/ -maxdepth 1 -name "*.tar" -mtime +7 -delete -printf "File %p deleted.\n" | _adddate >> /var/log/dbntool/removal_logs.txt 2>> /var/log/dbntool/errors.txt


