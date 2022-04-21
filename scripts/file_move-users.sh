#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

#validate flags
while getopts c:i:bvh flag
do
	case "${flag}" in
		v) echo "${flag} not yet implemented";;
		c) custContext=${OPTARG}; flag_mode="yes";;
		i) inFile=${OPTARG}; flag_mode="yes";;
		b) moveMode="bot";;
		h) echo "todo"; exit;;
		?) echo "invalid flag, exiting" >&2; exit;;
	esac
done

moveMode="top"

_userRemove () {
	awk -F, 'BEGIN {OFS=","}{print $3}' $inFile > /tmp/dbntool-usermove.tmp
	grep -vf /tmp/dbntool-usermove.tmp $dir_ccdbn/$custContext/accounts.csv > /tmp/dbntool.tmp
	cp /tmp/dbntool.tmp $dir_ccdbn/$custContext/accounts.csv
}

_userAdd () {
	> /tmp/dbntool-usermove.tmp
	i=1
	while IFS=, read -r first last userdid
	do
		echo "$i,$first $last,$userdid" >> /tmp/dbntool-usermove.tmp
		i=$((i+1))
	done < $inFile


if [[ $moveMode == "top" ]] ; then
	cat $dir_ccdbn/$custContext/accounts.csv >> /tmp/dbntool-usermove.tmp
	cp /tmp/dbntool-usermove.tmp $dir_ccdbn/$custContext/accounts.csv
else	
	cat /tmp/dbntool-usermove.tmp >> $dir_ccdbn/$custContext/accounts.csv
fi
}


_validate_infile $1

if [[ $flag_mode == "test" ]] ; then
	if [[ -z $custContext || -z $inFile ]] ; then
		echo "flag mode requires parameters -c for Customer Context and -i for input file"
		echo "exiting"
		exit 0
	else
		echo "Flag mode exec"

	fi
else
	if [[ -z $1 ]] ; then
		echo "Pass file to script to run in guided exec mode. Pass flags -c and -i to use flag exec mode."
		exit
	else
		inFile="$1"
	fi

	_set_custContext
	_userRemove
	_userAdd
	
	
	echo "script finished, check for errors before commiting and pushing to production"
	exit


fi
