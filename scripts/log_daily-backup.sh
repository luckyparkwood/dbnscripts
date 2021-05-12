#!/bin/bash

tar -cvf /var/lib/asterisk/CCdbn-$(date +"%Y%m%d").tar /var/lib/asterisk/CCdbn/
tar -cvf /etc/asterisk/dbn_extensions-$(date +"%Y%m%d").tar /etc/asterisk/dbn_extensions.conf
tar -cvf /etc/asterisk/dbn_voicemail-$(date +"%Y%m%d").tar /etc/asterisk/dbn_voicemail.conf
tar -cvf /var/spool/asterisk/dbn_vmrecordings-$(date +"%Y%m%d").tar /var/spool/asterisk/voicemail/

echo $'\n$date' >> /etc/dbntool/changelog/removal_logs.txt
echo $'\n$date' >> /etc/dbntool/changelog/errors.txt
find /var/lib/asterisk/ -maxdepth 1 -name "*.tar" -mtime +7 -delete -printf "File %p deleted.\n" >> /etc/dbntool/changelog/removal_logs.txt 2>> /etc/dbntool/changelog/errors.txt
find /var/spool/asterisk/ -maxdepth 1 -name "*.tar" -mtime +7 -delete -printf "File %p deleted.\n" >> /etc/dbntool/changelog/removal_logs.txt 2>> /etc/dbntool/changelog/errors.txt
find /etc/asterisk/ -maxdepth 1 -name "*.tar" -mtime +7 -delete -printf "File %p deleted.\n" >> /etc/dbntool/changelog/removal_logs.txt 2>> /etc/dbntool/changelog/errors.txt


