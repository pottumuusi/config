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

	if [ -z "$(mount | grep ${path})" ] ; then
		echo "TRUE"
		return
	fi

	echo "FALSE"
}

# Modify config.sh to change what to setup.
function should_setup_portage() {
	if [ "TRUE" = "${cfg_should_setup_portage}" ] ; then
		echo "TRUE"
		return
	fi

	echo ""
}

function should_setup_timezone() {
	if [ "TRUE" = "${cfg_should_setup_timezone}" ] ; then
		echo "TRUE"
		return
	fi

	echo ""
}

function should_setup_locale() {
	if [ "TRUE" = "${cfg_should_setup_locale}" ] ; then
		echo "TRUE"
		return
	fi

	echo ""
}

function should_setup_kernel() {
	if [ "TRUE" = "${cfg_should_setup_kernel}" ] ; then
		echo "TRUE"
		return
	fi

	echo ""
}

function should_setup_initramfs() {
	if [ "TRUE" = "${cfg_should_setup_initramfs}" ] ; then
		echo "TRUE"
		return
	fi

	echo ""
}
