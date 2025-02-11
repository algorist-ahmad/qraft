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
        if [[ -n $last_filter && -z $last_symbol ]]; then
            case $pair in
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

    if [[ $STRICT_MODE == 1 && -n $last_filter && -z $last_symbol ]] && ! contains "$last_filter" 'null' '!null'; then
        err "Inavlid filter '$last_filter'"
        return 1
    fi
}
