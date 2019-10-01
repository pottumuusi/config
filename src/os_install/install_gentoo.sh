#!/bin/bash

set -ex

readonly main_block_device="/dev/vda"

# label: dos
# label-id: 0x25a3d9ff
# unit: sectors
#
# start=        2048, size=     4194304, type=83, bootable
# start=     4196352, size=     8388608, type=82
# start=    12584960, size=    50329600, type=8e
readonly saved_partition_table="./saved_partition_table"
readonly boot_partition_dev="${main_block_device}1"
readonly swap_partition_dev="${main_block_device}2"
readonly lvm_partition_dev="${main_block_device}3"

readonly volgroup_name="vg01"
readonly root_size="14G"
readonly home_size="9995M"

readonly root_partition_dev="/dev/${volgroup_name}/root"
readonly home_partition_dev="/dev/${volgroup_name}/home"

readonly stage3_remote_dir="https://mirror.netcologne.de/gentoo/releases/amd64/autobuilds/current-stage3-amd64/"
readonly stage3_tarball_remote_full_path="${stage3_remote_dir}/${stage3_tarball_filename}"
readonly stage3_tarball_filename="stage3-amd64-20190929T214502Z.tar.xz"
readonly stage3_tarball_contents_filename="stage3-amd64-20190929T214502Z.tar.xz.CONTENTS "
readonly stage3_tarball_digests_filename="stage3-amd64-20190929T214502Z.tar.xz.DIGESTS"
readonly stage3_tarball_digests_asc_filename="stage3-amd64-20190929T214502Z.tar.xz.DIGESTS.asc"

function presetup() {
	gpg --keyserver hkps://hkps.pool.sks-keyservers.net --recv-keys 0xBB572E0E2D182910 # TODO check correctness
}

function setup_date_and_time() {
	echo "////////// SETTING DATE AND TIME //////////"
	emerge net-misc/ntp
	ntpd -q -g
}

function setup_partitions() {
	echo "////////// PARTITIONING //////////"
	sfdisk --wipe always ${main_block_device} < ${saved_partition_table}
	mkfs.ext2 ${boot_partition_dev}
	mkswap ${swap_partition_dev}
	swapon ${swap_partition_dev}

	pvcreate ${lvm_partition_dev}
	vgcreate ${volgroup_name} ${lvm_partition_dev}

	lvcreate --type linear -L ${root_size} -n root ${volgroup_name}
	lvcreate --type linear -L ${home_size} -n home ${volgroup_name}

	mkfs.ext4 ${root_partition_dev}
	mkfs.ext4 ${home_partition_dev}
}

function setup_stage_tarball() {
	echo "////////// INSTALLING STAGE TARBALL //////////"
	pushd ./
	cd /mnt/gentoo
	wget ${stage3_tarball_remote_full_path}
	openssl dgst -r -sha512 ${stage3_tarball_filename} # TODO exit with error message if does not match

	# From Gentoo wiki:
	# To be absolutely certain that everything is valid, verify the
	# fingerprint shown with the fingerprint on the Gentoo signatures page.
	# Gentoo signatures page: https://www.gentoo.org/downloads/signatures/
	gpg --verify ${stage3_tarball_digests_asc_filename}

	tar xpvf ${stage3_tarball_filename} --xattrs-include='*.*' --numeric-owner
	popd
}

function setup_compile_options() {
	echo "////////// SETTING COMPILE OPTIONS  //////////"
	# TODO edit make.conf, save it to repo and write to system being
	# installed. /mnt/gentoo/etc/portage/make.conf
	#
	# COMMON_FLAGS="-march=native -O2 -pipe"
	# CFLAGS="${COMMON_FLAGS}"
	# CXXFLAGS="${COMMON_FLAGS}"
	# MAKEOPTS="-j5"
}

function setup_new_environment() {
	echo "////////// SETTING UP NEW ENVIRONMENT //////////"
	# save output of mirrorselect to repo and append to make.conf
	# mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
	mkdir --parents /mnt/gentoo/etc/portage/repos.conf
	cp \
		/mnt/gentoo/usr/share/portage/config/repos.conf \
		/mnt/gentoo/etc/portage/repos.conf/gentoo.conf
	echo "////////// PRINTING GENTOO CONF //////////"
	cat /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
	cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

	mount --types proc /proc /mnt/gentoo/proc
	mount --rbind /sys /mnt/gentoo/sys
	mount --make-rslave /mnt/gentoo/sys
	mount --rbind /dev /mnt/gentoo/dev
	mount --make-rslave /mnt/gentoo/dev
}

function enter_new_environment() {
	# TODO chroot commands here
}

presetup
setup_partitions
setup_date_and_time
setup_stage_tarball
setup_compile_options
setup_new_environment
enter_new_environment
