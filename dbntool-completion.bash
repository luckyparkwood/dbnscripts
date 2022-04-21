#complete -W "log new add change remove production show" dbntool

_dbntool_complete()
{
	local cur prev;

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}
	prev2=${COMP_WORDS[COMP_CWORD-2]}

	if [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=( $(compgen -W "add change log production remove show help update file git auto" -- $cur) )
	elif [ $COMP_CWORD -eq 2 ]; then
		case "$prev" in
			"add") 
				COMPREPLY=( $(compgen -W "users recording-pin dbn-directory help" -- $cur) ) ;;
			"change") 
				COMPREPLY=( $(compgen -W "bulk-change-field move-recordings field help" -- $cur) ) ;;
			"log") 
				COMPREPLY=( $(compgen -W "backup write-changes clean-up show-diff help" -- $cur) ) ;;
			"production") 
				COMPREPLY=( $(compgen -W "push-2-prod remote-reload server-login show-reload-logs auto-push-reload help" -- $cur) ) ;;
			"remove") 
				COMPREPLY=( $(compgen -W "users recording vmcontext help" -- $cur) ) ;;
			"show") 
				COMPREPLY=( $(compgen -W "customer-info recording-pin name-recordings logs get-printout help" -- $cur) ) ;;
			"file") 
				COMPREPLY=( $(compgen -W "column-order fix-name accounts.csv vm_conf.add push_dbn_extensions.conf push_dbn_voicemail.conf csv-import export-accounts reorder-accounts help" -- $cur) ) ;;
			"git") 
				COMPREPLY=( $(compgen -W "add show-trackedfiles help" -- $cur) ) ;;
			"auto") 
				COMPREPLY=( $(compgen -W "new-dbn help" -- $cur) ) ;;
			"help")
				COMPREPLY=( $(compgen -W "process about" -- $cur) ) ;;
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

				"customer-info")
					COMPREPLY=( $(compgen -W "$(grep -oe "\[.*\]" /etc/asterisk/dbn_voicemail.conf | sed -E 's/\[|\]/\"/g' | sed -z 's/\n/ /g;s/ $/\n/')" -- $cur ) ) ;;
			esac
		fi
	elif [ $COMP_CWORD -ge 4 ]; then
		if [ $prev == "-c" ] ; then
			COMPREPLY=( $(compgen -W "$(grep -oe "\[.*\]" /etc/asterisk/dbn_voicemail.conf | sed -E 's/\[|\]/\"/g' | sed -z 's/\n/ /g;s/ $/\n/')" -- $cur ) )
		fi
	fi
	return 0
}

complete -o bashdefault -o default -F _dbntool_complete dbntool
