#!/bin/bash

read -p "What is the Customer Context? " custContext
read -p "What is the old number? " oldNum
read -p "What is the new number? " newNum
sed -i "s/$oldNum/$newNum/" /var/lib/asterisk/CCdbn/$custContext/accounts.csv
sed -i "s/$oldNum/$newNum/" /etc/asterisk/dbn_voicemail.conf
cat /var/lib/asterisk/CCdbn/$custContext/accounts.csv | grep '$oldNum\|$newNum'
cat /etc/asterisk/dbn_voicemail.conf | grep '$oldNum\|$newNum'
