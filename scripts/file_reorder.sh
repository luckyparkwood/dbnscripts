#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

inFile="$1"
inFilePath="$(pwd "$inFile")"


if [[ -z $1 ]] ; then
	echo "Pass file to script to run in guided exec mode."
	exit
fi

cd $inFilePath

cat $inFile | grep -n '' | sed -E 's/:[0-9]+//g' >> "$inFile".reorder

_cleanup_files 

echo "Accounts re-ordered, saved as $inFile.reorder"
