#!/bin/bash

source "$SRC_DIR"/logger.sh
source "$SRC_DIR"/utils.sh

# Read all arguments (separated by whitespace; extra whitespace is ignored)
read -ra DATABASE_FILES <<< "$1"

# verify input

DATABASE_FILES_COUNT=${#DATABASE_FILES[@]}

no_database_error() {
  err "Error: No database file provided."
  exit 1
}

case $DATABASE_FILES_COUNT in
  0)
    if [[ -f "$DATABASES_FILE" ]]; then
      # load ~/.cache/qraft/databases (ignore empty lines && one line = one database file)
      DATABASES=()
      while IFS= read -r line; do
        [[ -n "$line" ]] && DATABASES+=("$line")
      done <<< "$(grep -vE '^[[:space:]]*$' "$DATABASES_FILE")"

      case ${#DATABASES[@]} in
        0)
          no_database_error
          ;;
        1)
          DATABASE_FILE=$DATABASES
          ;;
        *)
          # ask user to choose from databases listed in ~/.cache/qraft/databases
          while select DATABASE_FILE in "${DATABASES[@]}"; do break; done; do
            [[ -n "$DATABASE_FILE" ]] && break || echo "Please, choose a valid entry or press Ctrl+D to abort!" >&2
          done

          [[ -z "$DATABASE_FILE" ]] && no_database_error
          ;;
      esac
    else
      no_database_error
    fi
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
if [[ ! -f "$DATABASE_FILE_FULL" ]]; then
  TABLE=${DATABASE_FILE##*/}
  DATABASE_FILE=${DATABASE_FILE%/*}
  DATABASE_FILE_FULL=$(real_path "$DATABASE_FILE")

  if [[ ! -f "$DATABASE_FILE_FULL" ]]; then
    err "File $DATABASE_FILE_FULL does not exist." && exit 2
  fi
fi

# test validity, save to cache if successful
error_msg=$(sqlite3 "$DATABASE_FILE_FULL" '.tables' 2>&1)
if [[ "$error_msg" == *"not a database"* ]]; then
    $jq $OUTPUT_FILE success = 'false'
    $jq $OUTPUT_FILE message = "$error_msg"
    exit 3
fi

# Attach database
"$SRC_DIR"/attach_databases.sh "$DATABASE_FILE"

# Load table if specified
if [[ -n "$TABLE" ]]; then
  export DATABASE_FILE
  "$SRC_DIR"/target.sh "$TABLE" || exit 1
else
  $jq $CACHE_FILE -u database.table = null
  $jq $OUTPUT_FILE -u message = "Connection to $DATABASE_FILE successful"
fi

# Update the database field in output.json
$jq $OUTPUT_FILE -u success = true
$jq $OUTPUT_FILE -u database = $DATABASE_FILE_FULL
$jq $CACHE_FILE -u database.file = $DATABASE_FILE_FULL
$jq $CACHE_FILE -u database.tables = "$(sqlite3 "$DATABASE_FILE_FULL" .tables | tr -s ' ' '\n' | jq -R -s 'split("\n") | map(select(. != ""))')"
