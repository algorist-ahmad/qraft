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
    [alter]=0
    [rename]=0
    [list]=0             # list db / list tables
    [desc]=0
    [filter]=            # assumed to be filter until operation found. Filters are naturally joined by AND, unless otherwise specified: table:col1,col2,col3 col1>80//col1<100 col2=A//B//C//D//E col3~shit%//%ass
    [operands]=          # or mods
    [limit]=0            # LIMIT <INT>
    [shift]=0            # OFFSET <INT>
    [ordering]=          # ORDER BY <COL> ASC(+)/DESC(-)
    [grouping]=0         # GROUP BY
    [select]=1
    [insert]=0
    [update]=0
    [delete]=0
    [transac]=0
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
    # indicates last option entered so the parser knows where to place the next argument
    last_opt=
    
    # Iterate over arguments using a while loop
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --debug | debug)
                if not ${ARG[debug]} ; then
                  ARG[debug]=1
                  last_opt= # this opt does not accept parameters
                  parsed=true
                fi
            ;;&
            -h | --help)
                if not ${ARG[help]} ; then
                  ARG[help]=1
                  ARG[select]=0
                  last_opt= # this opt does not accept parameters
                  parsed=true
                fi
            ;;&
            -v | --version)
                if not ${ARG[version]} ; then
                  ARG[version]=1
                  ARG[select]=0
                  last_opt= # this opt does not accept parameters
                  parsed=true
                fi
            ;;&
            -c | --connect | --db | connect | load | db)
                if not ${ARG[connect]} ; then
                  last_opt=database
                  ARG[connect]=1 # dispatch to load_database
                  parsed=true
                fi
            ;;&
            -p | --protect)
                if not ${ARG[protect]} ; then
                  last_opt=protect
                  ARG[$last_opt]='' # prepare to accept args
                  ARG[select]=0
                  parsed=true
                fi
            ;;&
            -A | --alter)
                if not ${ARG[alter]} ; then
                  last_opt=alter
                  ARG[$last_opt]=''
                  ARG[select]=0
                  parsed=true
                fi
            ;;&
            -l | --list | list)
                if not ${ARG[list]} ; then
                  last_opt=list
                  ARG[$last_opt]=''
                  ARG[select]=0
                  parsed=true
                fi
            ;;&
            --desc | desc)
                if not ${ARG[desc]} ; then
                  last_opt=desc
                  ARG[$last_opt]=''
                  ARG[select]=0
                  parsed=true
                fi
            ;;&
            -t | --target | --table | target | select)
                if not ${ARG[target]} ; then
                  last_opt=target
                  ARG[$last_opt]=''
                  parsed=true
                fi
            ;;&
            -L | --limit | lim)
                if not ${ARG[limit]} ; then
                  last_opt=limit
                  ARG[$last_opt]=''
                  parsed=true
                fi
            ;;&
            -s | --shift | --offset | shift | offset)
                if not ${ARG[shift]} ; then
                  last_opt=shift
                  ARG[$last_opt]=''
                  parsed=true
                fi
            ;;&
            -g | --group)
                if not ${ARG[grouping]} ; then
                  last_opt=grouping
                  ARG[$last_opt]=''
                  parsed=true
                fi
            ;;&
            -a | -i | add | insert)
                if not ${ARG[insert]} ; then
                  last_opt=insert
                  ARG[$last_opt]=''
                  ARG[select]=0
                  parsed=true
                fi
            ;;&
            -m | -u | mod | set | update)
                if not ${ARG[update]} ; then
                  last_opt=update
                  ARG[$last_opt]=''
                  ARG[select]=0
                  parsed=true
                fi
            ;;&
            -d | del | delete | rm)
                if not ${ARG[delete]} ; then
                  last_opt=delete
                  ARG[$last_opt]=''
                  ARG[select]=0
                  parsed=true
                fi
            ;;&
            transac)
                if not ${ARG[transac]} ; then
                  last_opt=transac
                  ARG[$last_opt]=''
                  ARG[select]=0
                  parsed=true
                fi
            ;;&
            pragma)
                if not ${ARG[pragma]} ; then
                  last_opt=pragma
                  ARG[$last_opt]=''
                  ARG[select]=0
                  parsed=true
                fi
            ;;&
            export)
                if not ${ARG[export]} ; then
                  last_opt=export
                  ARG[$last_opt]=''
                  ARG[select]=0
                  parsed=true
                fi
            ;;&
            import)
                if not ${ARG[import]} ; then
                  last_opt=import
                  ARG[$last_opt]=''
                  ARG[select]=0
                  parsed=true
                fi
            ;;&
            --)
                # break this loop and consider remaining args as operands
                shift ; break
            ;;&
            +*)
                if not $parsed; then
                    column_name=${1:1} # remove the '+' symbol
                    ARG[ordering]+=" $column_name ASC,"
                    parsed=true
                fi
            ;;&
            -*)
                if not $parsed; then
                    column_name=${1:1} # remove the '-' symbol
                    ARG[ordering]+=" $column_name DESC,"
                    parsed=true
                fi
            ;;&
            *)
                # if not parsed yet, and if not in operand mode,then dump in filters. Else, dump in operands
                if is $parsed; then
                    : # do nothing
                elif is $last_opt; then
                    ARG[$last_opt]+=" $1"
                else
                    ARG[filter]+=" $1"
                fi
            ;;
        esac
        shift ; parsed= # discard argument and reset variables
    done

    # if args remain, dump into ARG[operands]
    # if [[ $# -gt 0 ]]; then ARG[operands]+=" $@"; fi
}

dispatch() {

    db="${ARG[database]}"
    target="${ARG[target]}"
    modifier= # DISTINCT
    operands="${ARG[operands]}"
    filter="${ARG[filter]}"
    grouping="${ARG[grouping]}"
    ordering="${ARG[ordering]}"
    lim=${ARG[limit]}
    shift=${ARG[shift]}
    e= # error
    
    # if an error is detected, output to stderr immediately
    if [[ $e -gt 0 ]]; then
        echo "Error: $(get_error_msg $e)" >&2
        exit $e
    fi

    cd $ROOT/src

    not ${ARG[input]} && run_default
    is_true ${ARG[help]} && print_help
    is_true ${ARG[connect]} && ./load_database.sh "${ARG[database]}"
    is_true ${ARG[protect]} && ./protect.sh

    is_true ${ARG[select]} && ./select.sh -from $target -in $db -where $filter -modifier $modifier -groupby $grouping -orderby $ordering -limit $lim -offset $shift
    is_true ${ARG[insert]} && ./insert.sh -into $target -in $db -values $operands
    is_true ${ARG[update]} && ./update.sh $target -set $operands -where $filter -in $db
    is_true ${ARG[delete]} && ./delete.sh -from $target -where $filter
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
    echo 'read README.md'
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
is_true() { [[ "$1" != "0" ]] }              # NOT 0
is() { [[ -n "$1" ]] }                      # non-empty
not() { [[ -z "$1" ]] || [[ "$1" == '0' ]] || [[ "$1" == 'false' ]] } # returns positive if $1 is 0, 'false', or empty

# helpers

main "$@"
