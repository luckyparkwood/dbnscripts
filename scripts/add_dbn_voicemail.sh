#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

while getopts c:svh flag
do
	case "${flag}" in
		v) echo "passing flag ${flag}";;
		c) custContext=${OPTARG}; flag_mode="yes";;
		s) safe_mode="yes";;
		h) echo "Usage: dbntool file push_dbn_voicemail.conf -c [custContext]"; exit;;
		?) echo "invalid flag, exiting" >&2; exit;;
	esac
done

if [[ ! $flag_mode == yes ]] ; then
	if [[ -z $1 ]] ; then
		_set_custContext
	else
		custContext=$1
	fi
fi

if [[ $safe_mode == "yes" ]] ; then
	_cust_contextcheck "[$custContext]" "/etc/asterisk/dbn_voicemail.conf"
	echo "context to be added"
	echo -e '['$custContext']' 
	cat ./vm-tempFile.csv
	exit
fi

echo "checking for /var/lib/asterisk/CCdbn/$custContext/vm_conf.add"
_file_check "/var/lib/asterisk/CCdbn/$custContext/vm_conf.add"
if [[ $? == 1 ]] ; then
	echo "file /var/lib/asterisk/CCdbn/$custContext/vm_conf.add not found..."
	echo "exiting"
	exit
fi

echo "checking for existing context $custContext in dbn_voicemail.conf"
_cust_contextcheck "[$custContext]" "/etc/asterisk/dbn_voicemail.conf"
if [[ $? -eq 0 ]] ; then
	echo "Use dbn add script to add to existing cust"
	exit
fi


_add_vmconf () {
	echo -e '['$custContext']' >> /etc/asterisk/dbn_voicemail.conf
	cat /var/lib/asterisk/CCdbn/$custContext/vm_conf.add >> /etc/asterisk/dbn_voicemail.conf
	echo >> /etc/asterisk/dbn_voicemail.conf	
	echo 'dbn_voicemail.conf updated.'
}

if [[ $flag_mode == "yes" ]] ; then
	_add_vmconf
	exit
fi

echo -e 'Adding: \n['$custContext']'
cat /var/lib/asterisk/CCdbn/$custContext/vm_conf.add
echo

read -p "Commit to dbn_voicemail.conf? " -n 1 -r
	if [[ $REPLY =~ ^[yY]$ ]] ; then
		echo
		_add_vmconf
	else
		echo
		echo "cancelling..."
		exit
	fi





