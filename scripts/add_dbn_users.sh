#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

while getopts c:i:Nvh flag
do
	case "${flag}" in
		N|v) echo "${flag} not yet implented"; exit;;
		c) custContext=${OPTARG}; flag_mode="yes";;
		i) inFile=${OPTARG}; flag_mode="yes";;
		h) echo "Usage: dbntool add users -c [custContext] -i [inputFile]"; exit;;
		?) echo "invalid flag, exiting" >&2; exit;;
	esac
done

_dbn_exist_file () {
i=1
while IFS=, read -r first last userdid
do
echo "$i,$first $last,$userdid" >> $dir_ccdbn/$custContext/temp.acc
i=$((i+1))
done < $inFile

while IFS=, read -r first last userdid
do
echo "$userdid => 12345,$first $last,,," >> $dir_ccdbn/$custContext/temp.vm 
done < $inFile
}

_dbn_exist_add () {
#perform the operations on the files
#accounts.csv
cat $dir_ccdbn/$custContext/accounts.csv >> $dir_ccdbn/$custContext/temp.acc
mv $dir_ccdbn/$custContext/temp.acc $dir_ccdbn/$custContext/accounts.csv

#dbn_voicemail.conf
while IFS=, read -r first last userdid
do
sed -i -e "/\[$custContext\]/,/^$/{s/^$/$userdid => 12345,$first $last,,,\n&/" -e "}" $file_dbnvmconf
done < $inFile
echo "new users added."
rm $dir_ccdbn/$custContext/temp.vm
}


_input_validation () {
_cust_contextcheck "\[$custContext\]" "$file_dbnvmconf"
if [[ ! $? -eq 0 ]] ; then
	echo "exiting..."
	exit
fi
#now handled by the flag importer
#_validate_infile "$inFile"
#if [[ $? -eq 1 ]] ; then
#	echo "file format invalid, reformat and try again"
#	exit
#fi
}

if [[ $flag_mode == "yes" ]] ; then
	if [[ $# -lt 4 ]] ; then
		echo "Flag mode requires -c for customer context and -i for input file"
		echo "exiting..."
		exit
	else
		_input_validation
		# execute functions
		_dbn_exist_file
		_dbn_exist_add
		echo "added users to $file_dbnvmconf and $dir_ccdbn/$custContext/accounts.csv"
		exit
	fi
fi


_set_inFile "$1"
if [[ $? -eq 1 ]] ; then
	echo "no input file selected, exiting"
	exit
fi
_set_custContext
_input_validation
_dbn_exist_file


#accounts.csv
#addition preview
echo "New lines to be added to accounts.csv: "
cat $dir_ccdbn/$custContext/temp.acc
echo

#dbn_voicemail.conf
#addition preview
echo "New lines to be added to dbn_voicemail.conf:"
cat $dir_ccdbn/$custContext/temp.vm
echo

read -p "Confirm the additions to accounts.csv and dbn_voicemail.conf? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
	_dbn_exist_add
else
	echo "cancelling..."
	rm $dir_ccdbn/$custContext/temp.acc
	rm $dir_ccdbn/$custContext/temp.vm
fi

