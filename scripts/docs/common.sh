#!/usr/bin/env bash

MODE="$1"

function partial() {
    echo -n "$1"
}

function code() {
    if [ "$MODE" == "build_docs" ]; then
        echo "\`\`\`$1\`\`\`"
    else
        echo "  $1"
    fi
}

function partial_code() {
    if [ "$MODE" == "build_docs" ]; then
        partial "\`$1\`"
    else
        partial "'$1'"
    fi
}

function link() {
    if [ "$MODE" == "build_docs" ]; then
        echo "[$1]($2)"
    else
        echo " - $2"
    fi
}

function partial_link() {
    if [ "$MODE" == "build_docs" ]; then
        partial "[$1]($2)"
    else
        partial " - $2"
    fi
}

function header() {
    echo "$1"
    echo "==="
}

function subheader() {
    if [ "$MODE" == "build_docs" ]; then
        echo "$1"
        echo "---"
    else
        echo "$1"
    fi
}

function point() {
    echo "  * $1"
}

function partial_point() {
    partial "  * $1"
}

function em() {
    if [ "$MODE" == "build_docs" ]; then
        echo "**$1**"
    else
        echo "$1"
    fi
}

function partial_em() {
    if [ "$MODE" == "build_docs" ]; then
        echo -n "**$1**"
    else
        echo -n "$1"
    fi
}

function i() {
    if [ "$MODE" == "build_docs" ]; then
        echo "*$1*"
    else
        echo "$1"
    fi
}

function partial_i() {
    if [ "$MODE" == "build_docs" ]; then
        echo -n "*$1*"
    else
        echo -n "$1"
    fi
}
