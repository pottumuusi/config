#!/bin/bash

# Select what to setup
readonly cfg_should_setup_portage="TRUE"
readonly cfg_should_setup_timezone="TRUE"
readonly cfg_should_setup_locale="TRUE"
readonly cfg_should_setup_kernel="TRUE"
readonly cfg_should_setup_lvm="TRUE"
readonly cfg_should_setup_new_system="TRUE"

readonly main_block_device="/dev/sda"
readonly mountpoint_root="/mnt/gentoo"

# Parse stage3 tar name from webpage.
readonly frozen_stage3_release_dir="https://mirror.netcologne.de/gentoo/releases/amd64/autobuilds/current-stage3-amd64/"
readonly stage3_tar="$(curl ${frozen_stage3_release_dir}	\
	| grep stage3						\
	| grep amd64						\
	| grep tar						\
	| grep -v multilib					\
	| grep -v -e CONTENTS -e DIGESTS			\
	| cut -d ">" -f 2					\
	| cut -d "<" -f 1)"

readonly gentoo_config="${script_root}/gentoo_config"

# label: dos
# label-id: 0x25a3d9ff
# unit: sectors
#
# start=        2048, size=     4194304, type=83, bootable
# start=     4196352, size=     8388608, type=82
# start=    12584960, size=    50329600, type=8e
readonly saved_partition_table="${gentoo_config}/saved_partition_table"
readonly gpt_partition_backup_file="sgdisk-sda.bin"
readonly boot_partition_dev="${main_block_device}1"
readonly swap_partition_dev="${main_block_device}2"
readonly lvm_partition_dev="${main_block_device}3"

readonly make_conf="${gentoo_config}/make.conf"

readonly volgroup_name="vg01"
readonly root_size="14G"
readonly home_size="9995M"

readonly lv_name_root="root"
readonly lv_name_home="home"
readonly root_partition_dev="/dev/${volgroup_name}/${lv_name_root}"
readonly home_partition_dev="/dev/${volgroup_name}/${lv_name_home}"

readonly opt_pre_chroot="--pre-chroot"
readonly opt_chroot="--chroot"
readonly opt_full_install="--full"

# Intended to be called after having chrooted to new environment.
readonly opt_post_chroot="--post-chroot"

readonly kernel_sources_dir="/usr/src/linux"

readonly new_hostname="my_hostname"
readonly inet_if="eth0" # TODO read this from a command, instead of hardcoding
