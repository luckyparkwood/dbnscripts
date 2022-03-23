#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

#validate flags
while getopts c:i:vh flag
do
	case "${flag}" in
		v) echo "${flag} not yet implemented";;
		c) custContext=${OPTARG}; flag_mode="yes";;
		i) inFile=${OPTARG}; flag_mode="yes";;
		h) echo "todo"; exit;;
		?) echo "invalid flag, exiting" >&2; exit;;
	esac
done

#exit script if there are any errors, since this deletes data
set -e

tempFile="/tmp/dbntool_change-updatedbn.tmp"
temp2="/tmp/dbntool2.tmp"
temp3="/tmp/dbntool3.tmp"

_accounts2input () {
	#convert accounts file to input format
	cat /var/lib/asterisk/CCdbn/$custContext/accounts.csv | sed 's/[0-9]*,//' | sed 's/ /,/g' > /var/lib/asterisk/CCdbn/"$custContext"/_input.accounts
	custSetup="/var/lib/asterisk/CCdbn/"$custContext"/_input.accounts"
}

_diffFile () {
	#sort and diff, remove rows without user info, save as diff
	bash -c "diff <(sort "$custSetup") <(sort "$inFile")" | grep -E "[<>]" > $temp2 && cp $temp2 $tempFile
}

_sameFile () {
	awk -F '[ ,]' '{print $NF}' $tempFile | sort | uniq > $temp2
	grep -vf $temp2 $tempFile | sed 's/ /,/g' | sort -t , -k2,2  > $temp3 && cp $temp3 ~/$custContext.same

}

_vmMovefile () {
	#print 2nd and 3rd columns containing names with comma delimiter, sort and filter to show duplicates, filter duplicates to only show one line, save as name pattern file
	awk -F '[ ,]' '{print $2","$3}' $tempFile | sort -k 2 | uniq -D | uniq > $temp2
	#search in diff file using pattern file to show lines that might need migrating, sed to change space to comma, sort on column 3 using comma as delimiter > save as patch file
	grep -f $temp2 $tempFile | sed 's/ /,/g' | sort -t , -k3,3 -k1,1 > $temp3 && cp $temp3 $tempFile
	#combine lines with a removal and addition on same line
	cat $tempFile | awk -F, -v ORS="" 'a!=$2{a=$2; $0=RS $0","} a==$1{2sub($1"2",";") } 1' > $temp2 && cp $temp2 $tempFile
	#remove lines with consecutive >.*> or <.*<
	grep -v '<.*<\|>.*>' $tempFile > $temp2 && cp $temp2 $tempFile
	#remove empty lines
	sed -i '/^$/d' $tempFile
	#use output to create csv for did migration
	awk -F, 'BEGIN {OFS=","} {print $2,$3,$4,$8}' $tempFile > ~/$custContext.vm-move
}

_validate_infile $1

if [[ $flag_mode == "test" ]] ; then
	if [[ -z $custContext || -z $inFile ]] ; then
		echo "flag mode requires parameters -c for Customer Context and -i for input file"
		echo "exiting"
		exit 0
	else
		echo "Flag mode exec"
		_accounts2input
		_diffFile

	fi
else
	if [[ -z $1 ]] ; then
		echo "Pass file to script to run in guided exec mode. Pass flags -c and -i to use flag exec mode."
		exit
	else
		inFile="$1"
	fi

	_set_custContext
	echo "converting current customer accounts.csv to input format"
	_accounts2input
	echo "generating diff between the two files"
	_diffFile
	echo "parsing for numbers whose account names have changed"
	_vmMovefile
	echo "for vm-move input file, check home directory for vm-move file named "~/$custContext.vm-move""
	echo "removing users current customer setup"
	dbntool remove users -c "$custContext" -i "$custSetup"
	echo "add users from new list"
	dbntool add users -c "$custContext" -i "$inFile"
	echo "script finished, check for errors before commiting and pushing to production"
	exit

fi



