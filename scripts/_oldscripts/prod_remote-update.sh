#!/bin/sh

set -e
#need to change remote script location to dbnadmin home dir
ssh -t dbnadmin@172.20.40.60 "sudo /home/chrisbright/update_reload.sh"

ssh -t dbnadmin@172.20.40.61 "sudo /home/chrisbright/update_reload.sh"
