#1/bin/bash

inFile=$1
inFilepath="$(pwd $1)"

read -p "Customer Context? " custContext
cd /var/lib/asterisk/CCdbn/$custContext/

#remove EOL delimiter
tr -d '\r' < $inFilepath/$inFile > tempFile.csv

echo "accounts.csv"
awk -F ',' '{ print NR "," $1 " " $2 "," $3 }' ./tempFile.csv
echo
echo "vm_conf.add"
awk -F ',' '{ print $3 "=> 12345," $1 " " $2 ",,,"}' ./tempFile.csv

read -p "Print to accounts.csv and vm_conf.add? " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]] ; then
		mv ./tempFile.csv ./$inFile
		echo
		awk -F ',' '{ print NR "," $1 " " $2 "," $3 }'  $inFile > ./accounts.csv
		awk -F ',' '{ print $3 " ==> " $1 " " $2 ",,,"}'  $inFile > ./vm_conf.add
	else
		echo
		echo "Cancelling..."
	fi

