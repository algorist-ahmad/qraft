#!/bin/bash

# INSERT script to generate an SQL INSERT query.

output_file=""
db_file=""
target=""
values=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -output) output_file="$2"; shift ;;
        -in) db_file="$2"; shift ;;
        -into) target="$2"; shift ;;
        -values) values="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate mandatory fields
if [[ -z "$output_file" || -z "$db_file" || -z "$target" || -z "$values" ]]; then
    echo '{"success": false, "message": "Missing mandatory arguments"}' > "$output_file"
    exit 1
fi

# Handle default values
if [[ "$values" == "default" ]]; then
    query="INSERT INTO ${target} DEFAULT VALUES;"
else
    IFS=' ' read -r -a values_array <<< "$values"
    columns=""
    vals=""
    for pair in "${values_array[@]}"; do
        key="${pair%%=*}"
        val="${pair#*=}"
        columns+="$key, "
        vals+="'$val', "
    done
    columns="${columns%, }"
    vals="${vals%, }"
    query="INSERT INTO ${target} ($columns) VALUES ($vals);"
fi

# Write to output JSON
jq -n --arg db "$db_file" --arg query "$query" \
   '{success: true, message: "Query building succeeded", database: $db, operation: "INSERT", query: $query}' \
   > "$output_file"
