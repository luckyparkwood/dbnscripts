#!/bin/bash

logFilepath=/etc/dbntool/changelog/changelog.log

cd /var/lib/asterisk/CCdbn/
echo "./record_passwords.csv" 
diff ./record_passwords.csv ./record_passwords.csv.backup
cd /etc/asterisk/
echo -e  "\n.dbn_extensions.conf" 
diff ./dbn_extensions.conf ./dbn_extensions.conf.$(date +"%Y%m%d") 
echo -e "\n.dbn_voicemail.conf" 
diff ./dbn_voicemail.conf ./dbn_voicemail.conf.$(date +"%Y%m%d") 


read -p "Commit diff to changelog? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then   
	echo
	echo -e "\nChangelog for $(date +"%Y%m%d")" > $logFilepath
	cd /var/lib/asterisk/CCdbn/
	echo "./record_passwords.csv CHANGES" >> $logFilepath
	diff ./record_passwords.csv ./record_passwords.csv.backup >> $logFilepath
	cd /etc/asterisk/
	echo -e  "\n.dbn_extensions.conf" >> $logFilepath
	diff ./dbn_extensions.conf ./dbn_extensions.conf.$(date +"%Y%m%d") >> $logFilepath
	echo -e "\n.dbn_voicemail.conf" >> $logFilepath/
	diff ./dbn_voicemail.conf ./dbn_voicemail.conf.$(date +"%Y%m%d") >> $logFilepath
	echo "changes written to log"
else
	echo
	echo "cancelling..."
fi
