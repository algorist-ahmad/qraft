#!/bin/bash

# DELETE script to generate an SQL DELETE query.

source "$SRC_DIR"/logger.sh
source "$SRC_DIR"/utils.sh
source "$SRC_DIR"/utils/parse_filters.sh

# Parse from string into an indexed array
eval pre_args=($pre_args)

# Input sanity checks
[[ -z $SELECTED_DATABASE ]] && err "No database loaded! Please, load a database first" && exit 1
[[ ${#pre_args} == 0 && $SELECTED_TABLE == null ]] && err "Please, select a table to add values into" && exit 1

# get table
if ! get_symbol "${pre_args[0]}" > /dev/null; then
    pre_args_table="${pre_args[0]}"
    pre_args=(${pre_args[@]:1})
fi

table=${pre_args_table:-$SELECTED_TABLE}
[[ -z $table ]] && err "Table name cannot be empty" && exit 1

## Get filters (saved in 'filters' global variable)
STRICT_MODE=1 parse_filters "${pre_args[@]}" || exit $?

## Build query
query="DELETE FROM $table"
if [[ ${#filters[@]} -gt 0 ]]; then
    query+=" WHERE ${filters[0]}"
    for filter in "${filters[@]:1}"; do
        query+=" AND $filter"
    done
else
    err "Please, provide at least one filter"
    exit 1
fi

# Write to output JSON
$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "Deleted records from table '$table'"
$jq "$OUTPUT_FILE" -u database = "$SELECTED_DATABASE"
$jq "$OUTPUT_FILE" -u target.table = "$table"
$jq "$OUTPUT_FILE" -u operation = "DELETE"
$jq "$OUTPUT_FILE" -u qeury = "$query"
