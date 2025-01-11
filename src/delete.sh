#!/bin/bash

# DELETE script to generate an SQL DELETE query.

output_file=""
db_file=""
target=""
filter=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -output) output_file="$2"; shift ;;
        -in) db_file="$2"; shift ;;
        -from) target="$2"; shift ;;
        -where) filter="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate mandatory fields
if [[ -z "$output_file" || -z "$db_file" || -z "$target" ]]; then
    echo '{"success": false, "message": "Missing mandatory arguments"}' > "$output_file"
    exit 1
fi

# Build final query
query="DELETE FROM ${target} WHERE ${filter:-1=1};"

# Write to output JSON
jq -n --arg db "$db_file" --arg query "$query" \
   '{success: true, message: "Query building succeeded", database: $db, operation: "DELETE", query: $query}' \
   > "$output_file"
