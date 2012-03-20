#!/usr/bin/env bash

if [[ "$DOCS" == "" ]]; then
    DOCS="."
fi

source "$DOCS/common.sh" "$1"

NAME="oab-java.sh"
VER="0.2.1"

echo "\`$NAME\` v${VER} - Create a local `partial_code "apt"` repository for Ubuntu Java packages."
echo
echo "Copyright (c) `date +%Y` Tamer Saadeh, <tamersaadeh@gmail.com>. MIT License"
echo
echo "Original Copyright (c) `date +%Y` Flexion.Org, http://flexion.org. MIT License"
echo
echo "By running this script to download Java you acknowledge that you have read and accepted the terms of the Oracle end user license agreement."
echo
link "Java Terms and License" "http://www.oracle.com/technetwork/java/javase/terms/license/"
echo
echo "If you want to see what this is script is doing while it is running then execute the following from another shell:"
echo

# Adjust the output if we are building the docs.
if [ "$1" != "build_docs" ]; then
    code "tail -f \"`pwd`/build.log\""
else
    code "tail -f build.log"
fi
echo
