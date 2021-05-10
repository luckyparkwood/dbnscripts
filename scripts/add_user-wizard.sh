#!/bin/bash 
. /etc/dbntool/scripts/functions.cfg

_set_custContext
_cust_contextcheck "\[$custContext\]" "/etc/asterisk/dbn_voicemail.conf"
if [[ ! $? -eq 0 ]] ; then
	echo "exiting..."
	exit	
fi

x=1
run=yes

while [ $run = "yes" ]
do
	read -p "User First Name? " userFirst
	read -p "User Last Name? " userLast
	read -p "User DID? " userDID
	echo "Add preview:
	$custContext/accounts.csv:
	$x,$userFirst,$userLast,$userDID
	
	dbn_voicemail.conf under [$custContext]:
	$userDID => 12345,$userFirst $userLast,,,
	"
	read -p "Add to $custContext/accounts.csv and dbn_voicemail.conf? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo "adding $userFirst,$userLast,$userDID to $custContext/accounts.csv"
		sed -i "1 i\$x,$userFirst,$userLast,$userDID" /var/lib/asterisk/CCdbn/$custContext/accounts.csv
		sed -i -e "/\[$custContext\]/,/^$/{s/^$/$userDID => 12345,$userFirst $userLast,,,\n&/" -e "}" /etc/asterisk/dbn_voicemail.conf
		read -p "Add another user?" -n 1 -r
		echo
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				(( x++ ))
			echo "starting over at $x..."
			else
				echo
				(( run = "no" ))
				echo
				echo "exiting..."
				exit
			fi
	else
		echo "exiting..."
		exit
	fi
done

