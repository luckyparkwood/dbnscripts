#!/bin/bash
. /etc/dbntool/scripts/functions.cfg

while getopts nh flag
do
	case "${flag}" in
		n) name_only="yes"; flag_mode="yes";;                
		h) _help_search "DBNPUSH"; exit ;;
		?) echo "invalid flag" >&2; exit 1;;
	esac
done


date="$(date)"

#check for root
if [ `whoami` != root ]; then
	echo Please run this script as root using sudo
	exit
fi

read -p "Comment for push?  " pushComment
echo
if [[ -z $pushComment ]] ; then
	echo "comment cannot be empty"
	exit
else
	echo "Initiated by $USER on $date \nComment: $pushComment" >> /var/log/dbntool/push_2_prod.log
fi
#set -e

#read -s -p "DBNadmin sudo password: " DBNPASS

echo "packaging tarball..."
cd /etc/asterisk
rm cloudcall_voicemail_full.tar

#ownership validation
if [ 'find /var/spool/asterisk/voicemail/ ! -user asterisk | grep -q .' -eq 0 ] ; then 
	echo "Voicemail file ownership error, exiting"
	exit
else
	echo "no permission error found"		
fi

if [ 'find /etc/asterisk/ -name "dbn_*.conf" ! -user asterisk | grep -q .' -eq 0 ] ; then 
	echo "dbn_*.conf ownership error, exiting"
	exit
else
	echo "no permission error found"
fi

	
chown -R asterisk.asterisk /var/spool/asterisk/voicemail
chown -R asterisk.asterisk /etc/asterisk/dbn_*.conf

if [[ $name_only == "yes" ]]; then
	tar cvf cloudcall_voicemail_full.tar --exclude='/var/spool/asterisk/voicemail/default' /var/spool/asterisk/voicemail/
else
	tar cvf cloudcall_voicemail_full.tar --exclude='/var/spool/asterisk/voicemail/default' /var/spool/asterisk/voicemail/ /etc/asterisk/dbn_*.conf
fi

#scp cloudcall_voicemail_full.tar chrisbright@172.20.40.60:cloudcall_voicemail_staging.tar
#scp cloudcall_voicemail_full.tar chrisbright@172.20.40.61:cloudcall_voicemail_staging.tar
chmod 664 cloudcall_voicemail_full.tar


pwd
echo "sending dbn tar to db01..."
#sshpass -p $DBNPASS scp cloudcall_voicemail_full.tar dbnadmin@172.20.40.60:cloudcall_voicemail_staging.tar
scp cloudcall_voicemail_full.tar dbnadmin@172.20.40.60:cloudcall_voicemail_staging.tar
echo "reloading asterisk dialplan on db01..."
#sshpass -p $DBNPASS ssh -t dbnadmin@172.20.40.60 "echo $DBNPASS | sudo -S /home/chrisbright/update_reload.sh"
ssh dbnadmin@172.20.40.60 /home/dbnadmin/update_reload.sh

echo "update to dbn01 complete, starting update to dbn02..." 

echo "sending dbn tar to db02..."
#sshpass -p $DBNPASS scp cloudcall_voicemail_full.tar dbnadmin@172.20.40.61:cloudcall_voicemail_staging.tar
scp cloudcall_voicemail_full.tar dbnadmin@172.20.40.61:cloudcall_voicemail_staging.tar

echo "reloading asterisk dialplan on db02..."
#sshpass -p $DBNPASS ssh -t dbnadmin@172.20.40.61 "echo $DBNPASS | sudo -S /home/chrisbright/update_reload.sh"
ssh dbnadmin@172.20.40.61 /home/dbnadmin/update_reload.sh

echo "update to db02 complete..."
echo "done"
