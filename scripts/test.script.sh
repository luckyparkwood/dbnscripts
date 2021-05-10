#/bin/bash
. /etc/dbntool/scripts/functions.cfg

_set_custContext
echo $custContext


_test_dircheck () {
echo "Checking for Cust directory..."
if [[ -d "/var/lib/asterisk/CCdbn/$1" ]] ; then
	echo "$1 found..."
	return 0
else
	echo "$1 not found..."
	return 1
fi
}

_test_dircheck $custContext


if [[ $? -eq 0 ]] ; then
	echo "directory exists"
elif [[ $? -eq 1 ]] ; then
	echo "directory does not exist"
fi

