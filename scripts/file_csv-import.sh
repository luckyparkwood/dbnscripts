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
awk -F ',' '{ print NR "," $1 " " $2 "," $3 }' tempFile.csv > $dir_ccdbn/$custContext/accounts.csv
awk -F ',' '{ print $3 " => 12345," $1 " " $2 ",,,"}' tempFile.csv > $dir_ccdbn/$custContext/vm_conf.add
mv tempFile.csv $inFile
echo "accounts.csv and vm_conf.add created."
echo "done"
}	

_preview_parse () {
echo
echo "file additions:"
echo "accounts.csv"
awk -F ',' '{ print NR "," $1 " " $2 "," $3 }' tempFile.csv > acc-tempFile.csv
cat acc-tempFile.csv
echo
echo "vm_conf.add"
awk -F ',' '{ print $3 " => 12345," $1 " " $2 ",,,"}' tempFile.csv > vm-tempFile.csv
cat vm-tempFile.csv
}

if [[ ! $flag_mode == "yes" ]] ; then
	if [[ -z $inFile ]] ; then
		echo "Provide a file to parse or use options -c and -i to enable flag mode"
		exit
	else
		inFile="$1"
	fi
fi
	
cd "$(pwd $inFile)"

echo "File type is: "
file "$inFile"


_validate_infile "$inFile"
if [[ $? -eq 1 ]] ; then
	echo "file format invalid, reformat and try again"
	exit 1
fi

cp $inFile ./tempFile.csv
if [[ $flag_mode == "yes" ]] ; then
	if [[ $safe_mode == "yes" ]] ; then
		_preview_parse
		exit	
	elif [[ -z $custContext || -z $inFile ]] ; then
		echo "Flag mode requires -c for Cust Context and -i for Input File"
		exit 1
	fi

	if [[ -f $dir_ccdbn/$custContext/accounts.csv ]] ; then
		mv $dir_ccdbn/$custContext/accounts.csv $dir_ccdbn/$custContext/_accounts.csv
	fi
	_csv_parse
	exit
fi	

_preview_parse

read -p "Print to accounts.csv and vm_conf.add? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]] ; then
	if [[ -f "./accounts.csv" ]] ; then
		echo
		read -p "accounts.csv already exists, rename the old file to continue? " -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]] ; then
			echo	
			mv $dir_ccdbn/$custContext/accounts.csv $dir_ccdbn/$custContext/_accounts.csv
			_csv_parse
		else
			echo "cancelling..."
			rm tempFile.csv acc-tempFile.csv vm-tempFile.csv

		fi
	else
		echo
		_csv_parse
	fi
else
	echo
	echo "Cancelling..."
	rm tempFile.csv
fi

