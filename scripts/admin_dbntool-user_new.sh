#!/bin/bash

if [ `whoami` != root ]; then
	echo Please run this script as root using sudo
	exit
fi

read -p "Username for new dbntool user" userName
read -p "Password for new dbntool user:" userPasswd
read -p "email for new dbntool user:" USER.EMAIL

echo "adding user..."
useradd -m $userName
setting user passwd..."
echo -e "$userPasswd\n$userPasswd" | passwd $userName
echo "setting user shell"
sed -i 's/"$userName".*$/\1\/bin\/bash/' /etc/passwd
echo "adding to groups"
sudo usermod -aG asterisk,sshuser $userName
echo "setting up git user config"
git config --global user.name "$userName"
git config --global user.email ""$userName"@cloudcall.com"

