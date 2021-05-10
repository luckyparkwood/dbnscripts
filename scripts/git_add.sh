#!/bin/bash

#adds new and modified files to git stage for commit

git add -A /etc/dbntool/
git add -u /etc/dbntool/
git add -A /var/lib/asterisk/CCdbn/
git add -u /var/lib/asterisk/CCdbn/
git add -u /etc/asterisk/dbn_voicemail.conf
git add -u /etc/asterisk/dbn_extensions.conf

echo "
git add -A /etc/dbntool/
git add -u /etc/dbntool/
git add -A /var/lib/asterisk/CCdbn/
git add -u /var/lib/asterisk/CCdbn/
git add -u /etc/asterisk/dbn_voicemail.conf
git add -u /etc/asterisk/dbn_extensions.conf
"
