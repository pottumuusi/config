#!/bin/bash

# Commands from following tutorial
# https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source

# Install prerequisite libraries + git
# sudo apt-get install libncurses5-dev libgnome2-dev libgnomeui-dev \
#     libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
#     libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
#     python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev git

# Remove vim if it already exists
# sudo apt-get remove vim vim-runtime gvim

# [IMPORTANT] on ubuntu 14.04 only python 2 or python 3 can be used. not both
# Get and compile vim
# cd ~
# git clone https://github.com/vim/vim.git

cd /mnt/shared_home/home/tank/vim_arch/vim
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-python3interp=yes \
            --with-python3-config-dir=/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu/ \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk2 --enable-cscope --prefix=/usr
#            --enable-pythoninterp=yes \
#            --with-python-config-dir=/usr/lib/python2.7/config \

make VIMRUNTIMEDIR=/usr/share/vim/vim80
sudo make install

# Use checkinstall for easy uninstall
# sudo apt-get install checkinstall
# cd ~/vim
# sudo checkinstall

# Set vim as default editor
# sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
# sudo update-alternatives --set editor /usr/bin/vim
# sudo update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
# sudo update-alternatives --set vi /usr/bin/vim

# Get vundle plugin manager here to avoid browsing
if [ ! -d /mnt/shared_home/home/tank/vim_arch/Vundle ] ; then
	git clone https://github.com/VundleVim/Vundle.vim.git /mnt/shared_home/home/tank/vim_arch/Vundle
fi
