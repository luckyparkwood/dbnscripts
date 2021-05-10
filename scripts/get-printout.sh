#!/bin/bash

if [[ -z $1 ]] ; then
read -p " Customer context? " custContext
else
	custContext=$1
fi

custAccount="$(grep -E -B1 "\($custContext," < /etc/asterisk/dbn_extensions.conf | grep -o -E "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]")"
custPin="$(grep -E ",$custContext$" < /var/lib/asterisk/CCdbn/record_passwords.csv | grep -o -E '[0-9][0-9][0-9][0-9][0-9]')"


echo "Dial by name recording number - 16178610612
Customer -     $custContext
DBN number -   ${custAccount}
Cust PIN -     ${custPin}"
