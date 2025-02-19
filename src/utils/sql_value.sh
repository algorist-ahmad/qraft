source "$SRC_DIR"/utils.sh

sql_value() {
    if is_number "$1"; then
        echo "$1"
    else
        val=${1//\'/\'\'}
        val=${val//\"/\\\"}
        echo "'$val'"
    fi
}
