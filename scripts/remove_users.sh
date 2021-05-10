#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

inFile=$1
inFilePath="$(pwd $inFile)"
accountPath=/var/lib/asterisk/CCdbn
voicemailPath=/etc/asterisk
logFile=/etc/dbntool/changelog/removed_users.log

_set_custContext

_cust_dircheck "$custContext"
if [[ $? -eq 1 ]] ; then
	echo "Customer context $custContext does not exist, exiting..."
	exit
fi


#echo " Backing up CUST accounts.csv..."
#cp $accountPath/$custContext/accounts.csv $accountPath/$custContext/accounts.$(date +"%Y%m%d").bak
#read -p "Backup voicemail.conf? Y/N " -n 1 -r
#	if [[ $REPLY =~ ^[Yy]$ ]] ; then
#		echo "Backing up voicemail.conf..."
#		cp $voicemailPath/dbn_voicemail.conf $voicemailPath/dbn_voicemail.$(date +"%Y%m%d").bak
#	fi

if [[ -z $1 ]] ; then
	read -p "DID to remove? " removeDID
	grep -v $removeDID < $accountPath/$custContext/accounts.csv > $accountPath/$custContext/accounts-temp.csv
	grep -v $removeDID < $voicemailPath/dbn_voicemail.conf > $voicemailPath/voicemail-temp.csv
	
	echo "Before removal: "
	echo "accounts.csv: "
	grep $removeDID < $accountPath/$custContext/accounts.csv
	echo "voicemail.conf: "
	grep $removeDID < $voicemailPath/dbn_voicemail.conf
	echo
	echo "After removal: "
	echo "accounts.csv: "
	grep $removeDID < $accountPath/$custContext/accounts-temp.csv
	echo "voicemail.conf: "
	grep $removeDID < $voicemailPath/voicemail-temp.csv
else
	grep -vf $inFile.csv $accountPath/$custContext/accounts.csv > $accountPath/$custContext/accounts-temp.csv
	grep -vf $infile.csv $voicemailPath/dbn_voicemail.conf > $voicemailPath/voicemail-temp.csv

	echo "Before removal: "
	echo "accounts.csv: "
	grep -f $inFile $accountPath/$custContext/accounts.csv
	echo "voicemail.conf: "
	grep -f $inFile $voicemailPath/dbn_voicemail.conf
	echo
	echo "After removal: "
	echo "accounts.csv: "
	grep -f $inFile $accountPath/$custContext/accounts-temp.csv
	echo "voicemail.conf: "
	grep -f $inFile $voicemailPath/voicemail-temp.csv

fi

read -p "Confirm remove user/s? This cannot be undone! Y/N " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]] ; then
		echo
		echo "Logging removals..."	
		echo "[$custContext] on $(date +"%Y%m%d") " >> $logFile
		diff $accountPath/$custContext/accounts-temp.csv $accountPath/$custContext/accounts.csv >> $logFile
		diff $voicemailPath/voicemail-temp.csv $voicemailPath/dbn_voicemail.conf >> $logFile
		mv $accountPath/$custContext/accounts-temp.csv $accountPath/$custContext/accounts.csv
		mv $voicemailPath/voicemail-temp.csv $voicemailPath/dbn_voicemail.conf
		echo "Accounts removed."

	else
		echo
		rm $accountPath/$custContext/accounts-temp.csv
		rm $voicemailPath/voicemail-temp.csv
		echo "Cancelling..."
	fi

echo "Done"
