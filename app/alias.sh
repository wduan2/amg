#!bin/usr/bash

# Add aliases am="ruby #{pwd}/acct_mg.rb" in ~/.aliases
AM_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/acct_mg.rb"

echo "detect working directory is: $AM_PATH"

AM_ALIAS="alias am=\"ruby $AM_PATH\""

if [ ! -f "$HOME/.aliases" ]; then
	echo "no ~/.aliases found in system, creating and adding alias..."
	echo $AM_ALIAS >> "$HOME/.aliases"
else
	if ! grep -q "$AM_ALIAS" "$HOME/.aliases" ; then
		echo "no alias exist, adding alias..."
		echo $AM_ALIAS >> "$HOME/.aliases"
	else
		echo "alias already exists, do nothing"	
	fi	
fi	

# Add if [-f ~/.aliases ]; then . ~/.aliases fi in ~/.zshrc and ~/.bashrc
BASH_ALIAS_CMD="if [ -f ~/.aliases ]; then\n . ~/.aliases\nfi"

# TODO: Better grep to check if the command exists
if ! grep "aliases" "$HOME/.bashrc" ; then
	echo "no bash alias command found, adding command..."
	echo $BASH_ALIAS_CMD >> "$HOME/.bashrc"
else
	echo "command already exists, do nothing"
fi

# TODO: Doesn't work for .zshrc
source ~/.bashrc
