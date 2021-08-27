#!/bin/bash
. /etc/dbntool/scripts/functions.cfg


while getopts c:i:svh flag
do
	case "${flag}" in
		v) echo "passing flag ${flag}";;
		c) custContext=${OPTARG}; flag_mode="yes";;
		i) inFile=${OPTARG}; flag_mode="yes";;
		s) safe_mode="yes";;
		h) echo "Usage: dbntool file remove_user -c [custContext] -i [inputFile] (-s (safe mode))"; exit;;
		?) echo "invalid flag, exiting" >&2; exit;;
	esac
done


voicemailPath=/etc/asterisk
logFile=/etc/dbntool/changelog/removed_users.log
inFilePath="$(pwd $inFile)"

_check_infile () {
cd $inFilePath	
_validate_infile "$inFile"
if [[ $? -eq 1 ]] ; then
	echo "File type is: "
	file "$inFile"
	echo "file format invalid, reformat and try again, should be ASCII"
	exit 1
fi
}

_check_custdir () {
_cust_dircheck "$custContext"
if [[ $? -eq 1 ]] ; then
	echo "Customer context $custContext does not exist, exiting..."
	exit
fi
}

_import_file () {
cd "$dir_ccdbn"/"$custContext"
awk -F, '{print $3}' $inFilePath/$inFile > remove_temp.csv
grep -f remove_temp.csv accounts.csv > remove_pre.acc
grep -vf remove_temp.csv accounts.csv > remove_final.acc
grep -f remove_temp.csv $file_dbnvmconf > remove_pre.vm
grep -vf remove_temp.csv $file_dbnvmconf > remove_final.vm
}


_preview_remove () {
cd "$dir_ccdbn"/"$custContext"
echo "removing from accounts.csv:"
cat remove_pre.acc
echo
echo "removing from dbn_voicemail.conf:"
cat remove_pre.vm
}

_detect_dupes () {
if [[ ! -z $(grep -of "$dir_ccdbn"/"$custContext"/remove_temp.csv "$dir_ccdbn"/"$custContext"/accounts.csv | uniq -d) ]] ; then 
	echo "accounts.csv dupes detected!"
	grep -of "$dir_ccdbn"/"$custContext"/remove_temp.csv "$dir_ccdbn"/"$custContext"/accounts.csv | uniq -d
	return 1
elif [[ ! -z $(grep -of "$dir_ccdbn"/"$custContext"/remove_temp.csv $file_dbnvmconf | uniq -d) ]] ; then 
	echo "vm.conf dupes detected!"
	grep -of "$dir_ccdbn"/"$custContext"/remove_temp.csv $file_dbnvmconf | uniq -d
	return 1
fi
}

#auto mode
if [[ $flag_mode == "yes" ]] ; then
	if [[ -z "$custContext" || -z "$inFile" ]] ; then
		echo "Flag mode requires -c for Cust Context and -i for Input File"
		exit 1
	fi
	
	_import_file
	_check_infile
	
	if [[ $safe_mode == "yes" ]] ; then
		_preview_remove
		_detect_dupes
		exit
	else
		_check_custdir
		_detect_dupes
		if [[ $? -eq 1 ]] ; then
			echo "cancelling... duplicate numbers detected, correct and try again"
			exit
		fi
		
		cd $voicemailPath
		cp dbn_voicemail.conf _dbn_voicemail.conf
		mv "$dir_ccdbn"/"$custContext"/remove_final.vm dbn_voicemail.conf
		_set_permissions "/etc/asterisk/dbn_voicemail.conf"

		cd "$dir_ccdbn"/"$custContext" 
		cp accounts.csv _accounts.csv
		mv remove_final.acc accounts.csv

		#early exit to not put a ton of entries in the logs
		exit

		echo "logging removals..."
		pwd	
		echo "
		$(date)" >> /etc/dbntool/changelog/removed_users.log
		whoami >> /etc/dbntool/changelog/removed_users.log
		echo "removing from accounts.csv:" >> /etc/dbntool/changelog/removed_users.log
		cat remove_pre.acc >> /etc/dbntool/changelog/removed_users.log
		echo "
		removing from dbn_voicemail.conf:" >> /etc/dbntool/changelog/removed_users.log
		cat remove_pre.vm >> /etc/dbntool/changelog/removed_users.log

		echo "cleaning up"
		rm remove_*
		echo "done"
		exit
	fi
else


#wizard entry
if [[ ! -z $1 ]] ; then
	echo "don't pass any variables to use removal wizard, or use flag mode to pass -c and -i"
	exit
fi

_set_custContext
_check_custdir

read -p "DID to remove? " removeDID
grep -v $removeDID < $accountPath/$custContext/accounts.csv > $accountPath/$custContext/accounts-temp.csv
chmod 774 $accountPath/$custContext/accounts-temp.csv
grep -v $removeDID < $voicemailPath/dbn_voicemail.conf > $voicemailPath/voicemail-temp.csv
chmod 774 $voicemailPath/voicemail-temp.csv

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

#confirm removal
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
fi 

echo "Done"
