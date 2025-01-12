#!/bin/bash

source $ROOT/src/logger.sh

# Trim leading and trailing whitespace from the filename
DATABASE_FILE=$(echo "$1" | xargs)
# OUTPUT_FILE=$(echo "$2" | xargs)

# Verify input
[[ -z "$@" ]] && err "Error: No database file provided." && exit 1

# test existance
[[ ! -f "$DATABASE_FILE" ]] && err "File $DATABASE_FILE does not exist." && exit 2

# test validity, save to cache if successful
error_msg=$(sqlite3 "$DATABASE_FILE" '.tables' 2>&1)
if [[ "$error_msg" == *"not a database"* ]]; then
    $jq $OUTPUT_FILE success = 'false'
    $jq $OUTPUT_FILE message = "$error_msg"
    exit 3
fi

# Update the database field in output.json
$jq $OUTPUT_FILE -u success = true
$jq $OUTPUT_FILE -u message = "Connection to $DATABASE_FILE successful"
$jq $OUTPUT_FILE -u database = $DATABASE_FILE
$jq $CACHE_FILE -u database.file = $DATABASE_FILE
$jq $CACHE_FILE -u database.tables = "$(sqlite3 "$DATABASE_FILE" .tables | tr -s ' ' '\n' | jq -R -s 'split("\n") | map(select(. != ""))')"
