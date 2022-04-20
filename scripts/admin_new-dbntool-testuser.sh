#!/bin/bash

if [ `whoami` != root ]; then
	echo Please run this script as root using sudo
	exit
fi

read -p "Username for new dbntool user" userName
read -p "Password for new dbntool user:" userPasswd
echo "home directory:"

find /home/ -type d -name "$userName"
echo "user password"
if grep -q "$userName" /etc/shadow; then echo "user found"; if grep -q "$userName:\*:" /etc/shadow; then echo "no password found"; else echo "password found"; fi; else echo "user not found"; fi
echo "shell set:"
cat /etc/passwd | grep "$userName"
echo "user groups:"
sudo groups $userName
echo "show git configs"
git config --list | grep "user."
echo "test ssh login"
sshpass -p "$userPasswd" ssh -l $userName 172.31.36.3 | exit
echo "test dbntool"
dbntool show customer-info all
echo "test dbnpush"
echo | sudo dbnpush
echo "test git setup"
git commit --allow-empty -m "empty test commit for user $userName"
