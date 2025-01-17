#!/bin/bash

source "$SRC_DIR"/logger.sh
source "$SRC_DIR"/utils.sh

# Read all arguments (separated by whitespace; extra whitespace is ignored)
read -ra DATABASE_FILES <<< "$1"

# verify input

DATABASE_FILES_COUNT=${#DATABASE_FILES[@]}

case $DATABASE_FILES_COUNT in
  0)
    err "Error: No database file provided."
    exit 1
    ;;
  1)
    DATABASE_FILE=$DATABASE_FILES
    # continue with the script
    ;;
  *)
    "$SRC_DIR"/attach_databases.sh "${DATABASE_FILES[@]}"
    exit
    ;;
esac

# Get full path of the database file as expected by the user
DATABASE_FILE_FULL=$(real_path "$DATABASE_FILE")

# test existance
[[ ! -f "$DATABASE_FILE_FULL" ]] && err "File $DATABASE_FILE_FULL does not exist." && exit 2

# test validity, save to cache if successful
error_msg=$(sqlite3 "$DATABASE_FILE_FULL" '.tables' 2>&1)
if [[ "$error_msg" == *"not a database"* ]]; then
    $jq $OUTPUT_FILE success = 'false'
    $jq $OUTPUT_FILE message = "$error_msg"
    exit 3
fi

# Update the database field in output.json
$jq $OUTPUT_FILE -u success = true
$jq $OUTPUT_FILE -u message = "Connection to $DATABASE_FILE successful"
$jq $OUTPUT_FILE -u database = $DATABASE_FILE_FULL
$jq $CACHE_FILE -u database.file = $DATABASE_FILE_FULL
$jq $CACHE_FILE -u database.tables = "$(sqlite3 "$DATABASE_FILE_FULL" .tables | tr -s ' ' '\n' | jq -R -s 'split("\n") | map(select(. != ""))')"
