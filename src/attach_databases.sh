#!/usr/bin/env bash

source "$SRC_DIR"/logger.sh
source "$SRC_DIR"/utils.sh

# Give positional arguments a variable name, so we can access them by name later
ARGUMENTS=("$@")

# Get real paths of the database files as expected by the user
declare -a DATABASE_FILES
for ARG in "$@"; do
    DATABASE_FILES+=("$(real_path "$ARG")")
done

# Validate input
error_codes=()
non_existent=()
invalid=()
for i in $(seq 0 $(($# - 1)) ); do
    ARG=${ARGUMENTS[$i]}
    FILE=${DATABASE_FILES[$i]}

    # Validate existence
    [[ ! -f "$FILE" ]] && non_existent+=("$ARG") && error_codes+=(2) && continue

    # Validate file type
    error_msg=$(sqlite3 "$FILE" '.tables' 2>&1 1>/dev/null)
    [[ "$error_msg" == *"not a database"* ]] && invalid+=("$ARG") && error_codes+=(3)
done

# Exit with error if invalid input was found
error_code=$(max_of "${error_codes[@]}")
if [[ -n "$error_code" ]]; then
  error_message=""

  if [[ ${#non_existent[@]} -gt 0 ]]; then
    error_message+="Following files do not exist:"$'\n'
    for FILE in "${non_existent[@]}"; do
      error_message+="  $FILE"$'\n'
    done
  fi

  if [[ ${#invalid[@]} -gt 0 ]]; then
    error_message+="Following files are not valid sqlite databases:"$'\n'
    for FILE in "${invalid[@]}"; do
      error_message+="  $FILE"$'\n'
    done
  fi

  $jq $OUTPUT_FILE -u success = false
  $jq $OUTPUT_FILE -u message = "$error_message"
  exit "$error_code"
fi


# Add files to databases list
for FILE in "${DATABASE_FILES[@]}"; do
  tmp_file=$(mktemp)
  touch "$DATABASES_FILE"  # Cretae databases file if does not exist already
  [[ $(head -c1 "$DATABASES_FILE") != "[" ]] && echo '[]' > "$DATABASES_FILE"  # Initialze databases file to an empty array if it was empty (or malformed)
  jq "if (any(.database == \"$FILE\") | not) then . + [{\"database\": \"$FILE\"}] end" "$DATABASES_FILE" > "$tmp_file"  # Add entry for the database (if does not already exist)
  mv "$tmp_file" "$DATABASES_FILE"
done

$jq $OUTPUT_FILE -u success = true
$jq $OUTPUT_FILE -u message = "Multiple databases attached successfully"
