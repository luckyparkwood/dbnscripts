#complete -W "log new add change remove production show" dbntool

_dbntool_complete()
{
	local cur prev;

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}
	prev2=${COMP_WORDS[COMP_CWORD-2]}

	if [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=( $(compgen -W "add change log new production remove show help update file git auto" -- $cur) )
	elif [ $COMP_CWORD -eq 2 ]; then
		case "$prev" in
			"add") 
				COMPREPLY=( $(compgen -W "user" -- $cur) ) ;;
			"change") 
				COMPREPLY=( $(compgen -W "bulk-change-field move-recordings field" -- $cur) ) ;;
			"log") 
				COMPREPLY=( $(compgen -W "backup write-changes clean-up show-diff" -- $cur) ) ;;
			"new") 
				COMPREPLY=( $(compgen -W "recording-pin dbn-directory" -- $cur) ) ;;
			"production") 
				COMPREPLY=( $(compgen -W "push-2-prod remote-reload server-login show-reload-logs auto-push-reload" -- $cur) ) ;;
			"remove") 
				COMPREPLY=( $(compgen -W "users recording vmcontext" -- $cur) ) ;;
			"show") 
				COMPREPLY=( $(compgen -W "customer-info recording-pin name-recordings logs get-printout" -- $cur) ) ;;
			"file") 
				COMPREPLY=( $(compgen -W "column-order fix-name accounts.csv vm_conf.add push_dbn_extensions.conf push_dbn_voicemail.conf csv-import export-accounts reorder-accounts" -- $cur) ) ;;
			"git") 
				COMPREPLY=( $(compgen -W "add show-trackedfiles" -- $cur) ) ;;
			"auto") 
				COMPREPLY=( $(compgen -W "new-dbn" -- $cur) ) ;;
		esac
	elif [ $COMP_CWORD -eq 3 ]; then
		if [ $prev2 == "add" ] ; then
			case "$prev" in
				"user")
					COMPREPLY=() ;;
			esac
		elif [ $prev2 == "change" ] ; then
			case "$prev" in
				"bulk-number")
					COMPREPLY=() ;;
				"recording-move")
					COMPREPLY=() ;;
			esac
		elif [ $prev2 == "new" ] ; then
			case "$prev" in
				"csv-import")
					COMPREPLY=() ;;

			esac
		elif [ $prev2 == "production" ] ; then
			case "$prev" in
				"login")
					COMPREPLY=( $(compgen -W "DBN01 DBN02" -- $cur) ) ;;
			esac	
		elif [ $prev2 == "remove" ] ; then
			case "$prev" in
				"bulk-remove")
					COMPREPLY=() ;;
				"recording")
					COMPREPLY=() ;;
			esac
		elif [ $prev2 == "show" ] ; then
			case "$prev" in
				"recording-pin")
					COMPREPLY=( $(compgen -W "all" -- $cur) ) ;;
				"logs")
					COMPREPLY=( $(compgen -W "all date list" -- $cur) ) ;;
			esac
		fi
	
	fi

	return 0
}

complete -o bashdefault -o default -F _dbntool_complete dbntool
