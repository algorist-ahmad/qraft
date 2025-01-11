#!/bin/bash

# UPDATE script to generate an SQL UPDATE query.

output_file=""
db_file=""
target=""
operands=""
filter=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -output) output_file="$2"; shift ;;
        -in) db_file="$2"; shift ;;
        -target) target="$2"; shift ;;
        -set) operands="$2"; shift ;;
        -where) filter="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate mandatory fields
if [[ -z "$output_file" || -z "$db_file" || -z "$target" || -z "$operands" ]]; then
    echo '{"success": false, "message": "Missing mandatory arguments"}' > "$output_file"
    exit 1
fi

# Parse operands
set_clause=""
IFS=' ' read -r -a ops_array <<< "$operands"
for pair in "${ops_array[@]}"; do
    key="${pair%%=*}"
    val="${pair#*=}"
    set_clause+="$key='$val', "
done
set_clause="${set_clause%, }"

# Build final query
query="UPDATE ${target} SET ${set_clause} WHERE ${filter:-1=1};"

# Write to output JSON
jq -n --arg db "$db_file" --arg query "$query" \
   '{success: true, message: "Query building succeeded", database: $db, operation: "UPDATE", query: $query}' \
   > "$output_file"
