#!/bin/bash

# SELECT script to generate an SQL SELECT query.
echo "SELECT TRIGGERED: $@"
output_file=""
db_file=""
target=""
filter=""
modifier=""
grouping=""
ordering=""
limit=""
offset=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -output) output_file="$2"; shift ;;
        -in) db_file="$2"; shift ;;
        -from) target="$2"; shift ;;
        -where) filter="$2"; shift ;;
        -modifier) modifier="$2"; shift ;;
        -groupby) grouping="$2"; shift ;;
        -orderby) ordering="$2"; shift ;;
        -limit) limit="$2"; shift ;;
        -offset) offset="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate mandatory fields
if [[ -z "$output_file" || -z "$db_file" || -z "$target" ]]; then
    jq ".success = false | .message = Missing mandatory arguments" "$output_file" > "$output_file"
    exit 1
fi

# Parse target (table and columns)
table_name="${target%%:*}"
columns="${target#*:}"

# Resolve columns (handle exclusion, ordering)
columns_sql="*"
if [[ "$columns" != "$table_name" ]]; then
    IFS=',' read -r -a col_array <<< "$columns"
    columns_sql=""
    for col in "${col_array[@]}"; do
        case $col in
            +*) ordering+="${col:1} ASC," ;;
            -*) ordering+="${col:1} DESC," ;;
            !*) ;; # Excluded column, do nothing
            *) columns_sql+="$col, " ;;
        esac
    done
    columns_sql="${columns_sql%, }"
    ordering="${ordering%, }"
fi

# Parse filters
filters_sql=""
if [[ -n "$filter" ]]; then
    filters_sql="WHERE $filter"
fi

# Parse limit and offset
limit_sql=""
if [[ -n "$limit" ]]; then
    if [[ "$limit" == *"+"* ]]; then
        lim="${limit%%+*}"
        off="${limit##*+}"
        limit_sql="LIMIT $lim OFFSET $off"
    else
        limit_sql="LIMIT $limit OFFSET ${offset:-0}"
    fi
fi

# Build final query
query="SELECT ${modifier} ${columns_sql} FROM ${table_name} ${filters_sql} ${grouping:+GROUP BY $grouping} ${ordering:+ORDER BY $ordering} ${limit_sql};"

# Write to output JSON
jq -n --arg db "$db_file" --arg query "$query" \
   --arg table "$table_name" --arg columns "$columns_sql" \
   '{success: true, message: "Query building succeeded", database: $db, target: {table: $table, columns: ($columns | split(", "))}, operation: "SELECT", query: $query}' \
   > "$output_file"
