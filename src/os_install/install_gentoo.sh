#!/bin/bash

set -ex

cd $(dirname $0)
script_root="$(pwd)"

source util.sh

# TODO Make it possible to select which steps to execute.

readonly DISABLED="TRUE"
readonly main_block_device="/dev/sda"
# TODO
# * merge the URL variables
# * use netcologne instead of gentoo.org
# readonly frozen_stage3_release_dir="http://distfiles.gentoo.org/releases/amd64/autobuilds/20200101T214502Z/"
readonly frozen_stage3_release_dir="https://mirror.netcologne.de/gentoo/releases/amd64/autobuilds/current-stage3-amd64/"
# Current stage3 tar name will change, as it contains version of the most
# recent stage3 release. Parse the name from webpage.
readonly stage3_tar="$(curl ${frozen_stage3_release_dir} | grep --color=auto stage3 | grep amd64 | grep tar | grep -v multilib | grep -v -e CONTENTS -e DIGESTS | cut -d ">" -f 2 | cut -d "<" -f 1)"
# readonly stage3_tar="stage3-amd64-20200101T214502Z.tar.xz"

# readonly stage3_remote_dir="https://mirror.netcologne.de/gentoo/releases/amd64/autobuilds/current-stage3-amd64/"
# readonly stage3_tarball_remote_full_path="${stage3_remote_dir}/${stage3_tarball_filename}"
# readonly stage3_tarball_filename="stage3-amd64-20190929T214502Z.tar.xz"
# readonly stage3_tarball_contents_filename="stage3-amd64-20190929T214502Z.tar.xz.CONTENTS "
# readonly stage3_tarball_digests_filename="stage3-amd64-20190929T214502Z.tar.xz.DIGESTS"
# readonly stage3_tarball_digests_asc_filename="stage3-amd64-20190929T214502Z.tar.xz.DIGESTS.asc"

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

function presetup() {
	if [ "TRUE" != "${DISABLED}" ] ; then
		# Was not able to connect to sks-keyservers.net
		gpg --keyserver hkps://hkps.pool.sks-keyservers.net --recv-keys 0xBB572E0E2D182910
	fi
	wget -O- https://gentoo.org/.well-known/openpgpkey/hu/wtktzo4gyuhzu8a4z5fdj3fgmr1u6tob?l=releng | gpg --import
}

function setup_date_and_time() {
	echo "////////// SETTING DATE AND TIME //////////"
	if [ "TRUE" != "${DISABLED}" ] ; then
		emerge net-misc/ntp
		ntpd -q -g # TODO test that works. Time may be correct out of the box
	fi
}

function setup_partitions() {
	echo "////////// PARTITIONING //////////"
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

	mount ${root_partition_dev} /mnt/gentoo
	mkdir /mnt/gentoo/boot
	mkdir /mnt/gentoo/home
	mount ${boot_partition_dev} /mnt/gentoo/boot
	mount ${home_partition_dev} /mnt/gentoo/home
}

function setup_stage_tarball() {
	echo "////////// INSTALLING STAGE TARBALL //////////"
	pushd /mnt/gentoo
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
	# gpg --verify ${stage3_tarball_digests_asc_filename}

	readonly signed_sum="$(grep -A1 SHA512 ${stage3_tar}.DIGESTS.asc | head -2 | grep -v SHA512)"
	readonly calculated_sum="$(sha512sum ${stage3_tar})"
	if [ "${signed_sum}" != "${calculated_sum}" ] ; then
		error_exit "Stage 3 tar sums do not match."
	fi

	# tar xpvf ${stage3_tarball_filename} --xattrs-include='*.*' --numeric-owner
	tar xpvf ${stage3_tar} --xattrs-include='*.*' --numeric-owner
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

	cp ${make_conf} /mnt/gentoo/etc/portage/make.conf
	mkdir --parents /mnt/gentoo/etc/portage/repos.conf
	cp \
		/mnt/gentoo/usr/share/portage/config/repos.conf \
		/mnt/gentoo/etc/portage/repos.conf/gentoo.conf
	cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

	mount --types proc /proc /mnt/gentoo/proc
	mount --rbind /sys /mnt/gentoo/sys
	mount --make-rslave /mnt/gentoo/sys
	mount --rbind /dev /mnt/gentoo/dev
	mount --make-rslave /mnt/gentoo/dev
}

function pre_chroot_install() {
	presetup
	setup_partitions
	setup_date_and_time
	setup_stage_tarball
	setup_compile_options
	setup_new_environment
}

function post_chroot_install() {
	echo "post_chroot_install not yet implemented"
}

function main() {
	# TODO use arguments to select whether to run pre_chroot_install + chroot OR post_chroot_install
	pre_chroot_install

	# TODO chroot commands here
	echo TODO chroot commands her

	post_chroot_install
}

main
