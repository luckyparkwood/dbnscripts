#!/bin/bash

date="$(date)"

#check for root
if [ `whoami` != root ]; then
	echo Please run this script as root or using sudo
	exit
fi

read -p "Comment for push?  " pushComment
echo "
Initiated by $USER on $date
Comment: $pushComment" >> /var/log/dbntool/push_2_prod.log

set -e

read -s -p "DBNadmin sudo password: " DBNPASS

echo "packaging tarball..."
cd /root
rm cloudcall_voicemail_full.tar
chown -R asterisk.asterisk /var/spool/asterisk/voicemail
chown -R asterisk.asterisk /etc/asterisk/dbn_*.conf
tar cvf cloudcall_voicemail_full.tar --exclude='/var/spool/asterisk/voicemail/default' /var/spool/asterisk/voicemail/ /etc/asterisk/dbn_*.conf
#scp cloudcall_voicemail_full.tar bbowles@172.20.40.60:cloudcall_voicemail_staging.tar
#scp cloudcall_voicemail_full.tar bbowles@172.20.40.61:cloudcall_voicemail_staging.tar
#scp cloudcall_voicemail_full.tar joelane@172.20.40.60:cloudcall_voicemail_staging.tar
#scp cloudcall_voicemail_full.tar joelane@172.20.40.61:cloudcall_voicemail_staging.tar
#scp cloudcall_voicemail_full.tar chrisbright@172.20.40.60:cloudcall_voicemail_staging.tar
#scp cloudcall_voicemail_full.tar chrisbright@172.20.40.61:cloudcall_voicemail_staging.tar
chmod 664 cloudcall_voicemail_full.tar


pwd
echo "sending dbn tar to db01..."
sshpass -p $DBNPASS scp cloudcall_voicemail_full.tar dbnadmin@172.20.40.60:cloudcall_voicemail_staging.tar
echo "reloading asterisk dialplan on db01..."
sshpass -p $DBNPASS ssh -t dbnadmin@172.20.40.60 "echo $DBNPASS | sudo -S /home/chrisbright/update_reload.sh"

echo "update to dbn01 complete, starting update to dbn02..." 

echo "sending dbn tar to db02..."
sshpass -p $DBNPASS scp cloudcall_voicemail_full.tar dbnadmin@172.20.40.61:cloudcall_voicemail_staging.tar
echo "reloading asterisk dialplan on db02..."
sshpass -p $DBNPASS ssh -t dbnadmin@172.20.40.61 "echo $DBNPASS | sudo -S /home/chrisbright/update_reload.sh"

echo "update to db02 complete..."
echo "done"
