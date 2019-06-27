#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# My additions

# Aliases
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Other

# Files in .hidden files are ignored by ls
# NOTES: Not tolerant of empty lines (or lines with only whitespace)
#        If any argument doesn't begin with a '-', this assumes it's a file argument
ls () {
	DEFAULT_ARGS="--color=auto"
	ALL=false
	A=0
	F=0
	I=0
	declare -a ARGS
	declare -a FILES
	declare -a IGNORE
	for a in $@
	do
		if [[ $a =~ ^-(a|[^-]+a) ]]; then
			ALL=true
			break
		fi
		if [[ $a =~ ^[^-].* ]]; then
			FILES[$F]=$a
			((F++))
		else
			ARGS[$A]=$a
			((A++))
		fi
	done
	if $ALL; then
		command ls ${DEFAULT_ARGS} ${@}
		return
	else
		if [ ${#FILES[@]} -eq 0 ]; then
			FILES[$F]="."
		fi
		for f in ${FILES[*]}
		do
			if [ -f "${f}/.hidden" ]; then

				while read l; do

					IGNORE[$I]="-I $l"
					((I++))
				done <"${f}/.hidden"
			fi
		done
		command ls ${DEFAULT_ARGS} ${ARGS[*]} ${IGNORE[*]} ${FILES[*]}
		return
	fi
}
