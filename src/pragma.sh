#!/usr/bin/env bash

source "$SRC_DIR"/logger.sh

# Input sanity checks
[[ $# == 0 ]] && err "No command provided!" && exit 1
[[ $# -gt 1 ]] && err "Too many arguments" && exit 1

# Cache/Environment sanity check
[[ -z "$SELECTED_DATABASE" ]] && err "No database selected" && exit 1

# Build Query
query="PRAGMA $1;"

# Write output
$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "Ran pragma command"
$jq "$OUTPUT_FILE" -u database = "$SELECTED_DATABASE"
$jq "$OUTPUT_FILE" -u target.table = "$SELECTED_TABLE"
$jq "$OUTPUT_FILE" -u operation = "PRAGMA"
$jq "$OUTPUT_FILE" -u query = "$query"
