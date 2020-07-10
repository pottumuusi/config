#!/bin/bash

set -ex

function bringup_ubuntu() {
	local -r USEFUL_FILES_DIR="${HOME}/my/util/useful-files"
	local -r USEFUL_FILES_CONFIG_DIR="${HOME}/my/util/useful-files/config"
	local -r VIM_COLORS_SOLARIZED_DIR="${HOME}/my/util/vim-colors-solarized"
	local -r VUNDLE_DIR="${HOME}/.vim/bundle/Vundle.vim"

	mkdir ${HOME}/util
	mkdir -p ${HOME}/.vim/colors

	git clone https://github.com/altercation/vim-colors-solarized.git ${VIM_COLORS_SOLARIZED_DIR}
	git clone https://github.com/pottumuusi/useful-files.git ${USEFUL_FILES_DIR}
	git clone https://github.com/VundleVim/Vundle.vim.git ${VUNDLE_DIR}

	mv ${VIM_COLORS_SOLARIZED_DIR}/solarized.vim ${HOME}/.vim/colors

	sudo apt-get update
	sudo apt-get install \
		neovim \
		tmux \
		eatmydata

	cp ${USEFUL_FILES_CONFIG_DIR}/bash/.bash_profile ${HOME}
	cp ${USEFUL_FILES_CONFIG_DIR}/nvim/.config/nvim/init.vim ${HOME}
	cp ${USEFUL_FILES_CONFIG_DIR}/vim/.vimrc ${HOME}
	cp ${USEFUL_FILES_CONFIG_DIR}/x/.Xmodmap ${HOME}
	# cp ${USEFUL_FILES_CONFIG_DIR}/x/.xinitrc ${HOME}
	cp ${USEFUL_FILES_CONFIG_DIR}/tmux/oh_my_tmux/.tmux.conf ${HOME}
	cp ${USEFUL_FILES_CONFIG_DIR}/tmux/oh_my_tmux/.tmux.conf.local ${HOME}

	source ${USEFUL_FILES_DIR}/src/git/aliases.sh
}

function main() {
	if [ -n "$(lsb_release -a | grep "Ubuntu")" ] ; then
		bringup_ubuntu
	fi
}

main
