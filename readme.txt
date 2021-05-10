LAST UPDATED OCT 2 2020
LOTS OF THINGS ARE OUT OF DATE HERE

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CLOUDCALL DBN CREATION / MANAGEMENT TOOL

Source added to ~/bash.rc for Bash completion.

Report bugs to: chris.bright@cloudcall.com


Directories name/affected by this tool:
~/dbntool/
/var/lib/asterisk/CCdbn/
/etc/asterisk/
/var/spool/asterisk/voicemail/
/home/chris.bright/changelog/
~/.bash.rc
/bin/bash
/usr/share/bash-completion/completions/

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Usage: [ -function ] [ subfunction ] [ file | parameter ]

#need to update logging description to using git
-log
	backup				Backs up the current production tarball, dbn_extensions.conf, dbn_voicemail.conf, and record_passwords.csv
	write-changes			Write current changes to change log /home/chris.bright/changelog/			
	clean-up [ NUM ]		Remove backups older than [ NUM ] of days. (Default 90)

#csv import is now located in file options
-new
	customer-dbn			Set customer context and ask to create directory. Asks to create directory and import csv using the specified context.
	recording-pin [ STRING ]	Pass or prompt for customer context to create new recording pin for the specified context 
	csv-import [ FILE ] 		Specify context to import linked CSV to create necessary files accounts.csv and vm_conf.add. Will fail if no file is specified.
					Only takes filenames with no special characters that need escaping.

#disabled add user bc it wasnt working right
-add
	user 				Adds single user to existing customer accounts.csv and dbn_voicemail.conf.
	bulk-add [ FILE ]		Import CSV to bulk add users to existing accounts.csv and dbn_voicemail.conf.

#chang name and number functions have been rolled into change-field function
-change
	name				Change single user name in existing customer accounts.csv and dbn_voicemail.conf.
	number				Change single user number in existing customer accounts.csv and dbn_voicemail.conf.
	bulk-change-name [ FILE ]	Import CSV to bulk change name information in accounts.csv and dbn_voicemail.conf. Column order: OldFirst,OldLast,DID,NewFirst,NewLast
	bulk-change-number [ FILE ]	Import CSV to bulk change number information in accounts.csv and dbn_voicemail.conf. Column order: First,Last,OldDID,NewDID 
	recording-move [ FILE ] 	Move existing recordings to new number based on imported CSV. Column order: First,Last,CurrentDID,NewDID


-remove
	users [FILE]			Run without specifying a file to remove single user. Specify file to bulk remove.
					Moves to removed users file in /home/chris.bright/changelog
					Import CSV to bulk move users to removed users file in /home/chris.bright/changelog/. Uploaded CSV must contain DIDs to be removed in COL1.

#reloads will ask for a log message like git
-production
	push-2-prod			Push current changes to production servers DB01 & DB02. Will Prompt for username and password.
	remote-reload			Gets and unpacks tarball then reloads asterisk servers on both DB01 and DB02. PUSH TO PRODUCTION FIRST
	login [ 1,2 ]			Logs into remote DBN servers DBN01 or DBN02. Will prompt for username and password.

#show export-accounts added, need to add lookup functions for extension, voicemail.conf, recordings, accounts.csv, recording pin
-show
	customer-info			Shows customer Context, DBN Number, Recording PIN
	recording-pins [ STRING ]	Pass or prompt for customer context to search in record_passwords.csv and returns info with DBN recording info.
	name-recordings [ STRING ]	Pass or prompt for customer context to list customer recording directory and files.
	log [ list, all, [YYYYMMDD] ]	Leave blank to see list. Specify [ all ] to cat all changes. Specify date to cat that change in YYYYMMDD format.

-help					Prints these instructions

-update					Pushes new changes to /bin/bash/dbntool and /usr/share/bash-completion/completions/dbntool. Also sources the dbn completion file
