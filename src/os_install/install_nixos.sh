#/bin/bash

set -ex

volume_group="vg01"
boot_partition="/dev/nvme0n1p2"
swap_partition="/dev/nvme0n1p6"
nixos_root_name="dom0_nixos"
nixos_saved_config="~/config/useful-files/config/nixos/configuration.nix"

# loadkeys fi
# nix-env -i wget
# nix-env -i git

#### Activate LVM volumes in volume group
vgchange -a y ${volume_group}

swapon ${swap_partition}

mount /dev/${volume_group}/${nixos_root_name} /mnt
mkdir -p /mnt/boot
mount /dev/${volume_group}/${} /mnt/boot

nixos-generate-config --root /mnt
cp ${nixos_saved_config} /mnt/etc/nixos/configuration.nix

nixos-install
