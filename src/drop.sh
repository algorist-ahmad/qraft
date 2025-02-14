#!/usr/bin/env bash

source "$SRC_DIR"/logger.sh
source "$SRC_DIR"/utils.sh

[[ $# -lt 2 ]] && err "Too few arguments!" && exit 1
[[ $# -gt 2 ]] && err "Too many arguments!" && exit 1

type=$1
name=$2

QUERY="DROP "

# get table name
case "$type" in
  view) QUERY+="VIEW $name" ;;
  table) QUERY+="TABLE $name" ;;
  *) err "First argument must be 'view' or 'table'" && exit 1 ;;
esac

# check existence
DATABASE_FILE=${DATABASE_FILE:-$($jq "$CACHE_FILE" database.file)}
[[ -z "$DATABASE_FILE" ]] && err "No database loaded. Please, load a database first!" && exit 1
sqlite3 "$DATABASE_FILE" "SELECT 1 FROM $name LIMIT 1" &>/dev/null || { err "Loaded database does not contain $type '$name'" && exit 1; }

# drop table/view
$jq "$OUTPUT_FILE" -u success = true
$jq "$OUTPUT_FILE" -u message = "Dropped $type '$name' from database '$DATABASE_FILE'"
$jq "$OUTPUT_FILE" -u database = "$DATABASE_FILE"
$jq "$OUTPUT_FILE" -u target.table = "$name"
