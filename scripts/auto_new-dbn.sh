#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

flag_mode="yes"
safe_mode="yes"

while getopts c:i:d:Fsvh flag
do
	case "${flag}" in
		v) echo "${flag} not yet implented"; exit;;
		c) custContext=${OPTARG};;
		i) inFile=${OPTARG};;
		d) dbnNum=${OPTARG};;
		s) safe_mode="yes";;
		F) enable_force="yes";;
		h) echo "Usage: dbntool auto new-dbn -i [inputFile] -c [custContext] -d [dbnNumber] -F (Force, Disable Safe Mode)"; exit;;
		?) echo "invalid flag, exiting" >&2; exit;;
	esac
done

if [[ -z $custContext || -z $inFile || -z $dbnNum ]] ; then
	echo "All variables -i -c -d  must be present to run in Auto mode. Runs in Safe Mode by default or with -s to preview changes. Run with -F to force DBN creation."
	exit
fi

if [[ $enable_force == "yes" ]] ; then
	safe_mode="no"
fi
if [[ $safe_mode == "yes" ]] ; then
	echo "
	STARTING DRY RUN
	"
	cd "$(pwd $inFile)"
	echo "================ input file..."
	if [[ ! "$inFile"  == *?.csv ]] ; then echo "file not in .csv format. exiting." ; exit ; fi
	file "$inFile"
	echo
	cat "$inFile"
	echo
	echo "================ formatting inputFile..."
	dbntool file fix-name -s -i "$inFile"
	mv ./tempFile.csv ./fix-tempFile.csv
	echo
	echo "================ checking directory and recording PIN..."
	dbntool new dbn-directory -s -c $custContext -i ./fix-tempFile.csv
	echo 
	echo "================ testing csv-import..."
	dbntool file csv-import -s -i ./fix-tempFile.csv
	echo
	echo "================ testing dbn_voicemail add..."
	dbntool file push_dbn_voicemail.conf -s -c $custContext 
	echo
	echo "================ testing dbn_extensions add..."
	dbntool file push_dbn_extensions.conf -s -c $custContext -d $dbnNum
	echo
	echo "
	DRY RUN FINISHED
	
	add -F flag to run in full exec mode
	"
	rm tempFile.csv fix-tempFile.csv acc-tempFile.csv vm-tempFile.csv
	exit
fi

_err_check () {
if [[ $? -eq 1 ]] ; then
	echo "exiting with error status $?"
	exit
fi
}

# navigate to source file directory
cd "$(pwd $inFile)"

# run fix-name tool to validate inFile
dbntool file fix-name -i "$inFile"
_err_check
inFile="$(echo "$inFile" | sed 's/ //g')"

# create new directory and PIN for new DBN
dbntool new dbn-directory -c "$custContext" -i "$inFile"
_err_check
cd "$dir_ccdbn""$custContext"

# process inputFile to create accounts.csv and vm_conf.add
dbntool file csv-import -c "$custContext" -i "$inFile"
_err_check

# push vm_conf.add to dbn_voicemail.conf
dbntool file push_dbn_voicemail.conf -c $custContext 

#create context and add dbnNumber to dbn_extensions.conf
dbntool file push_dbn_extensions.conf -c $custContext -d $dbnNum

echo "New DBN for $custContext created and added to production files. Check git diff for errors before pushing to production servers."
echo "finished"
