#!/bin/bash
ROOT=$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")") # path to this project root dir
ENV=$ROOT/.env

# Load environment variables from .env
[ -f $ENV ] && source $ENV || echo '.env NOT FOUND!'

# general syntax: qraft <filter> <operator> <operands>

declare -A ARG=(
    [input]="$@"
    [output_mode]=$MODE
    [database]=$DATABASE
    [target]=$TABLE      # or select
    [operation]='SELECT' # SELECT, INSERT, UPDATE, DELETE, ALTER, PRAGMA
    [default]=0
    [connect]=0
    [protect]=0
    [create]=0
    [alter]=0
    [rename]=0
    [drop]=0
    [list]=0             # list db / list tables
    [desc]=0
    [filter]=            # assumed to be filter until operation found. Filters are naturally joined by AND, unless otherwise specified: table:col1,col2,col3 col1>80//col1<100 col2=A//B//C//D//E col3~shit%//%ass
    [operands]=          # or mods
    [limit]=0            # LIMIT <INT>
    [shift]=0            # OFFSET <INT>
    [ordering]=          # ORDER BY <COL> ASC(+)/DESC(-)
    [grouping]=          # GROUP BY
    [insert]=0
    [update]=0
    [delete]=0
    [transaction]=
    [pragma]=0
    [export]=0
    [import]=0
    [interactive]=0
    [debug]=0
    [help]=0
    [version]=0
)

main() {
    initialize   # setup environment and check for missing files
    parse "$@"   # break input for analysis
    dispatch     # execute the operation
    terminate    # execute post-script tasks regardless of operation
}

initialize() {
  # load list of cached databases and tables
  # attempt connection to $DATABASE
  # other verifications making sure its working
  # DO NOT put existence tests and validity tests outside this function
#   cat "$JSON_OUTPUT_FILE" 
  cd $ROOT
  cp aux/output.json tmp/output.json
}

parse() {

    # how it works:
    # all arguments are assumed to be filters save for a few speciasl commands
    # until an operation is uttered. Once this occurs, all subsequent arguments
    # are considered operands. The parser will do its best to parse operands,
    # but a secondary parser may be needed for cases with complex arguments.
    # special flags like --debug may be placed anywhere, order does not matter.

    # indicates whether current arg has been parsed already or not
    parsed=
    # indicates whether a key operation has been mentionned
    operand_mode=
    
    # Iterate over arguments using a while loop
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --debug | debug)
                if not ${ARG[debug]} ; then
                  ARG[debug]=1
                  parsed=true
                fi
            ;;&
            -h | --help)
                if not ${ARG[help]} ; then
                  ARG[help]=1
                  parsed=true
                fi
            ;;&
            -c | --connect | --db | connect | load | db)
                if not ${ARG[connect]} ; then
                  ARG[connect]=1
                  parsed=true
                  operand_mode=true
                fi
            ;;&
            -p | --protect )
                if not ${ARG[protect]} ; then
                  ARG[protect]=1
                  parsed=true
                  operand_mode=true
                fi
            ;;&
            create )
                if not ${ARG[create]} ; then
                  ARG[create]=1
                  parsed=true
                  operand_mode=true
                fi
            ;;&
             )
                if not ${ARG[]} ; then
                  ARG[]=1
                  parsed=true
                  operand_mode=true
                fi
            ;;&
             )
                if not ${ARG[]} ; then
                  ARG[]=1
                  parsed=true
                  operand_mode=true
                fi
            ;;&
             )
                if not ${ARG[]} ; then
                  ARG[]=1
                  parsed=true
                  operand_mode=true
                fi
            ;;&
# qraft alter table <TABLE> add <COLUMN> <DATATYPE>
# qraft alter table <TABLE> rename to <NEW_TABLE>
# qraft drop table <TABLE>
# qraft drop view <VIEW>
# qraft tables
# qraft desc <TABLE>
# qraft <TABLE> desc
# qraft
# qraft <TABLE>
# qraft select <TABLE>
# qraft target <TABLE>
# qraft <FILE>/<TABLE>
# qraft <FILTER>
# qraft col=abc
# qraft col!=abc
# qraft col\>99
# qraft col\<99
# qraft col ge 99
# qraft col le 99
# qraft col~pattern
# qraft col is null
# qraft col is not null
# qraft col in (value1, value2, ...)
# qraft col not in (value1, value2, ...)
# qraft col between value1 and value2
# qraft col not between value1 and value2
# qraft condition1 and condition2
# qraft condition1 or condition2
# qraft not condition
# qraft col regexp pattern
# qraft col = (select ...)
# qraft col in (select ...)
# qraft exists (select ...)
# qraft not exists (select ...)
# qraft lim=99
# qraft shift=99
# qraft +<COL>
# qraft -<COL>
# qraft group <COL>
# qraft [TABLE] add <COL1>=x <COL2>=y <COL3>=z
# qraft [TABLE] add default
# qraft [TABLE] <FILTER> set <COL1>=x <COL2>=y <COL3>=z
# qraft [TABLE] <FILTER> del
# qraft transaction begin
# qraft transaction commit
# qraft transaction rollback
# qraft pragma <COMMAND>
# qraft export <TABLE> to <FILE>
# qraft import <FILE> into <TABLE>
# -i
# --verbose
# --help
# --version

            --)
                # break this loop and consider remaining args as operands
                shift ; break
            ;;&
            *)
                # if not parsed yet, and if not in operand mode,then dump in filters. Else, dump in operands
                if is $parsed; then
                    : # do nothing
                elif is $operand_mode; then
                    ARG[operands]+=" $1"
                else
                    ARG[filter]+=" $1"
                fi
            ;;
        esac
        shift ; parsed= # discard argument and reset variables
    done

    # if args remain, dump into ARG[operands]
    if [[ $# -gt 0 ]]; then ARG[operands]+=" $@"; fi
}

dispatch() {

    e= # error
    
    # if an error is detected, output to stderr immediately
    if [[ $e -gt 0 ]]; then
        echo "Error: $(get_error_msg $e)" >&2
        exit $e
    fi

    cd $ROOT/src

    is_empty ${ARG[input]} && run_default
    is_true ${ARG[help]} && print_help
    is_true ${ARG[connect]} && ./load_database.sh "${ARG[operands]}"
    is_true ${ARG[protect]} && ./protect.sh
}

terminate() {

    # final_message=
    # error_number=

    # if debug is true, reveal variables
    is_true ${ARG[debug]} && reveal_variables

    # # if there are any errors, print
    # [[ $error_number -gt 0 ]] && echo -e "$error_msg"

    # # if there are any final messages, print
    # [[ -n "$final_message" ]] && echo -e "\n$final_message"

    # exit $error_number

    # print results
    cat $ROOT/tmp/output.json
}

print_help() {
    bat $(get_file help)
}

run_default() {
    echo "no args, idk what to do"
}

# Loop through the keys of the associative array and print key-value pairs
reveal_variables() {
    local yellow="\033[33m"
    local green="\033[32m"
    local red="\033[31m"
    local purple="\033[35m"
    local cyan="\033[36m"
    local reset="\033[0m"

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
