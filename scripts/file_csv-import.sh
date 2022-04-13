#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

while getopts c:i:svh flag
do
	case "${flag}" in
		v) echo "passing flag ${flag}";;
		c) custContext=${OPTARG}; flag_mode="yes";;
		i) inFile=${OPTARG}; flag_mode="yes";;
		s) safe_mode="yes";;
		h) echo "Usage: dbntool file csv-import -c [custContext] -i [inputFile] (-s (safe mode))"; exit;;
		?) echo "invalid flag, exiting" >&2; exit;;
	esac
done


_csv_parse() {
awk -F ',' '{ print NR "," $1 " " $2 "," $3 }'  /tmp/dbntool-tempFile.csv > $dir_ccdbn/$custContext/accounts.csv
awk -F ',' '{ print $3 " => 12345," $1 " " $2 ",,,"}'  /tmp/dbntool-tempFile.csv > $dir_ccdbn/$custContext/vm_conf.add
mv  /tmp/dbntool-tempFile.csv $inFile
echo "accounts.csv and vm_conf.add created."
echo "setting owner and permissions for new files"
_set_permissions
echo "done"
}	

_preview_parse () {
echo
echo "file additions:"
echo "accounts.csv"
awk -F ',' '{ print NR "," $1 " " $2 "," $3 }'  /tmp/dbntool-tempFile.csv > /tmp/dbntool-acc-tempFile.csv
cat /tmp/dbntool-acc-tempFile.csv
echo
echo "vm_conf.add"
awk -F ',' '{ print $3 " => 12345," $1 " " $2 ",,,"}'  /tmp/dbntool-tempFile.csv >  /tmp/dbntool-vm-tempFile.csv
cat  /tmp/dbntool-vm-tempFile.csv
}

_set_permissions(){
#chown -Rc :asterisk /var/lib/asterisk/CCdbn/$custContext/
chmod -c 775 /var/lib/asterisk/CCdbn/$custContext/
}

if [[ ! $flag_mode == "yes" ]] ; then
	if [[ -z $1 ]] ; then
		echo "Provide a file to parse or use options -c and -i to enable flag mode"
		exit
	else
		inFile="$1"
	fi
fi
	
cd "$(pwd $inFile)"



_validate_infile "$inFile"
if [[ $? -eq 1 ]] ; then
	echo "File type is: "
	file "$inFile"
	echo "ERROR - file format invalid, reformat and try again, should be ASCII"
	exit 1
fi

cp $inFile ./tempFile.csv
if [[ $flag_mode == "yes" ]] ; then
	if [[ -f "./accounts.csv" ]] ; then
		echo "WARNING - accounts.csv already exists for this customer. continuing in flag mode wil overwrite the current accounts.csv file."
	fi
	if [[ $safe_mode == "yes" ]] ; then
		_preview_parse
		exit	
	elif [[ -z $custContext || -z $inFile ]] ; then
		echo "Flag mode requires -c for Cust Context and -i for Input File"
		exit 1
	fi
	_csv_parse
	exit
fi	

read -p "Customer Context? " custContext
cd $dir_ccdbn/$custContext
_preview_parse
read -p "Print to accounts.csv and vm_conf.add? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]] ; then
	echo
	_csv_parse
	_cleanup_files
else
	echo
	echo "Cancelling..."
	_cleanup_files
fi

echo "done"
