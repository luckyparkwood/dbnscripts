#!/bin/bash

echo "Values are '\<NEW VALUE' '\>OLDVALUE'"
cd /var/lib/asterisk/CCdbn/
echo "./record_passwords.csv"
diff ./record_passwords.csv ./record_passwords.csv.backup
cd /etc/asterisk/
echo
echo  "\dbn_extensions.conf"
diff ./dbn_extensions.conf ./dbn_extensions.conf.$(date +"%Y%m%d")
echo
echo "\dbn_voicemail.conf"
diff ./dbn_voicemail.conf ./dbn_voicemail.conf.$(date +"%Y%m%d")
