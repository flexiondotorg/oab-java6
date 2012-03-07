source "$SCRIPTS/common.sh"

# Get the current Debian package version and package urgency
export DEB_VERSION=`head -n1 "$BASE/src/$JAVA7/debian/changelog" | cut -d'(' -f2 | cut -d')' -f1 | cut -d'~' -f1`
export DEB_URGENCY=`head -n1 "$BASE/src/$JAVA7/debian/changelog" | cut -d'=' -f2`

# Determine the currently supported Java version and update
export JAVA_VER=`echo ${DEB_VERSION} | cut -d'.' -f1`
export JAVA_UPD=`echo ${DEB_VERSION} | cut -d'.' -f2 | cut -d'-' -f1`

# Try and dynamic find the JDK downloads
ncecho " [x] $JAVA7: Getting Java SE download page "
wget "http://www.oracle.com/technetwork/java/javase/downloads/index.html" -O /tmp/oab-index.html >> "$LOG" 2>&1 &
pid=$!;progress $pid

# See if the Java version is on the download frontpage, otherwise look for it in
# the previous releases page.
DOWNLOAD_INDEX=`grep "/technetwork/java/javase/downloads/jdk-${JAVA_VER}u${JAVA_UPD}" "/tmp/oab-index.html" | cut -d\" -f4`
if [ -n "${DOWNLOAD_INDEX}" ]; then
    ncecho " [x] $JAVA7: Getting current release download page "
    wget "http://www.oracle.com/${DOWNLOAD_INDEX}" -O "/tmp/oab-download-$JAVA7.html" >> "$LOG" 2>&1 &
    pid=$!;progress $pid
else
    ncecho " [x] $JAVA7: Failed to get current release page, getting previous releases download page "
    wget "http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase7-521261.html" -O "/tmp/oab-download-$JAVA7.html" >> "$LOG" 2>&1 &
    pid=$!;progress $pid
fi

# Download the Oracle install packages.
for JAVA_BIN in "jdk-${JAVA_VER}u${JAVA_UPD}-linux-i586.tar.gz" "jdk-${JAVA_VER}u${JAVA_UPD}-linux-x64.tar.gz"
do
    # Get the download URL and size
    DOWNLOAD_URL=`grep "${JAVA_BIN}" "/tmp/oab-download-$JAVA7.html" | cut -d'{' -f2 | cut -d',' -f3 | cut -d'"' -f4`
    DOWNLOAD_SIZE=`grep "${JAVA_BIN}" "/tmp/oab-download-$JAVA7.html" | cut -d'{' -f2 | cut -d',' -f2 | cut -d':' -f2 | sed 's/"//g'`

    ncecho " [x] $JAVA7: Downloading ${JAVA_BIN} : ${DOWNLOAD_SIZE} "
    wget -c "${DOWNLOAD_URL}" -O "$BASE/pkg/${JAVA_BIN}" >> "$LOG" 2>&1 &
    pid=$!;progress_loop $pid

    ncecho " [x] $JAVA7: Symlinking ${JAVA_BIN} "
    ln -s "$BASE/pkg/${JAVA_BIN}" "$BASE/src/$JAVA7/${JAVA_BIN}" >> "$LOG" 2>&1 &
    pid=$!;progress_loop $pid    
done

"$SCRIPTS/build_packages.sh" "$JAVA7"
