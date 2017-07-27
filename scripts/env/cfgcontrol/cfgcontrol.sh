#!/bin/bash

declare -r argc=$#
declare -r -a argv=( "$@" )
declare -r bold=$(tput bold)
declare -r normal=$(tput sgr0)
declare -r relative_script_dir=$( dirname $0 )

main() {
	cd $relative_script_dir
	readonly script_dir=$(pwd)

	if [ ! -h $script_dir/shared_vars ] ; then
		echo "Link to file with shared variables not found. Running"
		echo "$script_dir/configure should generate this file."
		exit 1
	fi

	. $script_dir/shared_vars
	. $script_dir/arg.sh
	. $script_dir/interact.sh
	. $bash_include_dir/assert.sh
	. $bash_include_dir/debug.sh

	process_args
	debug_print_args

	debug_print "action is: $action"
	if [ "not-set" != "$action" ] ; then
		do_action "$action"
	fi
}

do_clean() {
	dir_to_remove="$script_dir/backup"

	if [ -d "$dir_to_remove" ] ; then
		local answer=$(get_yes_no \
			"Recursively remove $dir_to_remove")

		rm -rf $dir_to_remove
	else
		echo "Already clean"
	fi

}

do_pull() {
	echo Pulling tracked configuration files from project...

	if [ ! -d $script_dir/backup ] ; then
		mkdir $script_dir/backup
	fi

	extract_entries_from_files \
		$config_list_file \
		$config_list_file

	for i in $( seq 0 1 $(($repo_config_entry_amount - 1)) )
	do
		extract_vars_from_entries
		debug_print "processing repo entry $repo_entry"

		if [ -z "$local_config_path" ] ; then
			debug_print "Empty local config for $config_file_name"
			continue
		fi

		cp \
			$local_config_path \
			$script_dir/backup/$config_file_name-$(date -Iseconds)

		cp $repo_config_path $local_config_path

		debug_print ""
		debug_print "Copied repo --> local"
		debug_print "====================="
		debug_print "local_path: $local_config_path"
		debug_print "repo_path: $repo_config_path"
		debug_print ""

		echo "Pulled $config_file_name"
	done

	msg+="\nBackups of local configs have been written to "
	msg+="$script_dir/backup\n"
	msg+="Run ${bold}cfgcontrol clean${normal} to remove all backups "
	msg+="from $script_dir/backup\n"

	echo -e "$msg"
}

do_push() {
	echo Pushing tracked configuration files to project...

	extract_entries_from_files \
		$config_list_file \
		$config_list_file

	for i in $( seq 0 1 $(($repo_config_entry_amount - 1)) )
	do
		extract_vars_from_entries
		debug_print "processing repo entry $repo_entry"

		if [ -z "$local_config_path" ] ; then
			debug_print "Empty local config for $config_file_name"
			continue
		fi

		cp $local_config_path $repo_config_path

		debug_print ""
		debug_print "Copied local --> repo"
		debug_print "====================="
		debug_print "local_path: $local_config_path"
		debug_print "repo_path: $repo_config_path"
		debug_print ""

		echo "Pushed $config_file_name"
	done
}

do_sync() {
	echo "Updating project config list..."

	cp $config_list_file $old_config_list_file

	# First add all repo config entries found from repo config directory
	# Escaped parentheses save matched string to be used with \1
	ls -RA1 $config_dir \
		| grep "^\." \
		| xargs -I{} find $repo_root/config -name {} \
		| sed -e 's/\(.*\)/repo:\1/g' \
		> $config_list_file

	extract_entries_from_files \
		$old_config_list_file \
		$config_list_file

	# Add local config entry for repo config if one has already been added
	# to configuration list. Which is the old configuration list now.
	for config in ${local_config_entries[@]}
	do
		config=$(echo $config | sed -e 's/local://g')

		if [ -z "$config" ] ; then
			continue
		fi

		config_name=$( basename $config )

		# Bash variable expansion needs "
		# Use | as delimiter because variable with path expands to
		# string with /
		sed -i \
			's|\(.*'"$config_name"'$\)|\1\nlocal:'"$config"'|g' \
			$config_list_file
	done

	# Add empty "local:" row for each repo config with no local config in 
	# old config listing.
	for config in ${repo_config_entries[@]}
	do
		config=$(echo $config | sed -e 's/repo://g')
		config_name=$( basename $config )

		is_local_config="n"
		is_local_config=$(local_config_in \
			"$config_name" local_config_entries[@])

		if [ "y" == "$is_local_config" ] ; then
			continue
		fi

		echo "Searching for $config_name from $HOME"
		local_config_locations=$(find $HOME -name $config_name)

		path_to_insert=""
		for location in $local_config_locations
		do
			answer=$(get_yes_no "Use $location for $config_name")

			if [ "y" == "$answer" ] ; then
				path_to_insert="$location"
				break
			fi
		done

		if [ -n "$path_to_insert" ] ; then
			local_config_to_config_list $config_name $path_to_insert
		else
			empty_local_config_to_config_list $config_name
		fi
	done
}

empty_local_config_to_config_list() {
	config_name=$1

	sed -i \
		's|\(.*'"$config_name"'$\)|\1\nlocal:|g' \
		$config_list_file

	msg="[ INFO ] Local location for $config_name not found. "
	msg+="Please manually insert it to $config_list_file"
	echo $msg
}

local_config_to_config_list() {
	config_name=$1
	path=$2

	sed -i \
		's|\(.*'"$config_name"'$\)|\1\nlocal:'"$path"'|g' \
		"$config_list_file"
}

local_config_in() {
	tested_config=$1
	declare -a matching_list=("${!2}")

	did_match="n"

	for matcher in ${matching_list[@]}
	do
		matcher=$(echo $matcher \
			| sed -e 's/local://g')

		if [ -z "$matcher" ] ; then
			continue
		fi

		matcher_name=$( basename $matcher )

		if [ "$tested_config" == "$matcher_name" ] ; then
			did_match="y"
			break
		fi
	done

	echo "$did_match"
}

extract_entries_from_files() {
	local_list_path=$1
	repo_list_path=$2

	# -g (global) option of _declare_ is for bash 4.2 and above
	declare -r -a -g local_config_entries=($(cat $local_list_path \
		| grep "^local:"))

	declare -r -a -g repo_config_entries=($(cat $repo_list_path \
		| grep "^repo:"))

	readonly repo_config_entry_amount=${#repo_config_entries[@]}

	debug_print ""
	debug_print "===== Config entries ====="
	debug_print "Repo config entry amount is: $repo_config_entry_amount"
	debug_print_array local_config_entries[@]
	debug_print_array repo_config_entries[@]
	debug_print ""
}

extract_vars_from_entries() {
	repo_entry=${repo_config_entries[$i]}
	repo_config_path=$(echo $repo_entry | sed -e 's/repo://g')

	local_entry=${local_config_entries[$i]}
	local_config_path=$(echo $local_entry | sed -e 's/local://g')

	config_file_name=$( basename $repo_config_path )
}

main
