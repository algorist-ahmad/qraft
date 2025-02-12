#!/bin/bash

# INSERT script to generate an SQL INSERT query.

source "$SRC_DIR"/logger.sh

# Parse from string into an indexed array
eval pre_args=($pre_args)

[[ ${#pre_args[@]} -gt 1 ]] && err "Can only add values into exactly one table" && exit 1
[[ $# == 0 ]] && err "Please specify some values to add into the table" && exit 1
[[ -z $SELECTED_DATABASE ]] && err "No database loaded! Please, load a database first" && exit 1
[[ ${#pre_args} == 0 && $SELECTED_TABLE == null ]] && err "Please, select a table to add values into" && exit 1

table=${pre_args[0]:-$SELECTED_TABLE}
[[ -z $table ]] && err "Table name cannot be empty" && exit 1

query="INSERT INTO $table"
# Handle default values
if [[ "$*" == "default" ]]; then
    query+=" DEFAULT VALUES;"
else
    # Parse arguments
    columns=""
    vals=""
    for pair in "$@"; do
        [[ $1 != *=* ]] && err "Inavlid value '$1', values must contain a '=' symbol" && exit 1
        key="${pair%%=*}"
        val="${pair#*=}"
        columns+="$key, "
        vals+="'$val', "
    done
    columns="${columns%, }"
    vals="${vals%, }"
    query+=" ($columns) VALUES ($vals);"
fi

# Write to output JSON
$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "Added values into table '$table'"
$jq "$OUTPUT_FILE" -u database = "$SELECTED_DATABASE"
$jq "$OUTPUT_FILE" -u target.table = "$table"
$jq "$OUTPUT_FILE" -u operation = "INSERT"
$jq "$OUTPUT_FILE" -u query = "$query"
