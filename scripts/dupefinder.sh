#!/bin/bash
. /etc/dbntool/scripts/functions.cfg


if [[ -z $1 ]] ; then
	#for f in "$(grep -o -E "[0-9]{11}" /etc/asterisk/dbn_voicemail.conf | uniq -d )" 
	#do grep "$f" /etc/asterisk/dbn_voicemail.conf ; done
	export IFS=$'\n'
	for i in $(grep -f <(grep -oE "[0-9]{11}" /etc/asterisk/dbn_voicemail.conf | sort | uniq -d) /etc/asterisk/dbn_voicemail.conf | sort | uniq | sed 's/\=/\\\=/g') 
	do 
		if [[ -z $i ]] ; then echo "no duplicates found" ; exit ; fi
		echo $i  $(sed -n '/'"$i"'/,/^$/p' <(tac /etc/asterisk/dbn_voicemail.conf) | grep "\[") | sed 's/\\\=/\=/g'  
	done





else
	custContext="$1"
	_cust_dircheck "$custContext"
	if [[ $? == 1 ]] ; then
		echo "dir not found, exiting"
		exit
	else
		echo "Duplicates found in "$custContext"/accounts.csv:"
		#grep -E "[0-9]{11}" /var/lib/asterisk/CCdbn/Chris/accounts.csv
		export IFS=$'\n'
		for i in $(grep -oE "[0-9]{11}" /var/lib/asterisk/CCdbn/"$custContext"/accounts.csv | sort | uniq -d)
		do
			if [[ -z $i ]] ; then echo "no duplicates found" ; exit ; fi
			grep "$i" /var/lib/asterisk/CCdbn/"$custContext"/accounts.csv
		done
		echo
		echo "Duplicates found in dbn_voicemail.conf in context ["$custContext"]:"
		export IFS=$'\n'
		for i in $(sed -n '/\['"$custContext"'\]/,/^$/p' /etc/asterisk/dbn_voicemail.conf | grep -oE "[0-9]{11}" | sort | uniq -d)
		do
			if [[ -z $i ]] ; then echo "no duplicates found" ; exit ; fi
			grep "$i" <(sed -n '/\['"$custContext"'\]/,/^$/p' /etc/asterisk/dbn_voicemail.conf)
		done
		
		#for f in "$(grep -o -E "[0-9]{11}" /var/lib/asterisk/CCdbn/$custContext/accounts.csv | uniq -d )" 
		#do
		#	if [[ -z $f ]] ; then echo "no duplicates found" ; exit ; fi	
		#	grep "$f" /etc/asterisk/dbn_voicemail.conf
       		#done

		
	fi
fi





