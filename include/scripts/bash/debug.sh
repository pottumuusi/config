debug_enable() {
	readonly debug="y"
}

debug_print_array() {
	declare -a arr=("${!1}")

	if [ "y" == "$debug" ] ; then
		echo "${arr[@]}"
	fi
}

debug_print_formatted() {
	local msg="$1"

	if [ "y" == "$debug" ] ; then
		echo -n -e "$msg"
	fi
}

debug_print() {
	local msg="$1"

	if [ "y" == "$debug" ] ; then
		echo "$msg"
	fi
}

debug_print_args() {
	if [ "y" != "$debug" ] ; then
		return
	fi

	echo "argc is: $argc"
	echo -n "argv is:"

	for i in $( seq 0 1 $(($argc - 1)) )
	do
		echo -n " ${argv[$i]}"
	done

	echo ""
}
