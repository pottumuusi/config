assert_str() {
	local under_test="$1"
	local wanted="$2"
	local err_text="$3"

	if [ "$under_test" != "$wanted" ] ; then
		exit_with_error "$err_text"
	fi
}

assert_nonempty_str() {
	local str="$1"
	local err_text="$2"

	if [ -z "$str" ] ; then
		exit_with_error ""
	fi
}

assert_dir() {
	local dir="$1"
	local err_text="$2"

	if [ ! -d "$dir" ] ; then
		exit_with_error "$err_text"
	fi
}

assert_file() {
	local file="$1"
	local err_text="$2"

	if [ ! -f "$file" ] ; then
		exit_with_error "$err_text"
	fi
}

exit_with_error() {
	local err_text="$1"

	print_error_line "$err_text"
	echo "Stopping..."
	exit 1
}

print_error_line() {
	local err_text="$1"

	echo "[ ERROR ] $err_text"
}
