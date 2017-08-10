action="not-set"

process_args() {
	# seq
	# par1: first
	# par2: increment
	# par3: last
	for i in $( seq 0 1 $(($argc - 1)) )
	do
		process_single_arg ${argv[$i]}
	done
}

process_single_arg() {
	arg=$1

	if [ "$arg" == "--debug" -o "$arg" == "-d" ] ; then
		debug_enable
		return
	fi

	if [ "$arg" == "--help" ] ; then
		try_set_action "help"
		return
	fi

	if [ "$arg" == "-h" ] ; then
		try_set_action "help"
		return
	fi

	if [ "$arg" == "clean" ] ; then
		try_set_action $arg
		return
	fi

	if [ "$arg" == "pull" ] ; then
		try_set_action $arg
		return
	fi

	if [ "$arg" == "push" ] ; then
		try_set_action $arg
		return
	fi

	if [ "$arg" == "sync" ] ; then
		try_set_action "$arg"
		return
	fi

	echo ""
	echo "Unknown argument: $arg"
	echo ""
	print_help_and_exit
}

try_set_action() {
	local cmd=$1
	local err_text="${bold}$action${normal} action already set to be\n"
	err_text+="executed. Found excessive action: ${bold}$cmd${normal}."

	assert_str \
		$action \
		"not-set" \
		"$err_text"

	action=$cmd
}

do_action() {
	action=$1

	if [ "clean" == "$action" ] ; then
		do_clean
		return
	fi

	if [ "pull" == "$action" ] ; then
		do_pull
		return
	fi

	if [ "push" == "$action" ] ; then
		do_push
		return
	fi

	if [ "sync" == "$action" ] ; then
		do_sync
		return
	fi

	if [ "help" == "$action" ] ; then
		print_help_and_exit
		return
	fi

	exit_with_error "Unrecognized action $action."
}
