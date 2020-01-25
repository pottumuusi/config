#!/bin/bash

set -ex

cd $(dirname $0)
script_root="$(pwd)"

source util.sh

readonly DISABLED="TRUE"
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
readonly boot_partition_dev="${main_block_device}1"
readonly swap_partition_dev="${main_block_device}2"
readonly lvm_partition_dev="${main_block_device}3"

readonly make_conf="${gentoo_config}/make.conf"

readonly volgroup_name="vg01"
readonly root_size="14G"
readonly home_size="9995M"

readonly root_partition_dev="/dev/${volgroup_name}/root"
readonly home_partition_dev="/dev/${volgroup_name}/home"

readonly opt_pre_chroot="--pre-chroot"
readonly opt_post_chroot="--post-chroot"

function process_args() {
	for opt in "$@" ; do
		echo opt is: $opt

		if [ "${opt_post_chroot}" = "$opt" ] ; then
			readonly is_post_chroot_install="TRUE"
			continue
		fi

		if [ "${opt_pre_chroot}" = "$opt" ] ; then
			readonly is_pre_chroot_install="TRUE"
			continue
		fi

		error_exit "Unknown program argument: $opt"
	done

	if [ "TRUE" != "${is_pre_chroot_install}" -a "TRUE" != "${is_post_chroot_install}" ] ; then
		error_exit "Expecting to receive either --pre-chroot or --post-chroot as an argument."
	fi

	if [ "TRUE" = "${is_pre_chroot_install}" -a "TRUE" = "${is_post_chroot_install}" ] ; then
		error_exit "Please choose either --pre-chroot or --post-chroot as program argument. Not both."
	fi
}

function presetup() {
	if [ "TRUE" != "${DISABLED}" ] ; then
		# Was not able to connect to sks-keyservers.net
		gpg --keyserver hkps://hkps.pool.sks-keyservers.net --recv-keys 0xBB572E0E2D182910
	fi
	wget -O- https://gentoo.org/.well-known/openpgpkey/hu/wtktzo4gyuhzu8a4z5fdj3fgmr1u6tob?l=releng | gpg --import
}

function setup_date_and_time() {
	print_header "SETTING DATE AND TIME"
	if [ "TRUE" != "${DISABLED}" ] ; then
		emerge net-misc/ntp
		ntpd -q -g # TODO test that works. Time may be correct out of the box
	fi
}

function setup_partitions() {
	print_header "PARTITIONING"
	sfdisk --wipe always ${main_block_device} < ${saved_partition_table}
	mkswap ${swap_partition_dev}
	swapon ${swap_partition_dev}

	pvcreate ${lvm_partition_dev}
	vgcreate ${volgroup_name} ${lvm_partition_dev}

	lvcreate --yes --type linear -L ${root_size} -n root ${volgroup_name}
	lvcreate --yes --type linear -L ${home_size} -n home ${volgroup_name}

	mkfs.ext2 -F -F ${boot_partition_dev}
	mkfs.ext4 -F -F ${root_partition_dev}
	mkfs.ext4 -F -F ${home_partition_dev}

	mount ${root_partition_dev} ${mountpoint_root}
	mkdir ${mountpoint_root}/boot
	mkdir ${mountpoint_root}/home
	mount ${boot_partition_dev} ${mountpoint_root}/boot
	mount ${home_partition_dev} ${mountpoint_root}/home
}

function setup_stage_tarball() {
	echo "INSTALLING STAGE TARBALL"
	pushd ${mountpoint_root}
	# wget ${stage3_tarball_remote_full_path}
	wget ${frozen_stage3_release_dir}/${stage3_tar}
	wget ${frozen_stage3_release_dir}/${stage3_tar}.DIGESTS.asc # Contains info of .DIGESTS
	if [ "TRUE" != "${DISABLED}" ] ; then
		openssl dgst -r -sha512 ${stage3_tarball_filename} # TODO exit with error message if does not match
	fi

	# From Gentoo wiki:
	# To be absolutely certain that everything is valid, verify the
	# fingerprint shown with the fingerprint on the Gentoo signatures page.
	# Gentoo signatures page: https://www.gentoo.org/downloads/signatures/
	readonly gpg_match="Good signature from \"Gentoo Linux Release Engineering"
	gpg --verify ${stage3_tar}.DIGESTS.asc 2>&1 | grep "${gpg_match}"

	readonly signed_sum="$(grep -A1 SHA512 ${stage3_tar}.DIGESTS.asc | head -2 | grep -v SHA512)"
	readonly calculated_sum="$(sha512sum ${stage3_tar})"
	if [ "${signed_sum}" != "${calculated_sum}" ] ; then
		error_exit "Stage 3 tar sums do not match."
	fi

	tar xpvf ${stage3_tar} --xattrs-include='*.*' --numeric-owner
	popd
}

function setup_portage_configuration() {
	print_header "SETTING UP PORTAGE CONFIGURATION"

	cp ${make_conf} ${mountpoint_root}/etc/portage/make.conf
	mkdir --parents ${mountpoint_root}/etc/portage/repos.conf
	cp \
		${mountpoint_root}/usr/share/portage/config/repos.conf \
		${mountpoint_root}/etc/portage/repos.conf/gentoo.conf
	cp --dereference /etc/resolv.conf ${mountpoint_root}/etc/
}

function setup_new_environment() {
	print_header "SETTING UP NEW ENVIRONMENT"

	mount --types proc /proc ${mountpoint_root}/proc
	mount --rbind /sys ${mountpoint_root}/sys
	mount --make-rslave ${mountpoint_root}/sys
	mount --rbind /dev ${mountpoint_root}/dev
	mount --make-rslave ${mountpoint_root}/dev
}

function setup_portage() {
	emerge-webrsync

	eselect profile set default/linux/amd64/17.1

	emerge --verbose --update --deep --newuse @world

	# TODO Check if necessary to update make.conf. Was it changed during
	# portage setup?

	# TODO configure ACCEPT_LICENSE
	# to make.conf:
	# ACCEPT_LICENSE="-* @FREE"
	# Per package overrides are also possible. For example can change:
	# /etc/portage/package.license/kernel
}

function setup_timezone() {
	cp ${gentoo_config}/timezone > /etc/timezone
	emerge --config sys-libs/timezone-data
}

function setup_locale() {
	cp ${gentoo_config}/locale.gen /etc/locale.gen
	locale-gen
	eselect locale set en_US
	env-update
	source /etc/profile
}

function pre_chroot_install() {
	print_header "PRE-CHROOT_INSTALL"
	presetup
	setup_partitions
	setup_date_and_time
	setup_stage_tarball
	setup_portage_configuration
	setup_new_environment
}

function post_chroot_install() {
	print_header "POST-CHROOT_INSTALL"

	source /etc/profile

	setup_portage
	setup_timezone
	setup_locale
}

function main() {
	process_args "$@"

	if [ "TRUE" = "${is_pre_chroot_install}" ] ; then
		pre_chroot_install

		chroot ${mountpoint_root} /bin/bash -c \
			${script_root}/install_gentoo.sh --post-chroot
	fi

	if [ "TRUE" = "${is_post_chroot_install}" ] ; then
		post_chroot_install
	fi
}

main "$@"
