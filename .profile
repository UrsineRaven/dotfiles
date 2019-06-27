#!/bin/sh
# Profile file. Runs on login.

# Set environment variables
export EDITOR="vim"


# If this is triggered by Bash (as opposed to a tty) and the bashrc exists, then load the bashrc
echo "$0" | grep "bash$" >/dev/null && [ -f ~/.bashrc ] && source "$HOME/.bashrc"

# Start X if on tty1 and i3 is not already running
[ "$(tty)" = "/dev/tty1" ] && ! pgrep -x i3 >/dev/null && exec startx

