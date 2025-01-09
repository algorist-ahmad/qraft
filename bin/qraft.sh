#!/bin/bash
ROOT=$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")") # path to this project root dir

# Load environment variables from .env
[ -f .env ] && source $ROOT/.env || echo '.env NOT FOUND!'

declare -A ARG=(
    [input]="$@"
    [output_mode]=$MODE
    [database]=$DATABASE
    [table]=$TABLE
    [operation]='SELECT' # SELECT, INSERT, UPDATE, DELETE, ALTER, PRAGMA
    [filter]=
    [modifications]=
)

main() {
    initialize   # setup environment and check for missing files
    parse "$@"   # break input for analysis
    dispatch     # execute the operation
    terminate    # execute post-script tasks regardless of operation
}

initialize() {
  :
}

parse() {

    # indicates whether current arg has been parsed already or not
    parsed=
    
    # Iterate over arguments using a while loop
    while [[ $# -gt 0 ]]; do
        case "$1" in
            # debug | --debug)
            #     if not ${ARG[debug]} ; then
            #       ARG[debug]=1
            #       parsed=true
            #     fi
            # ;;&
            help | --help | -h)
                if not ${ARG[help]} ; then
                  ARG[help]=1
                  parsed=true
                fi
            ;;&
            --)
                # break this loop and consider remaining args as operands
                shift ; break
            ;;&
            *)
                # if not parsed yet, treat as operand
                if not $parsed; then
                  ARG[operands]+=" $1"
                fi
            ;;
        esac
        shift ; parsed= # discard argument and reset variables
    done

    # if args remain, dump into ARG[operands]
    if [[ $# -gt 0 ]]; then ARG[operands]+=" $@"; fi
}

dispatch() {

    e="${ENV[error]}"
    root="${ENV[root]}"
    
    # if an error is detected, output to stderr immediately
    if [[ $e -gt 0 ]]; then
        echo "Error: $(get_error_msg $e)" >&2
        exit $e
    fi

    is_empty ${ARG[input]} && run_default
    is_true ${ARG[help]} && print_help
}

terminate() {

    final_message="${ENV[footer]}"
    error_number=${ENV[error]}

    # if debug is true, reveal variables
    is_true ${ARG[debug]} && reveal_variables

    # if there are any errors, print
    [[ $error_number -gt 0 ]] && echo -e "$error_msg"

    # if there are any final messages, print
    [[ -n "$final_message" ]] && echo -e "\n$final_message"

    exit $error_number
}

print_help() {
    bat $(get_file help)
}

run_default() {
    ${ENV[default_fn]}
}

# Loop through the keys of the associative array and print key-value pairs
reveal_variables() {
    local yellow="\033[33m"
    local green="\033[32m"
    local red="\033[31m"
    local purple="\033[35m"
    local cyan="\033[36m"
    local reset="\033[0m"

    echo -e "--- ARGUMENTS ---"
    for key in "${!ARG[@]}"; do
        value="${ARG[$key]}"
        value="${value%"${value##*[![:space:]]}"}"  # Trim trailing whitespace
        value="${value#"${value%%[![:space:]]*}"}"  # Trim leading whitespace
        color="$reset"

        if [[ $value == 'null' ]]; then
            value=""  # Null value
        elif [[ -z $value ]]; then
            value="EMPTY"  # Empty string
            color=$cyan    # Empty value
        elif [[ $value == '1' ]]; then
            color=$green   # True value
        elif [[ $value == '0' ]]; then
            color=$red     # False value
        fi

        printf "${yellow}%-20s${reset} : ${color}%s${reset}\n" "$key" "$value"
    done

    echo -e "--- ENVIRONMENT ---"
    for key in "${!ENV[@]}"; do
        value="${ENV[$key]}"
        value="${value%"${value##*[![:space:]]}"}"  # Trim trailing whitespace
        value="${value#"${value%%[![:space:]]*}"}"  # Trim leading whitespace
        color="$reset"

        if [[ $value == 'null' ]]; then
            value=""  # Null value
        elif [[ -z $value ]]; then
            value="EMPTY"  # Empty string
            color=$cyan    # Empty value
        elif [[ $value == '1' ]]; then
            color=$green   # True value
        elif [[ $value == '0' ]]; then
            color=$red     # False value
        fi

        printf "${yellow}%-20s${reset} : ${color}%s${reset}\n" "$key" "$value"
    done

    echo -e "--- FILES ---"
    for key in "${!FILE[@]}"; do
        value="${FILE[$key]}"
        value="${value%"${value##*[![:space:]]}"}"  # Trim trailing whitespace
        value="${value#"${value%%[![:space:]]*}"}"  # Trim leading whitespace
        color="$reset"

        if [[ $value == 'null' ]]; then
            value=""  # Null value
        elif [[ -z $value ]]; then
            value="EMPTY"  # Empty string
            color=$cyan    # Empty value
        elif [[ $value == '1' ]]; then
            color=$green   # True value
        elif [[ $value == '0' ]]; then
            color=$red     # False value
        fi

        printf "${yellow}%-20s${reset} : ${color}%s${reset}\n" "$key" "$value"
    done
}

# helpers

set_env() { echo "${ENV[$1]}"; }
get_file() { echo "${FILE[$1]}"; }
get_error_msg() { echo "${ERROR[$1]}"; }
is_null() { [[ "$1" == "$NULL" ]] }         # is equal to defined null value
is_true() { [[ "$1" -eq 1      ]] }         # deprecated, use is()
is_false() { [[ "$1" -eq 0 ]] }             # deprecated, use not()
is_empty() { [[ -z "$1" ]] }                # deprecated, use not()
is() { [[ -n "$1" ]] }  # non-empty
not() { [[ -z "$1" ]] || [[ "$1" == '0' ]] || [[ "$1" == 'false' ]] } # returns positive if $1 is 0, 'false', or empty

# helpers

main "$@"
