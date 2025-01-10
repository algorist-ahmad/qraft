#!/bin/bash

# Function to output error messages
output_error() {
    jq ".success = false | .message = \"$1\"" ./output.json > ./output.tmp && mv ./output.tmp ./output.json
    cat ./output.json
}

# attempt to connect to provided sqlite3 file and run test query
# if successful, update tmp/output.json by setting "database" to the given file path

# Verify input
if [[ -z "$1" ]]; then
    output_error "Error: No database file provided."
    exit 1
fi

# Trim leading and trailing whitespace from the filename
DATABASE_FILE=$(echo "$1" | xargs)

# Change directory to qraft/tmp to update output.json
cd ../tmp || { output_error "Error: Failed to change directory to '../tmp'"; exit 1; }

# Ensure the SQLite file exists in the correct directory
if [[ ! -f "$DATABASE_FILE" ]]; then
    output_error "File $DATABASE_FILE does not exist."
    exit 1
fi

# Run a test query
sqlite3 "$DATABASE_FILE" "SELECT 1;" > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    output_error "Error: Failed to connect to database or invalid SQLite file."
    exit 1
fi

# Ensure output.json exists; create if it doesn't
if [[ ! -f "./output.json" ]]; then
    echo "{\"success\": false, \"message\": \"Error: output.json not found. Creating a new one.\", \"database\": \"\", \"target\": \"\", \"columns\": \"\", \"operation\": \"\", \"filters\": [], \"modifications\": {}, \"grouping\": \"\", \"ordering\": [], \"limit\": 0, \"offset\": 0}" > ./output.json
fi

# Update the database field in output.json
jq --arg db "$DATABASE_FILE" '.database = $db | .success = true | .message = "Database loaded successfully"' ./output.json > ./output.tmp && mv ./output.tmp ./output.json

# Show results
cat ./output.json
