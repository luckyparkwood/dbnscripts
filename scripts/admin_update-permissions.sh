#!/bin/bash

chown :asterisk /var/lib/asterisk/CCdbn/*/
chown :asterisk /var/lib/asterisk/CCdbn/*/*                     
chmod 775 /var/lib/asterisk/CCdbn/*/
chmod 775 /var/lib/asterisk/CCdbn/*/*

chown :asterisk /etc/asterisk/dbn*
chmod 775 /etc/asterisk/dbn*
