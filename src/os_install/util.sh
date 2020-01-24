#!/bin/bash

function print_header() {
	echo -e "\n//////////////////// $1 ////////////////////\n"
}

function error_exit() {
	echo -e "$1\nExiting..."
	exit 1
}
