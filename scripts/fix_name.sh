#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

while getopts i:b:svh flag
do
	case "${flag}" in
		v) echo "${flag} not yet implemented"; exit;;
		i) inFile=${OPTARG}; flag_mode="yes";;
		b) bulk_mode="yes";;
		h) echo "Usage: dbntool file fix-name (-i [inputFile]) OR (-b (bulk mode) [inputFile1, inputFile2])) -v (verbose)"; exit;;
		s) safe_mode="yes";;
		?) echo "invalid flag, exiting" >&2; exit;;
	esac
done

_fix_name () {
	# remove garbage CLRF and BOM characters
	tr -d '\r' < $fileName | tr -cd '\11\12\15\40-\176' > tempFile.csv
	# remove header
	sed -r -i '1{/(Phone|First|Last|Number)/d;}' tempFile.csv
	# remove double, leading, and trailing spaces
	sed -r -i 's/(^| |$){2,}//g' tempFile.csv
       	# handle double, leading, and trailing delimiters
	sed -r -i -e 's/( )*,( )*|(,){2,}/,/g' -e 's/^,|,$//g'  tempFile.csv
	# adding leading 1 to any number not in 1NPANXXNNNN format
	sed -r -i 's/(^|,)([0-9]{10})(,|$)/\11\2\3/g' tempFile.csv
	# remove any " ' " characters
	sed -i "s/'//g" tempFile.csv
	# rearrange columns if DID is in first or second column
	awk -i inplace -F',' 'BEGIN{ OFS="," } { if ( $1 ~/[0-9]{10}/) print $2,$3,$1; else if ( $2 ~/[0-9]{10}/) print $1,$3,$2; else print $1,$2,$3 }' tempFile.csv
	
if [[ $safe_mode == "yes" ]] ; then
	if [[ ! "$fileName" == "$inFile" ]] ; then
		rm "$fileName"
	fi
	file tempFile.csv
	echo
	cat tempFile.csv
	exit
else
	echo "Cleaning up and saving file as $fileName"
	mv tempFile.csv $fileName
	
	exit
fi
}

_check_colNum () {
if [[ $(head -1 $fileName | awk -F, '{print NF}') -lt 3 ]] ; then
	echo "less than 3 columns found, reformat and try again"
	exit
fi
}

if [[ $bulk_mode == "yes" ]] ; then
x=1;
j=$#;
while [ $x -le $(( $j-2 )) ] 
do
	echo "File $x: $3";
	inFile="$3"
	fileName="$(ls "$3" | sed "s/ //g")"
	_check_colNum
	_fix_name
	x=$((x + 1));
	shift 1;
done
echo "done"
exit
fi	

if [[ ! $flag_mode == "yes" ]] ; then
	cd "$(pwd "$1")"
	inFile="$1"
	fileName="$(ls "$1" | sed "s/ //g")"
	read -p "Backup source file $1? Y/N " -n 1 -r
       	if [[ $REPLY =~ ^[Yy]$ ]] ; then
		echo
		cp "$1" "$fileName"
		
	fi
else
	cd "$(pwd "$inFile")"
	fileName="$(ls "$inFile" | sed "s/ //g")"
	if [[ $safe_mode == "yes" ]] ; then
		if [[ ! "$inFile" == "$fileName" ]] ; then
			cp "$inFile" "$fileName"
		fi
	else	
		rename "s/ //g" "$inFile"
	fi
fi



_check_colNum
# run fix
_fix_name

echo "done"
