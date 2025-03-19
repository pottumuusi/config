#!/bin/bash

set -e

main() {
    local -r workarea_directory='/tmp/config_workarea'
    local -r vim_colors_directory="${HOME}/.vim/colors"

    if [ ! -d "${vim_colors_directory}" ] ; then
        mkdir ${vim_colors_directory}
    fi

    if [ ! -d "${workarea_directory}" ] ; then
        mkdir ${workarea_directory}
    fi

    pushd ${workarea_directory}

    wget https://github.com/romainl/flattened/archive/refs/heads/master.zip
    unzip master.zip
    cp --verbose ./flattened-master/colors/flattened_dark.vim ${vim_colors_directory}/

    popd # ${workarea_directory}

    rm --verbose --recursive ${workarea_directory}
}

main "${@}"
