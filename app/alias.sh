#!/usr/bin/env bash

# Add aliases am="ruby #{pwd}/acct_mg.rb" in ~/.aliases
AM_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/acct_mg.rb"

echo "Detected current working directory: $AM_PATH"

AM_ALIAS="alias am=\"ruby $AM_PATH\""

if [ ! -f "$HOME/.aliases" ]; then
	echo "No ~/.aliases found in system, creating and adding alias..."
	echo $AM_ALIAS >> "$HOME/.aliases"
else
	if ! grep -q "$AM_ALIAS" "$HOME/.aliases" ; then
		echo "No alias exist, adding alias..."
		echo $AM_ALIAS >> "$HOME/.aliases"
	else
		echo "Alias already exists, do nothing!"	
	fi	
fi	

# Add if [-f ~/.aliases ]; then . ~/.aliases fi in ~/.zshrc
BASH_ALIAS_CMD="if [ -f ~/.aliases ]; then\n . ~/.aliases\nfi"

# TODO: Better grep to check if the command exists
if ! grep "aliases" "$HOME/.zshrc" ; then
	echo "No bash alias command found in .zshrc, adding command..."
	echo $BASH_ALIAS_CMD >> "$HOME/.zshrc"
else
	echo "Command already exists in .zshrc, do nothing!"
fi

. ~/.zshrc
# source ~/.bashrc