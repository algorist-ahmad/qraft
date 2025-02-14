#!/usr/bin/env bash

source "$SRC_DIR"/logger.sh
source "$SRC_DIR"/utils.sh

# Input sanity checks
[[ $# -lt 3 ]] && err "Too few arguments!" && exit 1
[[ $# -gt 3 ]] && err "Too many arguments" && exit 1
[[ $2 != 'into' ]] && err "Invalid argument '$2'" && exit 1

# Cache/Environment sanity check
[[ -z "$SELECTED_DATABASE" ]] && err "No database selected" && exit 1

table=$3
file=$1

# Build Query
query="
.mode tab
.import '$file' '$table'
"

# Write output
$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "Imported table '$table' from file '$file'"
$jq "$OUTPUT_FILE" -u database = "$SELECTED_DATABASE"
$jq "$OUTPUT_FILE" -u target.table = "$table"
$jq "$OUTPUT_FILE" -u operation = "IMPORT"
$jq "$OUTPUT_FILE" -u query = "$query"
