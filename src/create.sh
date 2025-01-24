#!/usr/bin/env bash

source "$SRC_DIR"/utils.sh
source "$SRC_DIR"/logger.sh

[[ $# == 0 || $1 != "table" ]] && err "Wrong usage! The command should start with \`qraft create table\`." && exit 1
shift

[[ $# -lt 3 ]] && err "Too few arguments! You should provide at least a table name, a column name, and its datatype" && exit 1
table=$1
shift

is_odd $# && err "Wrong usage! Each column name should be associated with exactly one datatype" && exit 1

database=$($jq "$CACHE_FILE" database.file)
[[ -z $database || $database == null ]] && err "No connected database found. Please, connect a database before creating a table!" && exit 1
eval protected=("$(jq --arg database "$database" '.[] | select(.database==$database) | .protected | .[]' "$DATABASES_FILE")")
contains '*' "${protected[@]}" && err "Cannot add table! Database '$database' is protected" && exit 1
contains "$table" $(sqlite3 "$database" .tables) && err "Table '$table' already exists in connected database. Please use \`alter\` command!" && exit 1

columns=()
datatypes=()

while [[ $# -gt 0 ]]; do
    columns+=("$1")
    datatypes+=("$2")
    shift 2
done

QUERY="CREATE TABLE $table("

for i in $(seq 0 $((${#columns[@]} - 1))); do
    [[ $i != 0 ]] && QUERY+=", "
    QUERY+="${columns[$i]} ${datatypes[$i]}"
done

QUERY+=")"

$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "Created table '$table' successfully!"
$jq "$OUTPUT_FILE" -u query = "$QUERY"
