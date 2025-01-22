
# helpers/simple utilities

real_path() { cd "$WORK_DIR" && realpath -Lm -- "$1" && cd - >/dev/null; }
set_env() { echo "${ENV[$1]}"; }
get_file() { echo "${FILE[$1]}"; }
get_error_msg() { echo "${ERROR[$1]}"; }
is_null() { [[ "$1" == "$NULL" ]] }         # is equal to defined null value
is_true() { [[ "$1" != "0" ]] }              # NOT 0
is() { [[ -n "$1" ]] }                      # non-empty
not() { [[ -z "$1" ]] || [[ "$1" == '0' ]] || [[ "$1" == 'false' ]] } # returns positive if $1 is 0, 'false', or empty

max_of() {
  max=$1
  shift

  while [[ "$#" != 0 ]]; do
    [[ $1 -gt $max ]] && max=$1
    shift
  done

  echo "$max"
}

contains() {
  needle=$1
  shift

  while [[ $# != 0 ]]; do
    [[ $1 == "$needle" ]] && return 0
    shift
  done

  return 1
}

list_attached_databases() {
    jq '.[].database' "$DATABASES_FILE" | sed -E 's/^"|"$//g'
}
