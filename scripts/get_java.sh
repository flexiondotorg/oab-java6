# Cet the current Debian package version and package urgency
DEB_VERSION=`head -n1 $1/src/$3/debian/changelog | cut -d'(' -f2 | cut -d')' -f1 | cut -d'~' -f1`
DEB_URGENCY=`head -n1 $1/src/$3/debian/changelog | cut -d'=' -f2`

# Determine the currently supported Java version and update
JAVA_VER=`echo ${DEB_VERSION} | cut -d'.' -f1`
JAVA_UPD=`echo ${DEB_VERSION} | cut -d'.' -f2 | cut -d'-' -f1`

# Try and dynamic find the JDK downloads
ncecho " [x] Getting Java SE download page"
wget "http://www.oracle.com/technetwork/java/javase/downloads/index.html" -O /tmp/oab-index.html >> "$2" 2>&1 &
pid=$!;progress $pid

# See if the Java version is on the download frontpage, otherwise look for it in
# the previous releases page.
DOWNLOAD_INDEX=`grep "/technetwork/java/javase/downloads/jdk-${JAVA_VER}u${JAVA_UPD}" /tmp/oab-index.html | grep "alt=\"Download JDK\"" | cut -d'<' -f3 | cut -d'"' -f2`
if [ -n "${DOWNLOAD_INDEX}" ]; then
    ncecho " [x] Getting current release download page "
    wget http://www.oracle.com/${DOWNLOAD_INDEX} -O /tmp/oab-download.html >> "$2" 2>&1 &
    pid=$!;progress $pid
else
    ncecho " [x] Failed to get current release page, getting previous releases download page "
    if [ "$3" == "sun-java6" ]; then
        wget http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase6-419409.html -O /tmp/oab-download.html >> "$2" 2>&1 &
        pid=$!;progress $pid
    else
        wget http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase7-521261.html -O /tmp/oab-download.html >> "$2" 2>&1 &
        pid=$!;progress $pid
    fi
fi

# Download the Oracle install packages.
for JAVA_BIN in jdk-${JAVA_VER}u${JAVA_UPD}-linux-i586.bin jdk-${JAVA_VER}u${JAVA_UPD}-linux-x64.bin
do
    # Get the download URL and size
    DOWNLOAD_URL=`grep ${JAVA_BIN} /tmp/oab-download.html | cut -d'{' -f2 | cut -d',' -f3 | cut -d'"' -f4`
    DOWNLOAD_SIZE=`grep ${JAVA_BIN} /tmp/oab-download.html | cut -d'{' -f2 | cut -d',' -f2 | cut -d':' -f2 | sed 's/"//g'`    
    
    ncecho " [x] Downloading ${JAVA_BIN} : ${DOWNLOAD_SIZE} "
    wget -c "${DOWNLOAD_URL}" -O $1/pkg/${JAVA_BIN} >> "$2" 2>&1 &
    pid=$!;progress_loop $pid

    ncecho " [x] Symlinking ${JAVA_BIN} "
    ln -s $1/pkg/${JAVA_BIN} $1/src/$3/${JAVA_BIN} >> "$2" 2>&1 &
    pid=$!;progress_loop $pid    
done

# remove download index and download release page
rm -rf /tmp/oab-index.html
rm -rf /tmp/oab-download.html 

sh build_packages "${DEB_VERSION}~${LSB_CODE}1" "${DEB_URGENCY}" "$3" "$2" "$4"
