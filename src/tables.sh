#!/usr/bin/env bash

source "$SRC_DIR"/logger.sh
source "$SRC_DIR"/utils.sh

# Sanity checks
[[ $# -gt 0 ]] && err "Too many arguments; No arguments supported" && exit 1
[[ -z "$SELECTED_DATABASE" ]] && err "No database selected" && exit 1

# Write output
$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "List all tables and views"
$jq "$OUTPUT_FILE" -u database = "$SELECTED_DATABASE"
$jq "$OUTPUT_FILE" -u target.table = "$SELECTED_TABLE"
$jq "$OUTPUT_FILE" -u query = ".tables"
