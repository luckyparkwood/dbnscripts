#!/bin/bash

originalPath=$PWD
inputFile=$1
#echo "$inputFile"
inputFilePath="$(pwd $1)"
#echo "$inputFilePath"

#take file input
if [ -z $1 ]; then
	echo "No input file selected. Exiting..."
	exit
else

	#ask for Cust Context
	read -p 'Enter Customer Context: ' custContext
	#echo $custContext

	#check if context exists
	if [ -d "/var/spool/asterisk/voicemail/$custContext" ]; then
		echo "Directory $custContext exists. Moving there..."
		cd /var/spool/asterisk/voicemail/$custContext

		echo "Input file - $inputFile"
		fileType="$(file $inputFilePath/$inputFile | awk -F': ' '{print $2}')"
		echo "File type = $fileType"
		if [[ $fileType == 'ASCII text' ]] ; then
			echo
			echo "File type is ASCII text, continuing..."
		
		else
			echo
			echo "Invisible characters or wrong file type... aborting..."
			exit
		fi	
			
	else
		echo "Directory $custContext does not exist. Exiting..."
		exit
	fi


fi


#backup current recordings
read -p "Backup current recordings in $PWD? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
	tar cvf $custContext.tar ./*
fi

read -p "Continue with swap? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
	#cp files from current directory to new directory
	echo "Creating new directories and copying files to new directories"
	awk -F ',' '{ system("cp -r ./" $3 " ./"$4) }' $inputFilePath/$inputFile
else
	echo "Cancelled. Exiting..."
	exit
fi
	

#delete directories matching old numbers
echo "Newly created files and directories: "

find ./ -mtime -1 -ls

read -p "Delete previous directories and recordings? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
	awk -F ',' '{ system ("rm -r " $3) }' $inputFilePath/$inputFile
fi

#cd $originalPath
