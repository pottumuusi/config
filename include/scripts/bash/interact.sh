get_yes_no() {
	local prompt=$1
	local answer=""

	while [ 1 ] ; do
		read -p "$prompt [y/n]: " answer

		if [ "y" == "$answer" -o "n" == "$answer" ] ; then
			break
		fi
	done

	echo $answer
}
