#!/bin/bash

chown :asterisk /var/lib/asterisk/CCdbn/*/
chown :asterisk /var/lib/asterisk/CCdbn/*/*                     
chmod 774 /var/lib/asterisk/CCdbn/*/
chmod 774 /var/lib/asterisk/CCdbn/*/*

chown :asterisk /etc/asterisk/dbn*
chmod 664 /etc/asterisk/dbn*
