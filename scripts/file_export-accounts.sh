#!/bin/bash

. /etc/dbntool/scripts/functions.cfg


while getopts ph flag
do
	case "${flag}" in
		p) print_only="yes" ;;
		h) _help_search "DBNPUSH"; exit ;;
		?) echo "invalid flag" >&2; exit 1;;
	esac
done

if [[ -z $1 ]] ; then
        read -p " Customer context? " custContext
else
	if [[ $print_only == "yes" ]] ; then
		custContext=$2
	else
		custContext=$1
	fi
fi

if [[ ! $print_only == "yes" ]] ; then
	#reorder accounts before export
	cd /var/lib/asterisk/CCdbn/$custContext/
	#removing accounts file backup, using git instead
	#cp -p accounts.csv _accounts.csv
	#cat _accounts.csv | grep -n '' | sed -E 's/:[0-9]+//g' > accounts.csv
	cat accounts.csv | grep -n '' | sed -E 's/:[0-9]+//g' > /tmp/dbntool-reorder
	cp /tmp/dbntool-reorder accounts.csv
	_cleanup_files

	#old ad-hoc method
	#cp /var/lib/asterisk/CCdbn/$custContext/accounts.csv /home/chris.bright/htmlchris/"$custContext"-dbn.$(date +"%Y%m%d").csv
	#chmod 644 /home/chris.bright/htmlchris/"$custContext"-dbn.$(date +"%Y%m%d").csv

	#echo "$custContext/accounts.csv copied to htmlchris/ as "$custContext"-dbn.$(date +"%Y%m%d").csv"
	#echo
	#echo "$custContext Accounts available via http link below (CCVPN must be on):
	#http://172.31.36.3/chris/$custContext"-dbn.$(date +"%Y%m%d").csv""
	#echo


	#new daily update
	cp /var/lib/asterisk/CCdbn/$custContext/accounts.csv /var/www/html/ccdbn/$custContext/accounts.csv
	echo "$custContext/accounts.csv copied to /var/www/html/ccdbn/$custContext/accounts.csv"
else
	echo "Print only mode, files not updated or reordered"
fi

echo
echo "$custContext Accounts available via http link below (CCVPN must be on):
http://172.31.36.3/ccdbn/$custContext/accounts.csv

All current customer setups can now be browsed via http://172.31.36.3/ccdbn/
This directory is synced daily and on request."
echo


#dbntool show get-printout "$custContext"
custAccount="$(grep -E -B1 "\($custContext," < /etc/asterisk/dbn_extensions.conf | grep -o -E "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]")"
custPin="$(grep -E ",$custContext$" < /var/lib/asterisk/CCdbn/record_passwords.csv | grep -o -E '[0-9][0-9][0-9][0-9][0-9]')"


echo "Dial by name recording number - 16178610612
Customer -     $custContext
DBN number -   ${custAccount}
Cust PIN -     ${custPin}"
