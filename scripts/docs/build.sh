#!/usr/bin/env bash

if [[ "$DOCS" == "" ]]; then
    DOCS="."
fi

source "$DOCS/common.sh" "build_docs"

if [[ "$1" == "" ]]; then
    location="."
else
    location="$1"
fi

# Add fork details
header "Origins" > "$location/README.md"
echo "This is a fork of `partial_link "flexiondotorg/oab-java6" "https://github.com/flexiondotorg/oab-java6"` that creates an `partial_code "apt"` repository for both Sun Java 6 and Oracle Java 7." >> "$location/README.md"
echo >> "$location/README.md"

# Add copywright
"$DOCS/copywright.sh" "build_docs" >> "$location/README.md"

# Add the usage instructions
"$DOCS/usage.sh" "build_docs" >> "$location/README.md"

# Add the CHANGES
if [ -e "$location/CHANGES" ]; then
    cat "$location/CHANGES" >> "$location/README.md"
fi

# Add the TODO
if [ -e "$location/TODO" ]; then
    cat "$location/TODO" >> "$location/README.md"
fi

# Add the LICENSE
if [ -e "$location/LICENSE" ]; then
    cat "$location/LICENSE" >> "$location/README.md"
fi

echo "Documentation built."
exit 0
