#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

#validate flags
while getopts c:i:bsvh flag
do
	case "${flag}" in
		v) echo "${flag} not yet implemented";;
		c) custContext=${OPTARG}; flag_mode="yes";;
		i) inFile=${OPTARG}; flag_mode="yes";;
		b) bulk_mode="yes";;
		s) safe_mode="yes";;
		h) echo "Usage: dbn_directory (-c [custContext] -i [inputFile]) OR (-b (bulk mode) [custContext1 custContext2])"; exit;;
		?) echo "invalid flag, exiting" >&2; exit;;
	esac
done

_set_permissions(){
	chown -Rc :asterisk /var/lib/asterisk/CCdbn/$custContext/
	chmod -Rc 774 /var/lib/asterisk/CCdbn/$custContext/
}

if [[ $bulk_mode == "yes" ]] ; then
i=1;
j=$#;
while [ $i -le $(( $j-1 )) ] 
do
	echo "Make Dir - $i: $3";
	custContext=$3

	if mkdir /var/lib/asterisk/CCdbn/$custContext ; then
		echo "Customer Directory $custContext created."
		echo "Creating recording PIN for $custContext"
		/etc/dbntool/scripts/new_recording_pin.sh $custContext
		_set_permissions

	else
		echo "ERROR - Create directory failed."
	fi
	i=$((i + 1));
	shift 1;
done
echo "done"
exit
fi

if [[ $flag_mode == "yes" ]] ; then
	if [[ -z $custContext || -z $inFile ]] ; then
		echo "flag mode requires parameters -c for Customer Context and -i for input file to move into new directory"
		echo "exiting"
		exit 0
	elif [[ $safe_mode == "yes" ]] ; then
		if [[ -d $dir_CCdbn/$custContext ]] ; then
			echo "WARNING - Directory $custContext exists"
		else 
			echo "INFO - Directory $custContext does not exist"
		fi
		if grep  "$custContext" "$dir_ccdbn"record_passwords.csv ; then
			echo "WARNING - Customer PIN for $custContext exists"
			exit
		else
			echo "INFO - Customer PIN for $custContext does not exist"
			exit
		fi	



	else 
		echo "Making Directory $custContext";
		if mkdir /var/lib/asterisk/CCdbn/$custContext ; then
			echo "Customer Directory $custContext created."
			echo "Creating recording PIN for $custContext"
			/etc/dbntool/scripts/new_recording_pin.sh $custContext
			mv $inFile /var/lib/asterisk/CCdbn/$custContext/
			echo "$inFile moved to /var/lib/asterisk/CCdbn/$custContext/"
			echo "setting directory and file permissions"
			_set_permissions
			echo "done"
			exit
		else
			echo "ERROR - Create directory and PIN failed."
			exit 1
		fi
	fi	
else
	if [[ -z $1 ]] ; then
		_set_custContext
	else
		 custContext=$1
	fi

	if mkdir /var/lib/asterisk/CCdbn/$custContext ; then
		echo "Customer Directory $custContext created."
		cd /var/lib/asterisk/CCdbn/$custContext
		echo "moved to /var/lib/asterisk/CCdbn/$custContext"
		read -p "create new VM PIN? " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]] ; then
			/etc/dbntool/scripts/new_recording_pin.sh $custContext
		else
			echo "create vm pin failed"
		fi
		echo "done"
	else
		echo "Create directory failed."
	fi
fi
