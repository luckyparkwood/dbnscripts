#!/bin/bash

date="$(date)"

read -p "Comment for push?  " pushComment
echo "
Initiated by $USER on $date
Comment: $pushComment" >> /var/log/dbntool/push_2_prod.log

set -e

cd /root
#need to remove tar storage and execution from root folder, move to /etc/asterisk
#cd /etc/asterisk
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
#need to check if scp is affected by ssh keyless entry
scp cloudcall_voicemail_full.tar dbnadmin@172.20.40.60:cloudcall_voicemail_staging.tar
scp cloudcall_voicemail_full.tar dbnadmin@172.20.40.61:cloudcall_voicemail_staging.tar
#need to set up keyless ssh on dbnadmin
#move remote script execution to dbnadmin
