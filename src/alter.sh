#!/usr/bin/env bash

source "$SRC_DIR"/utils.sh
source "$SRC_DIR"/logger.sh

[[ $# == 0 || $1 != "table" ]] && err "Wrong usage! The command should start with \`qraft create table\`." && exit 1
shift

[[ $# -lt 3 ]] && err "Too few arguments! You should provide at least a table name, and an action" && exit 1
table=$1
shift

QUERY="ALTER TABLE $table "
message=""

if [[ "$1" == rename && "$2" == to ]]; then
    if [[ $# -eq 3 ]]; then
        QUERY+="RENAME TO $3"
        message="Renamed table '$table' to '$3' successfully!"
    elif [[ $# -lt 3 ]]; then
        err "Too few arguments! Please, provide the new name to rename to"
        exit 1
    else
        shift 3
        err "Too many arguments! Not sure how to handle '$*'"
        exit 1
    fi
elif [[ $1 == add ]]; then
    shift
    if [[ $# -ge 2 ]]; then
        QUERY+="ADD $*"
        message="Added column '$1' to table '$table' successfully!"
    else
        err "Too few arguments! Please, provide column name as well data type"
        exit 1
    fi
else
    err "Unknown argument '$1'"
    exit 1
fi

database=$($jq "$CACHE_FILE" database.file)
[[ -z $database || $database == null ]] && err "No connected database found. Please, connect a database before creating a table!" && exit 1

eval protected=("$(jq --arg database "$database" '.[] | select(.database==$database) | .protected | .[]' "$DATABASES_FILE")")
contains '*' "${protected[@]}" && err "Cannot alter table! Database '$database' is protected" && exit 1
contains "$table" "${protected[@]}" && err "Cannot alter table! Table '$table' is protected" && exit 1

$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "$message"
$jq "$OUTPUT_FILE" -u query = "$QUERY"
