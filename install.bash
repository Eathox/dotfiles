#!/bin/bash

set -e

backup () {
	local TARGET=".zshrc"
	local BACKUP_LOC="$HOME/$TARGET-backup"

	echo "Backing up original files to '$BACKUP_LOC'"
	if [[ -e "$BACKUP_LOC" ]]; then
		echo "Error: file '$BACKUP_LOC' already exists, aborting"
		exit
	fi

	mkdir "$BACKUP_LOC"
	if [[ -e "$HOME/$TARGET" ]]; then
		mv "$HOME/$TARGET" "$BACKUP_LOC/$TARGET"
	else
		echo ".zshrc doesnt exsist, skipping"
	fi
}

link () {
	local TARGETS=(".zshrc" ".zshrc.functions")

	echo "Linking: " "${TARGETS[@]}"
	for TARGET in "${TARGETS[@]}"; do
		cp -i "$TARGET" "$HOME"
		rm "$TARGET"
		ln "$HOME/$TARGET" "$TARGET"
	done
}

backup
link
