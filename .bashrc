#!/bin/bash
# Bash "Run Commands"; The configuration file for Bash.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# My additions ############################################

# Aliases
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Other

# File names in .hidden files are ignored by ls
# NOTES: Not tolerant of empty lines (or lines with only whitespace) in the .hidden file(s)
#	 If any argument doesn't begin with a '-', this assumes it's a file argument
#	 If you pass multiple folders, it will essentially concatenate the .hidden files and ignore all files matching any of those names (so if you have a file name TEST in two folders, but only have TEST in the .hidden file of one folder, calling ls on both folders won't show either TEST file)
#	 It does honor the -a flag
#	 I don't know if there's a limit on total number of flags or total command length, but if there is, this may surpass it depending on the number of file names in the .hidden file
ls () {
	DEFAULT_ARGS="--color=auto" # Here, because I want colors (and you can't have a function and an alias with the same name)
	ALL=false
	A=0
	F=0
	I=0
	declare -a ARGS
	declare -a FILES
	declare -a IGNORE
	for a in $@
	do
		if [[ $a =~ ^-(a|[^-]+a) ]]; then # If the -a flag is present
			ALL=true
			break
		fi
		if [[ $a =~ ^[^-].* ]]; then # If the argument doesn't start with '-', add it to the Files array
			FILES[$F]=$a
			((F++))
		else			     # Otherwise add it to the Args array
			ARGS[$A]=$a
			((A++))
		fi
	done
	if $ALL; then
		command ls ${DEFAULT_ARGS} ${@}
		return
	else
		if [ ${#FILES[@]} -eq 0 ]; then # If no files/directories are present, explicitly add the implied .
			FILES[$F]="."
		fi
		for f in ${FILES[*]}
		do
			if [ -f "${f}/.hidden" ]; then # Read the .hidden file, if present, and generate the -I flags
				IGNORE[$I]=$(awk '{print "-I " $0}' "${f}/.hidden" | tr "\n" " ")
				((I++))
			fi
		done
		command ls ${DEFAULT_ARGS} ${ARGS[*]} ${IGNORE[*]} ${FILES[*]}
		return
	fi
}

# Script that works like a basic feed reader
source ~/.local/bin/feed-reader.sh
alias archnews='deef archnews'
