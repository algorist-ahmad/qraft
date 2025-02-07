#!/bin/bash

# UPDATE script to generate an SQL UPDATE query.

source "$SRC_DIR"/logger.sh
source "$SRC_DIR"/utils.sh

# Parse from string into an indexed array
eval pre_args=($pre_args)

# Input sanity checks
[[ $# == 0 ]] && err "Please specify some values to add into the table" && exit 1
[[ -z $SELECTED_DATABASE ]] && err "No database loaded! Please, load a database first" && exit 1
[[ ${#pre_args} == 0 && $SELECTED_TABLE == null ]] && err "Please, select a table to add values into" && exit 1

get_symbol() {
    for symbol in '!=' '>=' '<=' '=' '<' '>' '~'; do
        [[ $1 == *"$symbol"* ]] && echo $symbol && return 0
    done
    return 1
}

# get table
if ! get_symbol "${pre_args[0]}" > /dev/null; then
    pre_args_table="${pre_args[0]}"
    pre_args=(${pre_args[@]:1})
fi

table=${pre_args_table:-$SELECTED_TABLE}
[[ -z $table ]] && err "Table name cannot be empty" && exit 1

filters=()
# get filters
for pair in "${pre_args[@]}"; do
    symbol=$(get_symbol "$pair")
    [[ -z "$symbol" ]] && err "Inavlid filter '$pair'" && exit 1
    key="${pair%%"$symbol"*}"
    val="${pair#*"$symbol"}"

    case "$symbol" in
        '='|'!=') ! is_number "$val" && [[ $val != null ]] && val="'$val'" ;;
        '~') val="'$val'" ;;
    esac

    case "$symbol" in
        '!=') symbol="<>" ;;
        '~') symbol="LIKE" ;;
    esac

    filters+=("$key $symbol $val")
done

## Build query
query="UPDATE $table SET"
for pair in "$@"; do
    [[ $1 != *=* ]] && err "Inavlid value '$1', values must contain a '=' symbol" && exit 1
    key="${pair%%=*}"
    val="${pair#*=}"
    ! is_number "$val" && val="'$val'"
    query+=" $key = $val"
done

## Append filters
if [[ ${#filters[@]} -gt 0 ]]; then
    query+=" WHERE ${filters[0]}"
    for filter in "${filters[@]:1}"; do
        query+=" AND $filter"
    done
fi

# Write to output JSON
$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "Updated table '$table'"
$jq "$OUTPUT_FILE" -u database = "$SELECTED_DATABASE"
$jq "$OUTPUT_FILE" -u target.table = "$table"
$jq "$OUTPUT_FILE" -u operation = "UPDATE"
$jq "$OUTPUT_FILE" -u qeury = "$query"
