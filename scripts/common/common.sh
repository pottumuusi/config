readonly bin_dir="$repo_root/bin"
readonly data_dir="$repo_root/data"
readonly config_dir="$repo_root/config"
readonly include_dir="$repo_root/include"

# TODO change include dir to $include_dir/bash
readonly out_dir="$repo_root/out"
readonly bash_include_dir="$include_dir/scripts/bash"
readonly scripts_common_dir="$repo_root/scripts/common"
readonly scripts_common_out_dir="$out_dir/scripts/common"
readonly cfgcongrol_out_dir="$out_dir/scripts/env/cfgcontrol"
readonly cfgcongrol_dir="$repo_root/scripts/env/cfgcontrol"

readonly scripts_common_file="$scripts_common_dir/common.sh"
readonly scripts_common_out_file="$scripts_common_out_dir/common.sh"
readonly shared_vars_file="$data_dir/shared_vars.sh"
readonly config_list_file="$data_dir/config_list.sh"
readonly old_config_list_file="$data_dir/config_list.sh.old"
readonly cfgcontrol_main_file="$cfgcongrol_dir/cfgcontrol.sh"
readonly cfgcontrol_out_main_file="$cfgcongrol_out_dir/cfgcontrol.sh"

readonly bash_interpreter_spec="#!/bin/bash"
readonly repo_name=$( basename $repo_root)
readonly scripts_common_file_name="$( basename $scripts_common_file )"
readonly bold=$(tput bold)
readonly normal=$(tput sgr0)

readonly autoadd_comment="# Added automatically by configure"
readonly source_scripts_common="\. common.sh"
readonly insert_common="\n\n$autoadd_comment\n$source_scripts_common"
readonly repo_envpath_entry="PATH=\"\$HOME/.$repo_name/bin:\$PATH\""
