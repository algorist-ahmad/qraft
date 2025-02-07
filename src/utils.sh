
# helpers/simple utilities

real_path() { cd "$WORK_DIR" && realpath -Lm -- "$1" && cd - >/dev/null; }
set_env() { echo "${ENV[$1]}"; }
get_file() { echo "${FILE[$1]}"; }
get_error_msg() { echo "${ERROR[$1]}"; }
is_null() { [[ "$1" == "$NULL" ]] }         # is equal to defined null value
is_true() { [[ "$1" != "0" ]] }              # NOT 0
is() { [[ -n "$1" ]] }                      # non-empty
not() { [[ -z "$1" ]] || [[ "$1" == '0' ]] || [[ "$1" == 'false' ]] } # returns positive if $1 is 0, 'false', or empty
is_number() { [[ $1 =~ ^[-+]?[0-9]+\.?[0-9]*$ ]]; }
is_even() { return $(($1 % 2)); }
is_odd() { ! is_even "$1"; }

max_of() {
  max=$1
  shift

  while [[ "$#" != 0 ]]; do
    [[ $1 -gt $max ]] && max=$1
    shift
  done

  echo "$max"
}

get_index() {
  needle=$1
  shift
  count=$#

  while [[ $# != 0 ]]; do
    [[ $1 == "$needle" ]] && echo "$((count - $#))" && return 0
    shift
  done

  return 1
}

contains() {
  get_index "$@" > /dev/null
}

list_attached_databases() {
    jq '.[].database' "$DATABASES_FILE" | sed -E 's/^"|"$//g'
}
