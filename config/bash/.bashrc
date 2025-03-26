# setxkbmap fi -option caps:swapescape
setxkbmap en_US
xset r rate 170 30
set -o vi

# export GIT_EDITOR=vim
export EDITOR=vim

if [ -f "${HOME}/.bash_aliases" ] ; then
	source ${HOME}/.bash_aliases
fi

eval "$(dircolors ~/.dir_colors)"
