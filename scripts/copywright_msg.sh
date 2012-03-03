NAME="oab-java.sh"
VER="0.2.0"

echo "$NAME v${VER} - Create a local 'apt' repository for Ubuntu Java packages."
echo "Copyright (c) `date +%Y` Flexion.Org, http://flexion.org. MIT License"
echo
echo "Copyright (c) `date +%Y` Tamer Saadeh <tamersaadeh@gmail.com>. MIT License"
echo
echo "By running this script to download Java you acknowledge that you have"
echo "read and accepted the terms of the Oracle end user license agreement."
echo
echo "  - http://www.oracle.com/technetwork/java/javase/terms/license/"
echo
echo "If you want to see what this is script is doing while it is running then execute"
echo "the following from another shell:"
echo

# Adjust the output if we are building the docs.
if [ "$1" != "build_docs" ]; then
    echo "  tail -f `pwd`/build.log"
else
    echo "  tail -f ./build.log"
fi
echo
