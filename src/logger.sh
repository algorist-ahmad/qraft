#!/bin/bash

err() {
    >&2 echo "$@"
}

dbug() {
    [[ "$DEBUG" == 'on' ]] && err "$@"
}