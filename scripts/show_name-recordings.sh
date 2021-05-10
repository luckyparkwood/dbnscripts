#!/bin/bash


if [[ ! -z $1 ]] ; then
	mtime=$1
else
	mtime=7
fi


find /var/spool/asterisk/voicemail/ -name "*.wav" -mtime -$mtime -printf "%p -- " -exec date -r {} \;

fileCount=$(find /var/spool/asterisk/voicemail/ -name "*.wav" -mtime -$mtime | wc -l)

echo "Total recordings in the past $mtime days: $fileCount"
echo "done"


