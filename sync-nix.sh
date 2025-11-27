#!/run/current-system/sw/bin/bash

# Pull and Push dotfiles script #
set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Files to ignore during sync
IGNORED_FILES=("sync-nix.sh" "LICENSE" "README.md" ".gitignore" ".git")

# Check if file should be ignored
should_ignore() {
	local filename=$(basename "$1")
	for ignored in "${IGNORED_FILES[@]}"; do
		if [ "$filename" = "$ignored" ]; then
			return 0
		fi
	done
	return 1
}

# Pull nix-config from /etc/nixos to repo
pull_nix_config() {
	echo -e "${YELLOW}Pulling nix-config from /etc/nixos...${NC}"

	if [ ! -d /etc/nixos ]; then
		echo -e "${RED}✗ Error: /etc/nixos directory not found${NC}"
		return 1
	fi

	# Remove existing config files (except ignored ones)
	for item in /etc/nixos/*; do
		local basename_item=$(basename "$item")
		if ! should_ignore "$basename_item" && [ "$basename_item" != "flake.lock" ]; then
			local target="./$basename_item"
			if [ -e "$target" ]; then
				echo -e "${YELLOW}Removing existing $basename_item...${NC}"
				rm -rf "$target"
			fi
		fi
	done

	# Copy files from /etc/nixos (except ignored ones and flake.lock)
	for item in /etc/nixos/*; do
		local basename_item=$(basename "$item")
		if ! should_ignore "$basename_item" && [ "$basename_item" != "flake.lock" ]; then
			echo -e "${YELLOW}Copying $basename_item...${NC}"
			cp -r "$item" "./"
		fi
	done

	echo -e "${GREEN}✓ nix-config pulled successfully${NC}"
}

# Push nix-config from repo to /etc/nixos
push_nix_config() {
	echo -e "${YELLOW}Pushing nix-config to /etc/nixos...${NC}"

	COMMIT_FILE="/etc/nixos/.commit"
	SHOULD_UPDATE=false

	# Check if .commit file exists
	if [ ! -f "$COMMIT_FILE" ]; then
		# File doesn't exist - get short commit hash and create it
		echo -e "${YELLOW}No .commit file found, creating one...${NC}"

		# Get short commit hash
		SHORT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
		echo "$SHORT_COMMIT" >"$COMMIT_FILE"

		# Copy config files to /etc/nixos (excluding ignored files)
		for item in ./*; do
			local basename_item=$(basename "$item")
			if ! should_ignore "$basename_item"; then
				echo -e "${YELLOW}Copying $basename_item to /etc/nixos...${NC}"
				cp -r "$item" /etc/nixos/
			fi
		done

		echo -e "${GREEN}✓ .commit file created with: $SHORT_COMMIT${NC}"
		echo -e "${GREEN}✓ nix-config pushed to /etc/nixos${NC}"
		SHOULD_UPDATE=true
	else
		# File exists - compare commit hashes
		echo -e "${YELLOW}Comparing commit hashes...${NC}"

		STORED_COMMIT=$(cat "$COMMIT_FILE")
		CURRENT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

		if [ "$CURRENT_COMMIT" = "$STORED_COMMIT" ]; then
			# Commits match - verify /etc/nixos has no changes
			echo -e "${GREEN}✓ Commit hashes match ($CURRENT_COMMIT)${NC}"
			echo -e "${YELLOW}Checking for changes in /etc/nixos...${NC}"

			# Build exclude options for diff
			EXCLUDE_OPTS=""
			for ignored in "${IGNORED_FILES[@]}"; do
				EXCLUDE_OPTS="$EXCLUDE_OPTS --exclude=$ignored"
			done
			EXCLUDE_OPTS="$EXCLUDE_OPTS --exclude=.commit --exclude=flake.lock"

			# Compare current directory with /etc/nixos
			DIFF_OUTPUT=$(diff -r . /etc/nixos $EXCLUDE_OPTS 2>&1 || true)

			if [ -n "$DIFF_OUTPUT" ]; then
				echo -e "${RED}✗ Differences found between repo and /etc/nixos:${NC}"
				echo -e "${RED}$DIFF_OUTPUT${NC}"
				echo -e "${RED}✗ Aborting push operation${NC}"
				return 1
			else
				echo -e "${GREEN}✓ Configurations are identical${NC}"
				echo -e "${GREEN}✓ nix-config already synced${NC}"
			fi
		else
			# Commits don't match - current commit is newer
			echo -e "${YELLOW}Current commit ($CURRENT_COMMIT) differs from stored commit ($STORED_COMMIT)${NC}"
			echo -e "${YELLOW}Updating .commit file and syncing /etc/nixos...${NC}"

			# Update the commit file with current commit
			echo "$CURRENT_COMMIT" >"$COMMIT_FILE"

			# Copy config files to /etc/nixos (excluding ignored files)
			for item in ./*; do
				local basename_item=$(basename "$item")
				if ! should_ignore "$basename_item"; then
					echo -e "${YELLOW}Copying $basename_item to /etc/nixos...${NC}"
					cp -r "$item" /etc/nixos/
				fi
			done

			echo -e "${GREEN}✓ .commit file updated to: $CURRENT_COMMIT${NC}"
			echo -e "${GREEN}✓ nix-config pushed to /etc/nixos${NC}"
			SHOULD_UPDATE=true
		fi
	fi

	# Launch nix-update only if we made changes
	if [ "$SHOULD_UPDATE" = true ]; then
		echo -e "${YELLOW}Launching nix-update...${NC}"

		# Alias: nix-update
		sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --upgrade --accept-flake-config --flake /etc/nixos && flatpak update -y
	fi
}

# Main script logic
main() {
	if [ $# -eq 0 ]; then
		echo "Usage: $0 <command>"
		echo ""
		echo "Commands:"
		echo "  pull    - Pull nix-config from /etc/nixos"
		echo "  push    - Push nix-config to /etc/nixos and run nix-update"
		return 1
	fi

	case "$1" in
	pull)
		pull_nix_config
		;;
	push)
		push_nix_config
		;;
	*)
		echo -e "${RED}✗ Unknown command: $1${NC}"
		echo "Available commands: pull, push"
		return 1
		;;
	esac
}

main "$@"
