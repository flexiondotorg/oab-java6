# Determine the new version
NEW_VERSION="$1"

# Genereate a build message
BUILD_MESSAGE="Automated build for ${LSB_REL} using https://github.com/rraptorr/$3"

# Change directory to the build directory
cd $BASE/src/$3

# Update the changelog
ncecho " [x] Updating the changelog "
dch --distribution ${LSB_CODE} --force-distribution --newversion ${NEW_VERSION} --force-bad-version --urgency=$2 "${BUILD_MESSAGE}" >> "$4" 2>&1 &
pid=$!;progress $pid

# Build the binary packages
ncecho " [x] Building the packages "
dpkg-buildpackage -b >> "$4" 2>&1 &
pid=$!;progress_can_fail $pid

if [ -e $BASE/$3_${NEW_VERSION}_${LSB_ARCH}.changes ]; then
    # Remove any existing .deb files if the 'clean' option was selected.
    if [ $5 -eq 1 ]; then
        ncecho " [x] Removing existing .deb packages "
        rm -fv $BASE/deb/* >> "$4" 2>&1 &
        pid=$!;progress $pid
    fi

    # Populate the 'apt' repository with .debs
    ncecho " [x] Moving the packages "
    mv -v $BASE/$3_${NEW_VERSION}_${LSB_ARCH}.changes $BASE/deb/ >> "$4" 2>&1
    mv -v $BASE/*$3-*_${NEW_VERSION}_*.deb $BASE/deb/ >> "$4" 2>&1 &
    pid=$!;progress $pid
else    
    error_msg "ERROR! Packages failed to build. Please raise an issue with the upstream script developer - https://github.com/rraptorr/$3/issues"
fi
