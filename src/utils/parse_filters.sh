source "$SRC_DIR"/utils.sh

get_symbol() {
    for symbol in '!=' '>=' '<=' '=' '<' '>' '~'; do
        [[ $1 == *"$symbol"* ]] && echo $symbol && return 0
    done
    return 1
}

_parse_single_filter() {
    symbol=$(get_symbol "$1")

    [[ -z "$symbol" ]] && return

    key="${1%%"$symbol"*}"
    val="${1#*"$symbol"}"

    case "$key" in
        lim|limit|shift|+*|-*)
            [[ "$STRICT_MODE" = 1 ]] && err "Invalid filter '$1'" && return 1
        ;;
    esac

    case "$key" in
        lim|limit) declare -g limit=$val; return ;;
        shift) declare -g offset=$val; return ;;
        +*) declare -g order_by="$val ASC"; return ;;
        -*) declare -g order_by="$val DESC"; return ;;
    esac

    case "$symbol" in
        '='|'!=') ! is_number "$val" && val="'$val'" ;;
        '~') val="'$val'" ;;
    esac

    case "$symbol" in
        '!=') symbol="<>" ;;
        '~') symbol="LIKE" ;;
    esac

    filters+=("$key $symbol $val")
}

parse_filters() {
    declare -ga filters=()
    declare -ga columns=()

    last_filter=""
    last_symbol=""
    for pair in "$@"; do
        if [[ "$last_filter" == "group" ]]; then
            if [[ "$STRICT_MODE" == 1 ]]; then
                err "Invalid filter '$last_filter'"
                return 1
            else
                declare -g group_by=$pair
            fi
        elif [[ -n $last_filter && -z $last_symbol ]]; then
            case $pair in
                group|limit|lim|shift|+*|-*) ;;
                "null")
                    filters+=("$last_filter = null")
                    ;;
                "!null")
                    filters+=("$last_filter <> null")
                    ;;
                *)
                    if [[ "$STRICT_MODE" == 1 ]]; then
                        err "Inavlid filter '$last_filter'"
                        return 1
                    else
                        columns+=("$last_filter")
                        _parse_single_filter "$pair"
                    fi
                    ;;
            esac
        else
            _parse_single_filter "$pair"
        fi

        last_filter=$pair
        last_symbol=$(get_symbol "$pair")
    done

    if [[ -n $last_filter && -z $last_symbol ]] && ! contains "$last_filter" 'null' '!null'; then
        if [[ $STRICT_MODE == 1 ]]; then
            err "Inavlid filter '$last_filter'"
            return 1
        elif [[ "$group_by" != "$last_filter" ]]; then
            columns+=("$last_filter")
        fi
    fi

    if [[ ${#columns[@]} -gt 0 ]]; then
        declare -g table=${columns[0]}
        columns=("${columns[@]:1}")
    fi
}
