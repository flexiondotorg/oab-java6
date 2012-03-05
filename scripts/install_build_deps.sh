source /tmp/common.sh
# Determine the build and runtime requirements.
BUILD_DEPS="build-essential debhelper defoma devscripts dpkg-dev git-core \
gnupg imvirt libasound2 libxi6 libxt6 libxtst6 rng-tools unixodbc unzip"
if [ "${LSB_ARCH}" == "amd64" ]; then
    BUILD_DEPS="${BUILD_DEPS} lib32asound2 ia32-libs"
fi

LSB_CODE=`lsb_release -c | cut -f2 | sed 's/ //g'`

if [ "${LSB_CODE}" == "precise" ]; then
    BUILD_DEPS="${BUILD_DEPS}  libxtst6:i386"
fi

# Install the Java build requirements
ncecho " [x] Installing Java build requirements "
apt-get install -y --no-install-recommends ${BUILD_DEPS} >> "$LOG" 2>&1 &
pid=$!;progress $pid
