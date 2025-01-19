#!/usr/bin/env bash

source "$SRC_DIR"/logger.sh

# get table name
case $# in
  0) err "No argument provided. Please, provide name of a table to select!" ;;
  1) TABLE=$1 ;;
  *) err "Too many arguments. Only one table can be selected at once!" ;;
esac

# check table existence
if [[ -z "$TABLE" ]]; then
  err "No table provided!" && exit 1
else
  DB_ADJECTIVE=$(test -n "$DATABASE_FILE" && echo "Provided" || echo "Loaded")
  DATABASE_FILE=${DATABASE_FILE:-$($jq "$CACHE_FILE" database.file)}
  [[ -z "$DATABASE_FILE" ]] && err "No database loaded. Please, load a database first!" && exit 1
  sqlite3 "$DATABASE_FILE" "SELECT 1 FROM $TABLE LIMIT 1" &>/dev/null || { err "$DB_ADJECTIVE database does not contain table '$TABLE'" && exit 1; }
fi

# load table
$jq "$CACHE_FILE" -u database.table = "$TABLE"
$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "Loaded table '$TABLE' from database '$DATABASE_FILE'"
$jq "$OUTPUT_FILE" -u target.table = "$TABLE"
