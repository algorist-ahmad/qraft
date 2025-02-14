source "$SRC_DIR"/utils.sh

get_symbol() {
    for symbol in '!=' '>=' '<=' '=' '<' '>' '~'; do
        [[ $1 == *"$symbol"* ]] && echo $symbol && return 0
    done
    return 1
}

parse_filters() {
    args=("$@")

    declare -ga filters=()
    declare -ga columns=()

    for ((i=0; i < ${#args[@]}; i++)); do
        current="${args[$i]}"
        next="${args[$((i + 1))]}"

        if [[ "$current" == "group" ]]; then
            if [[ "$STRICT_MODE" == 1 || -z "$next" ]]; then
                err "Invalid filter '$current'"
                return 1
            else
                declare -g group_by=$next
                ((i++))
            fi

            continue
        fi

        symbol=$(get_symbol "$current")
        key="${current%%"$symbol"*}"
        val="${current#*"$symbol"}"

        if [[ -z "$symbol" ]]; then
            [[ "$STRICT_MODE" == 1 ]] && err "Inavlid filter '$$current'" && return 1

            case "$current" in
                +*) declare -g order_by="${current:1} ASC"; continue ;;
                -*) declare -g order_by="${current:1} DESC"; continue ;;
            esac

            case "$next" in
                "null") filters+=("$current = NULL"); ((i++)) ;;
                "!null") filters+=("$current <> NULL"); ((i++)) ;;
                *) columns+=("$current") ;;
            esac

            continue
        fi

        case "$key" in
            lim|limit|shift|+*|-*)
                [[ "$STRICT_MODE" = 1 ]] && err "Invalid filter '$current'" && return 1
            ;;
        esac

        case "$key" in
            lim|limit) declare -g limit=$val; continue ;;
            shift) declare -g offset=$val; continue ;;
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
    done

    if [[ ${#columns[@]} -gt 0 ]]; then
        declare -g table=${columns[0]}
        columns=("${columns[@]:1}")
    fi
}
