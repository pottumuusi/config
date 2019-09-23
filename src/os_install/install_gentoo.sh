#!/bin/bash

set -ex

main_block_device="/dev/vda"

# label: dos
# label-id: 0x25a3d9ff
# unit: sectors
#
# start=        2048, size=     4194304, type=83, bootable
# start=     4196352, size=     8388608, type=82
# start=    12584960, size=    50329600, type=8e
saved_partition_table="./saved_partition_table"
boot_partition_dev="${main_block_device}1"
swap_partition_dev="${main_block_device}2"
lvm_partition_dev="${main_block_device}3"

volgroup_name="vg01"
root_size="14G"
home_size="10G"

root_partition_dev="/dev/${volgroup_name}/root"
home_partition_dev="/dev/${volgroup_name}/home"

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
