#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

while getopts c:d:svh flag
do
	case "${flag}" in
		v) echo "passing flag ${flag}";;
		c) custContext=${OPTARG}; flag_mode="yes";;
		d) dbnNum=${OPTARG}; flag_mode="yes";;
		s) safe_mode="yes";;
		h) echo "Usage: push_dbn_extensions -c [custContext] -d [dbnNumber]"; exit;;
		?) echo "invalid flag, exiting" >&2; exit;;
	esac
done

if [[ $flag_mode == "yes" ]] ; then
	if [[ -z $custContext || -z $dbnNum ]] ; then
		echo "Flag mode requires both parameters -c and -d passed from the command line"
		exit
	fi	
else
	if [[ -z $1 ]] ; then
		_set_custContext
	else
		custContext=$1
	fi
	read -p 'What is the customer DBN Number?: ' dbnNum
fi


if [[ $safe_mode == "yes" ]] ; then
	_cust_contextcheck "$custContext" "/etc/asterisk/dbn_extensions.conf"
	echo "context to be added..."
	echo -e "exten => $dbnNum,1,Answer()\nsame  => n,Directory($custContext,callSYN,b)\nsame  => n,Hangup"
	echo
	echo "checking dbn_extensions.conf for $dbnNum..."
	if grep -q " $dbnNum," /etc/asterisk/dbn_extensions.conf; then
		echo "WARNING - dbn Number $dbnNum FOUND in dbn_extensions.conf"
	else
		echo "INFO - dbn Number $dbnNum not found in dbn_extensions.conf"
	fi
	exit
fi

echo "checking for customer directory /var/lib/asterisk/CCdbn/$custContext/"
_cust_dircheck "$custContext"
if [[ $? == 1 ]] ; then
	echo "ERROR - Directory $custContext not found. Check context name, or customer not likely setup"
	echo "exiting"
	exit
fi

echo "checking dbn_extensions.conf for $custContext"
_cust_contextcheck "$custContext" "/etc/asterisk/dbn_extensions.conf"
if [[ $? == 0 ]] ; then
	echo "ERROR - Customer $custContext exists, exiting..."
	exit
fi

if grep -q " $dbnNum," /etc/asterisk/dbn_extensions.conf; then
	echo "ERROR - dbn number $dbnNum exists, exiting"
	exit
fi


if [[ $flag_mode == "yes" ]] ; then
	echo -e "\nexten => $dbnNum,1,Answer()\nsame  => n,Directory($custContext,callSYN,b)\nsame  => n,Hangup" >> /etc/asterisk/dbn_extensions.conf
	echo 'dbn_extensions.conf updated.'
else
	echo -e "exten => $dbnNum,1,Answer()\nsame  => n,Directory($custContext,callSYN,b)\nsame  => n,Hangup"
	read -p "Commit to dbn_extensions.conf? " -n 1 -r
	       if [[ $REPLY =~ ^[yY]$ ]] ; then
        	       echo
	               echo -e "\nexten => $dbnNum,1,Answer()\nsame  => n,Directory($custContext,callSYN,b)\nsame  => n,Hangup" >> /etc/asterisk/dbn_extensions.conf
        	       echo 'dbn_extensions.conf updated.'
	       else
        	       echo
	               echo "canceling..."
        	       exit
	       fi
fi
