function fork_msg() {
    echo "This is a fork of https://github.com/flexiondotorg/oab-java6"
    echo "that creates an 'apt' repository for both Sun Java 6 and Oracle Java 7."
    echo
}

function build_docs() {
    # Add fork details
    fork_msg build_docs > README

    # Add copywright
    ./scripts/copywright_msg.sh build_docs >> README

    # Add the usage instructions
    ./scripts/usage.sh build_docs >> README

    # Add the CHANGES
    if [ -e CHANGES ]; then
        cat CHANGES >> README
    fi

    # Add the TODO
    if [ -e TODO ]; then
        cat TODO >> README
    fi

    # Add the LICENSE
    if [ -e LICENSE ]; then
        cat LICENSE >> README
    fi

    echo "Documentation built."
    exit 0
}

build_docs

