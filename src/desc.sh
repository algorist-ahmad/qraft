#!/usr/bin/env bash

source "$SRC_DIR"/logger.sh
source "$SRC_DIR"/utils.sh

# Prepend $pre_args into $@
eval "pre_args=($pre_args)"
set -- "${pre_args[@]}" "$@"

# Sanity checks
[[ $# -lt 1 ]] && err "Please, provide a table name" && exit 1
[[ $# -gt 1 ]] && err "Too many arguments" && exit 1
[[ -z "$SELECTED_DATABASE" ]] && err "No database selected" && exit 1

table=$1

# Write output
$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "Describe table '$table'"
$jq "$OUTPUT_FILE" -u database = "$SELECTED_DATABASE"
$jq "$OUTPUT_FILE" -u target.table = "$table"
$jq "$OUTPUT_FILE" -u query = ".schema $table"
