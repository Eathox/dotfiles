#!/usr/bin/env bash

set -e

DOTFILES_BACKUP_LOC="$HOME/dotfiles-backup"

get_user_answer () {
	PROMPT=$1
	USER_ANSWER=""
	while [[ $USER_ANSWER != "y" && $USER_ANSWER != "n" ]]; do
		echo -n "$PROMPT"
		read -r USER_ANSWER
	done
}

backup_file () {
	local FILE="$1"
	local FILE_DIR="$2"

	local FILE_LOC
	if [[ "$FILE_DIR" == "" ]]; then
		FILE_LOC="$FILE"
	else
		FILE_LOC="$FILE_DIR/$FILE"
	fi
	local BACKUP_LOC="$DOTFILES_BACKUP_LOC/$FILE_LOC"

	if [[ ! -f "$HOME/$FILE_LOC" ]]; then
		echo "File '$HOME/$FILE_LOC' doesn't exist, skipping"
	fi

	echo "Backing up '$FILE' -> '$BACKUP_LOC'"
	if [[ -e $BACKUP_LOC ]]; then
		if [[ ! -f "$BACKUP_LOC" ]]; then
			echo "Error: '$BACKUP_LOC' is an directory, aborting."
			exit
		fi

		echo "File '$BACKUP_LOC' already exists"
		get_user_answer "would you like to overwrite? (y/n): "

		if [[ $USER_ANSWER != "y" ]]; then
			return 1
		fi
	fi

	mkdir -p "${BACKUP_LOC%/*}"
	mv "$HOME/$FILE_LOC" "$BACKUP_LOC"
	return 0
}

link_file () {
	local FILE="$1"
	local FILE_DIR="$2"

	local FILE_LOC
	if [[ "$FILE_DIR" == "" ]]; then
		FILE_LOC="$FILE"
	else
		FILE_LOC="$FILE_DIR/$FILE"
	fi

	cp "$FILE" "$HOME/$FILE_LOC"
	rm "$FILE"

	echo "Linking: '$FILE' <- '$HOME/$FILE_LOC'"
	ln "$HOME/$FILE_LOC" "$FILE"
}

install () {
	declare -A ALL_FILE=(
		[".zshrc"]=""
		[".zshrc.functions"]=""
		[".p10k.zsh"]=""
		["color.conf"]="TermStart/config"
	)

	for FILE in "${!ALL_FILE[@]}"; do
		FILE_DIR="${ALL_FILE[$FILE]}"

		if backup_file "$FILE" "$FILE_DIR"; then
			link_file "$FILE" "$FILE_DIR"
		else
			echo "Skipping backup and linking"
		fi
		echo ""
	done
}

install
