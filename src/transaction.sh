#!/usr/bin/env bash

source "$SRC_DIR"/logger.sh

# Input sanity checks
[[ $# == 0 ]] && err "No action provided!" && exit 1
[[ $# -gt 1 ]] && err "Too many arguments" && exit 1

# Cache/Environment sanity check
[[ -z "$SELECTED_DATABASE" ]] && err "No database selected" && exit 1

# Retrieve action
case $1 in
    begin) action=BEGIN; past=Began ;;
    commit) action=COMMIT; past=Committed ;;
    rollback) action=ROLLBACK; past="Rolled back" ;;
    *) err "Invalid argument '$1'" && exit 1
esac

# Build Query
query="$action TRANSACTION"

# Write output
$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "$past transaction"
$jq "$OUTPUT_FILE" -u database = "$SELECTED_DATABASE"
$jq "$OUTPUT_FILE" -u target.table = "$SELECTED_TABLE"
$jq "$OUTPUT_FILE" -u operation = "$query"
$jq "$OUTPUT_FILE" -u query = "$query;"
