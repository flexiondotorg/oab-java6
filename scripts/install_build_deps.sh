source "$SCRIPTS/common.sh"
lsb

# Determine the build and runtime requirements.
BUILD_DEPS="build-essential debhelper defoma devscripts dpkg-dev git-core \
gnupg imvirt libasound2 libxi6 libxt6 libxtst6 rng-tools unixodbc unzip"
if [ "${LSB_ARCH}" == "amd64" ]; then
    BUILD_DEPS="${BUILD_DEPS} lib32asound2 ia32-libs"
fi

# Workaround until both of these are fixed:
# - https://github.com/rraptorr/sun-java6/issues/5
# - https://bugs.launchpad.net/ubuntu/+source/ia32-libs/+bug/947495
if [ "${LSB_CODE}" == "precise" ]; then
    BUILD_DEPS="${BUILD_DEPS}  libxtst6:i386"
fi

# Install the Java build requirements
ncecho " [x] Installing Java build requirements "
apt-get install -y --no-install-recommends ${BUILD_DEPS} >> "$LOG" 2>&1 &
pid=$!;progress $pid
