debug_copying_print() {
	from="$1"
	to="$2"

	debug_print ""
	debug_print "Copied $from --> $to"
	debug_print "====================="
	debug_print "local_path: $local_config_path"
	debug_print "repo_path: $repo_config_path"
	debug_print ""
}

debug_config_entries_print() {
	debug_print ""
	debug_print "===== Config entries ====="
	debug_print "Repo config entry amount is: $repo_config_entry_amount"
	debug_print_array local_config_entries[@]
	debug_print_array repo_config_entries[@]
	debug_print ""
}
