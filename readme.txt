UPDATED 2/23/22


### DBN_TRAINING

Customer Configuration has 6 parts
1. DID set up in P1 under the Synety YYY Sales Demo account
	- sip contact domain: dialbyname.cloudcall.com
	- ring only
	- Username First,Last: [CUSTCONTEXT],DialByName
	- user email: dbn@cloudcall.com
2. recording pin
	- stored in a shared recording pin database
	- unique to every customer
	- allows automated recording of dbn names
	- file location: /var/lib/asterisk/CCdbn/record_passwords.csv
3. account file
	- drives the dialbyname lookup function
	- individual file to each customer stored in own dir
	- file/dir location: /var/lib/asterisk/CCdbn/[CUSTCONTEXT]/accounts.csv
4.	voicemail.conf context
	- tells asterisk where to send the calls after matching on name lookup
	- also used for voicemail file lookups - these are user extensions, and recordings are stored as voicemail greetings
	- stored in a shared dbn conf file
	- file location:/etc/asterisk/dbn_voicemail.conf
5. extensions.conf context
	- this is the DID you have configured in P1 for the customer DBN
	- tells the asterisk server which customer DBN files to look through
	- stored in a shared dbn conf file
	- file location: /etc/asterisk/dbn_extension.conf
6. recording files
	- each file is stored as greet.wave in a unique directory named after each individual user DID
	- dictated by asterisk vm function
	- file/dir location: /var/spool/asterisk/voicemail/[CUSTCONTEXT]/[USERDID]/greet.wav
###

### DBNTOOL

Description

Scripts a lot of the functions and manual effort required to onboard, manage and troubleshoot customer DBNs.

Prerequisites
	- asterisk
	- sshpass
	- git
Installation
git@github.com:luckyparkwood/dbntool.git

Familiarity with basic Linux navigation and commands, asterisk, git, at least one file editor (VIM,NANO) is required!

File locations
- main dir: /etc/dbntool/
- binary: /bin/bash
- temp files: /tmp/dbntool/ (future update)
- bash completion: /usr/share/bash-completion/completions/
- logs: /var/log/dbntool/
- exports: /home/chris/htmlchris > /var/www/html/chris

Usage:

Invoke the tool:
$dbntool

If no arguments are passed, it will display the help page.
###

### ADMIN
$dbntool (update-dbntool, update-permissions, dbntool-user_new, dbntool-user_test, cleanup-tmpfiles)

update-dbntool
	Updates the binaries in /usr/bin/ to match the local copies of dbntool and dbnpush in the dbntool main directory
	(Sometimes needs to be run twice for some reason)
update-permissions
	Resets permissions of all dbntool managed files to 775 and owner :asterisk
dbntool-user_new
	Creates new nonroot user on server to manage the dbn. Does the following:
		Asks for new username
		Asks for new password
		Adds new user with home directory
		Adds supplied password
		Adds Bash as the default shell for new user
		Adds new user to groups asterisk and sshuser
		Adds User details to git global options to allow git use	
dbntool-user_test
	Tests user for the correct permissions and verifies setup.
cleanup-tmpfiles
	Manually removes any temporary files that might be blocking script execution in /tmp/
###

### LOG (depreciated, use git for version control)
$dbntool log (backup,write-changes,cleanup,show-diff)

backup
	Backs up the current production tarball, dbn_extensions.conf, dbn_voicemail.conf, and record_passwords.csv

write-changes (DISABLED)
	Write current changes to change log /home/chris.bright/changelog/ (disabled, use git for version control)
clean-up [NUM]
	Remove backups older than [ NUM ] of days. (Default 90)
show-diff (DISABLED)
	Show diff between current files and backups (disabled, use git for version control)
###

### ADD
$dbntool add (user,recording-pin,dbn-directory) 
user (CR,[INFILE, -c [CUSTCONTEXT] -i [INFILE])
	CR
		Invoke without any variables to start the Add User Wizard
	[INFILE]
		Pass csv file into script to bulk import users
		File requirements: 
			Type is ASCII without any invisible or special characters
			3 columns in (FIRST,LAST,DID) format
			No header row
	-c [CUSTCONTEXT] -i [INFILE]
		Non-interactive flag mode. 
		Pass -c for Custmer context and -i for input file.
		Same file requirements as above.
recording-pin (CR,[CUSTCONTEXT], -c [CUSTOMERCONTEXT])
	CR
		Invoke without any variable to begin guided PIN addition
	[CUSTCONTEXT]
		Pass the customer context as a variable to automatically add customer pin (no confirmation)
	-c [CUSTOMERCONTEXT]
		Pass with flag -c to use flag mode (non-interactive)
dbn-directory (CR, -c [CUSTCONTEXT] -i [INFILE], -b [CUSTCONTEXT1 CUSTCONTEXT2 ...])
	CR
		Invoke without any variables or flags to start guided DBN customer directory creation
		Will also ask to create new recording PIN
	-c [CUSTCONTEXT] -i [INFILE]
		Use flags -c with [CUSTCONTEXT] and -i with [INFILE] to start non-interactive flag mode
		Flag mode requires both parameters to function.
		Will also create a recording PIN for the Customer if one does not exist with the same CUSTCONTEXT
	-b [CUSTCONTEXT1 CUSTCONTEXT2 ...]
		Bulk mode addition of directories and recording PINs
		Invoke with flag -b followed by each customer context to be added, separated with a space
###

### CHANGE
$dbntool change (bulk-change-field,move-recordings,field)
		   
bulk-change-field
	(not yet built)
move-recordings
	Used to move recordings from old number drectories to new number directories after being changed (does not change numbers in dbn_voicemail or accounts.csv). 
	Matches each line on OLD_DID and moves file from existing directory to newly created directory in /var/spool/asterisk/voicemail/[CUSTCONTEXT]/ according to NEW_DID
	Offers to delete old DIDs afterwards.
	(Currently no script to automatically make file in correct format for this)
	File requirements: 
			Type is ASCII without any invisible or special characters
			4 columns in (FIRST,LAST,OLD_DID,NEW_DID) format
			No header row
field
	Start change field wizard. Search and replace. Works with any matched string.
	Asks for customer context and searches both dbn_voicemail.conf and [CUSTCONTEXT}/accounts.csv
###
	
	
### REMOVE
$dbntool remove (users,vmcontext)
	
users (CR, -c [CUSTCONTEXT] -i [INFILE] (-F Force))
	CR
		Invoke without any variables to start remove user wizard.
	-c [CUSTCONTEXT] -i [INFILE]
		Use flags -c and -i for non-interactive flag mode.
		Pass -c for customer contxt and -i for input file. 
		File requirements: 
			Type is ASCII without any invisible or special characters
			3 columns in (FIRST,LAST,DID) format
			No header row
	-F Force
		Force removal even if duplicates are detected (CHECK AFTER OPERATION TO ENSURE INTENDED REMOVALS)
vmcontext
	Confirms customer context and removes from dbn_voicemail.conf only.
	Useful for rebuilding customer DBNs after significant changes (remove existing, add as new)
###


### PRODUCTION
$dbntool production (push-2-prod,remote-reload,login,show-reload-logs,auto-push-reload)

push-2-prod
	Run as sudo
	Push changes to DBN files and recordings to production servers dbn-01 and dbn-02
remote-reload
	Run as sudo
	Remotely triggers scripts on production servers dbn-01 and dbn-02 to unpack the tarballs and restart asterisk dialplan only.
	Does not terminate in-progress calls.
login
	(not yet built)
show-reload-logs
	Reads contents of the production push and reload log
	Does not terminate in-progress calls.
###


### SHOW
$dbntool show (customer-info,recording-pin,name-recordings,logs,get-printout)

customer-info (CR,all,[CUSTCONTEXT])
	Prints customer configuration from record_passwords.csv, dbn_voicemail.conf, and dbn_extensions.conf
	CR
		Invoke without parameters to start guided search.
	all
		Prints configured customers (list directories in /var/lib/asterisk/CCdbn/)
recording-pin (CR,all,[CUSTCONTEXT])
	CR
		Invoke without parameters to start guided search.
	all
		Prints entire record_passwords.csv file
	[CUSTCONTEXT]
		Searches record_passwords.csv for [CUSTCONTEXT] and prints any matches
name-recordings (CR,[#OFDAYS])
	Shows recordings added in the last [#OFDAYS]. With no passed number of days, default is 7 days.
logs
	(not yet built)
get-printout [CUSTCONTEXT]
	Prints DBN recording number, Customer Context, Customer DBN DID, and customer recording PIN.
	Mostly fallen out of use in favor of '$dbntool file export_accounts' which also moves accounts file to the html download directory for company retrieval. 
###


###FILE
$dbntool file (column-order,fix-name,accounts.csv,vm_conf.add,push_dbn_extensions.conf,push_dbn_voicemail.conf,csv-import,export-accounts,reorder-accounts)

column-order ({1-3} {1-3} {1-3})
	Takes input argument as column order for new file.
	Input column numbers must be separated with a space. i.e column-order 3,1,2
	No input validation so it is easy to break the file
	Saves as a separate file reodrer_$inFile for comparison
fix-name ([INFILE], -i [INFILE] -s)
	Takes a CSV and sanitizes the data to be readable by the DBN scripts. 
	Use -i to init Flag mode for non-interactive completion. Otherwise pass CSV into script to parse in guided mode.
	Performs the following major functions:
		Checks for column numbers
		Attempts to rearrange column number if DID is not in 3rd column
		Validates numbers as correct 1NPANXXNNNN format
		Removes header row
		Removes any invisible characters not compatible with basic ASCII format
		Other minor formatting checks
	-s Safe mode, non interactive, but show changes without making changes to files
	***THIS SCRIPT IS NOT FOOL-PROOF BUT WORKS 99 PERCENT OF THE TIME! ALWAYS REVIEW DIFF BEOFRE COMMITTING CHANGES***	
accounts.csv
	NOT CONFIGURED, MAY REMOVE IN FUTURE UPDATE
vm_conf.add
	NOT CONFIGURED, MAY REMOVE IN FUTURE UPDATE
push_dbn_extensions.conf ([CR], -c [CUSTCONTEXT] -d [CUSTDID] -i [INFILE] -s)
	Guided mode: Ask for customer context and DID before adding an entry for this company to the dbn_extensions.conf file.
	Non-int mode: Take arguments passed by flags to add an entry for the company to the dbn_extensions.conf file.
		-s Safe mode, non interactive, but show changes without making changes to files
push_dbn_voicemail.conf ([CR], -c [CUSTCONTEXT] -i [INFILE] -s)
	Guided mode: Ask for customer context taking vm_conf.add file in customer directory adding an entry for this company to the dbn_voicemail.conf file
	Non-int mode: Take arguments passed by flags to add an entry for the company to the dbn_voicemail.conf file.
		-s Safe mode, non interactive, but show changes without making changes to files
csv-import ([INFILE], -c [CUSTCONTEXT] -i [INFILE] -s)
	Guided Mode: Pass sanitized CSV file to script, then ask for customer context to create accounts.csv and vm_conf.add in the customer directory
	Non-int mode: Take arguments passed by flags to create accounts.csv and vm_conf.add in the customer directory
	-s Safe mode, non interactive, but show new file contents without creating files
	***REQUIRES CUSTOMER DIRECTORY TO EXIST***
export-accounts [CUSTCONTEXT]
	Reorders the passed customers accounts.csv file and sends copy of it to the html server for download via HTTP.
	Shows a printout for copy paste into email for DBN tickets
	Download accessible on company VPN only
reorder-accounts [INFILE]
	Reorders accounts in supplied file. 
	Works by ordering accounts with line number and removes previous line number (intended only for accounts.csv files, not meant for other uses/may not work)
move-users ([INFILE], -c [CUSTCONTEXT] -i [INFILE] [-b])
	Guided exec: Pass file to command to start guided exec. Will ask for customer context and use the supplied file containing First,Last,DID to move those users to the top of the customers accounts.csv file. 
	Flag mode: Take arguments passed by flags to move the users in the INFILE to the top of the customers accounts.csv file.
	-b : This optional flag will add the supplied users to the bottom of the file instead of the default destination of top of the file. 
	
###

### HELP
$dbntool help
	Prints the readme file.
###

### GIT
$dbntool git (add,show-trackedfiles)

add
	Run as sudo 
	Adds new and updated files to the staging area to be committed to git.
	Only checks new and changed files in /etc/asterisk/ and /var/lib/asterisk/CCdbn/
show-trackedfiles
	Run as sudo
	Shows all files currently tracked by git (they are hidden when running git status)
###


### AUTO
$dbntool auto new-dbn (-c [CUSTCONTEXT] -d [DBNDID] -i [INFILE] {CR,-F})
	Workhorse DBN created for fully automated creation of new customer DBNs
	Pass -c for customer context, -d for DBN DID as configured in P1, -i for input file
	Run without -F to run a series of checks that validates the input file format, checkes for existing contexts and directory, colliding VM recording pins, and displays preview of additions to dbn_voicemail.conf and [CUSTCONTEXT]/accounts.csv
	After approving the changes, run with -F to force the creation of all the required DBN components. 
	Check the changes through Git to ensure it was successful.
###


### DBNPUSH
$sudo dbnpush [-n]
	Formerly dbntool production auto-push-reload	
	Run as sudo
	Combination of push-2-prod and remote-reload scripts
	Asks for reason for pushing to servers for logging - cannot be empty
	Automatically pushes DBN file changes and recordings to production servers dbn-01 and dbn-02. Also triggers the reload scripts on the production servers to unpack the tarballs and reload the asterisk dialplan. 
###
