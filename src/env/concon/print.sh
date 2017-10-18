print_help_and_exit() {
	cat <<EOF

Usage: concon [OPTION] ACTION

Copy configuration files to/from dedicated configuration directory.

===== OPTIONS =====
-d, --debug	print debug messages when running
-h, --help	print this help text

===== ACTIONS =====
clean		Remove backups of local configuration files. Backups are
		generated when using the ${bold} pull${normal} action.
push		Use files on local machine in replacing of files in projects
		configuration directory.
pull		Use files from projects configuration directory in replacing
		of files used on local machine. By default backups are made
		from files on local machine before replacing them.
sync		Update list of project & local configuration file pairs. Files
		found from scripts configuration directory which begin with
		dot "." are added to the list. Files of identical name are
		searched under users home directory.

===== FILES =====
$config_list_file
	List of project & local configuration. Used in ${bold}pull ${normal}
	and ${bold}push${normal} actions to find out which files are
	considered to be the local equivalents of files in configuration
	directory of project.

===== DIRECTORIES =====
$config_dir
	Configuration directory of project. Contains the files intended to be
	shared with other machines. Add copies of new configuration files
	here.
EOF

	exit 0
}

tell_about_backing_local_configs() {
	cat <<EOF

Backups of local configs have been written to $concon_dir/backup

Backups can be removed from $concon_dir/backup manually or by running
the command: ${bold}concon clean${normal}.
EOF
}

print_version_and_exit() {
	echo "$concon_program_version"
	exit
}
