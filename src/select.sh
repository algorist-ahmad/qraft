#!/usr/bin/env bash

source "$SRC_DIR"/logger.sh
source "$SRC_DIR"/utils.sh
source "$SRC_DIR"/utils/parse_filters.sh

# Prepend $pre_args to $@
eval "pre_args=($pre_args)"
set -- "${pre_args[@]}" "$@"

# Sanity checks
[[ $# == 0 ]] && err "Please, provide at least one filter" && exit 1
[[ -z "$SELECTED_DATABASE" ]] && err "No database selected" && exit 1

# Parse filters
parse_filters "$@" || exit $?

table=${table:-$SELECTED_TABLE}
[[ -z "$table" ]] && err "No table provided. Please, select or provide a table name" && exit 1

# Build query
query="SELECT "

if [[ "${#columns[@]}" -gt 0 ]]; then
    query+=$(join_str ", " "${columns[@]}")
else
    query+="*"
fi

query+=" FROM $table"

[[ "${#filters[@]}" -gt 0 ]] && query+=" WHERE $(join_str " AND " "${filters[@]}")"
[[ -n "$order_by" ]] && query+=" ORDER BY $order_by"
[[ -n "$limit" ]] && query+=" LIMIT $limit"
[[ -n "$offset" ]] && query+=" ORDER BY $offset"
[[ -n "$group_by" ]] && query+=" GROUP BY $group_by"

# Write output
$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "Fetch data from table '$table'"
$jq "$OUTPUT_FILE" -u database = "$SELECTED_DATABASE"
$jq "$OUTPUT_FILE" -u target.table = "$table"
$jq "$OUTPUT_FILE" -u operation = "QUERY"
$jq "$OUTPUT_FILE" -u query = "$query;"
