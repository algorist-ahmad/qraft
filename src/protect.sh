#!/usr/bin/env bash

source "$SRC_DIR"/utils.sh
source "$SRC_DIR"/logger.sh

if [[ $1 == "./"* || $1 = "/"* ]]; then
    filename=$1
elif [[ -f "$CACHE_FILE" ]] && contains "$1" $(sqlite3 $($jq "$CACHE_FILE" database.file) .tables); then
    table=$1
else
    filename=$1
fi

if [[ -n $table ]]; then
    temp_file=$(mktemp)
    database=$($jq "$CACHE_FILE" database.file)
    jq --arg table "$table" \
        --arg database "$database" \
        'map(if .database==$database then if (.protected | type) != "array" then .protected=[$table] else if (.protected | index($table) == null) then .protected += [$table] end end end)' \
        "$DATABASES_FILE" > "$temp_file"
    mv "$temp_file" "$DATABASES_FILE"
    $jq "$OUTPUT_FILE" -u message = "Table '$table' was successfully protected!"
elif [[ -n $filename ]]; then
    file_full=$(real_path "$filename")
    [[ ! -f $file_full ]] && err "Cannaot access '$filename': No such database or table" && exit 1
    sqlite3 "$file_full" .tables &>/dev/null || { err "Cannot protect '$filename': Not a database"; exit 1; }
    contains "$file_full" $(list_attached_databases) || { err "Cannot protect '$filename': Not attached/loaded yet"; exit 1; }

    temp_file=$(mktemp)
    jq --arg database "$file_full" 'map(if .database==$database then .protected = ["*"] end)' "$DATABASES_FILE" > "$temp_file"
    mv "$temp_file" "$DATABASES_FILE"

    $jq "$OUTPUT_FILE" -u message = "Database '$file_full' was successfully protected!"
else
    err "No argument provided. Please, provide a table or database file name"
    exit 1
fi

$jq "$OUTPUT_FILE" -u success = true
