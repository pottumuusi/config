#!/bin/bash

function print_header() {
	echo -e "\n//////////////////// $1 ////////////////////\n"
}

function error_exit() {
	echo -e "$1\nExiting..."
	exit 1
}

function debug_print() {
	echo "[DEBUG] $1"
}

function is_mounted() {
	local -r path=$1

	debug_print "is_mounted, path is $path"

	if [ -z "$(mount | grep ${path})" ] ; then
		echo "TRUE"
	fi

	echo "FALSE"
}
