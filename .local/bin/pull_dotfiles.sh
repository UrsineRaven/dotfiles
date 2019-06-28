#!/bin/bash
# This script pulls UrsineRaven's dotfiles, and checks them out to the 
# appropriate places. It will backup any pre-existing dotfiles to 
# $HOME/.dotfiles-backup
#
# NOTE: This script assumes that you have git installed.
# 
# Sources: https://www.atlassian.com/git/tutorials/dotfiles

git clone --bare https://github.com/UrsineRaven/dotfiles.git $HOME/.dotfiles
function dotfiles {
	/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}
dotfiles checkout
if [ $? = 0 ]; then
	echo "Successfully checked out dot files."
else
	echo "Backing up pre-existing dot files."
	mkdir $HOME/.dotfiles-backup
	dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} sh -c 'mkdir -p "$HOME/.dotfiles-backup/$(dirname {}); mv $HOME/{} $HOME/.dotfiles-backup/{} ;'
	dotfiles checkout
fi
dotfiles config --local status.showUntrackedFiles no
