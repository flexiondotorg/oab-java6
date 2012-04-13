#!/usr/bin/env bash
# Copyright (c) Martin Wimpress
# http://flexion.org/
# See the file "LICENSE" for the full license governing this code.

# References
#  - https://github.com/rraptorr/sun-java6
#  - http://ubuntuforums.org/showthread.php?t=1090731
#  - http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/gpg-cs.html

# Variables
VER="0.1.9"

function copyright_msg() {
    local MODE=${1}
    if [ "${MODE}" == "build_docs" ]; then
        echo "OAB-Java6"
        echo "========="
    fi
    echo `basename ${0}`" v${VER} - Create a local 'apt' repository for Ubuntu Java packages."
    echo "Copyright (c) Martin Wimpress, http://flexion.org. MIT License"
    echo
    echo "By running this script to download Java you acknowledge that you have"
    echo "read and accepted the terms of the Oracle end user license agreement."
    echo
    echo "* http://www.oracle.com/technetwork/java/javase/terms/license/"
    echo
    # Adjust the output if we are executing the script.
    if [ "${MODE}" != "build_docs" ]; then
        echo "If you want to see what this is script is doing while it is running then execute"
        echo "the following from another shell:"
        echo
        echo "  tail -f `pwd`/`basename ${0}`.log"
        echo
    #else
    #    echo "  tail -f ./`basename ${0}`.log"
    fi
}

function usage() {
    local MODE=${1}
    echo "Usage"
    echo "-----"
    echo "::"
    echo
    echo "  sudo ${0}"
    echo
    echo "Optional parameters"
    echo
    echo "* ``-c`` : Remove pre-existing packages from ``<working directory>/deb``"
    echo "* ``-s`` : Skip building if the packages already exist"
    echo "* ``-k <gpg secret key ID>`` : Use the specified existing key instead of generating a temporary one"
    echo "* ``-d <working directory>`` : Use the specified existing directory instead of ${WD}, e.g. ``-d .``"
    echo "* ``-h`` : This help"
    echo
    echo "How do I download and run this thing?"
    echo "-------------------------------------"
    echo "Like this."
    echo "::"
    echo
    echo "  cd ~/"
    echo "  wget https://raw.github.com/flexiondotorg/oab-java6/master/`basename ${0}` -O `basename ${0}`"
    echo "  chmod +x `basename ${0}`"
    echo "  sudo ./`basename ${0}`"
    echo
    echo "If you are behind a proxy you may need to run using:"
    echo "::"
    echo
    echo "  sudo -i ./`basename ${0}`"
    echo
    # Adjust the output if we are building the docs.
    if [ "${MODE}" == "build_docs" ]; then
        echo "If you want to see what this is script is doing while it is running then execute"
        echo "the following from another shell:"
        echo "::"
        echo
        echo "  tail -f ./`basename ${0}`.log"
    fi
    echo
    echo "How it works"
    echo "------------"
    echo "This script is merely a wrapper for the most excellent Debian packaging"
    echo "scripts prepared by Janusz Dziemidowicz."
    echo
    echo "* https://github.com/rraptorr/sun-java6"
    echo
    echo "The basic execution steps are:"
    echo
    echo "* Remove, my now disabled, Java PPA 'ppa:flexiondotorg/java'."
    echo "* Install the tools required to build the Java packages."
    echo "* Create download cache in ``<working directory>/pkg``."
    echo "* Download the i586 and x64 Java install binaries from Oracle. Yes, both are required."
    echo "* Clone the build scripts from https://github.com/rraptorr/sun-java6"
    echo "* Build the Java packages applicable to your system."
    echo "* Create local ``apt`` repository in ``<working directory>/deb`` for the newly built Java Packages."
    echo "* Create a GnuPG signing key in ``<working directory>/gpg`` if none exists."
    echo "* Sign the local ``apt`` repository using the local GnuPG signing key."
    echo
    echo "What gets installed?"
    echo "--------------------"
    echo "Nothing!"
    echo
    echo "This script will no longer try and directly install or upgrade any Java"
    echo "packages, instead a local ``apt`` repository is created that hosts locally"
    echo "built Java packages applicable to your system. It is up to you to install"
    echo "or upgrade the Java packages you require using ``apt-get``, ``aptitude`` or"
    echo "``synaptic``, etc. For example, once this script has been run you can simply"
    echo "install the JRE by executing the following from a shell."
    echo "::"
    echo
    echo "  sudo apt-get install sun-java6-jre"
    echo
    echo "Or if you already have the *\"official\"* Ubuntu packages installed then you"
    echo "can upgrade by executing the following from a shell."
    echo "::"
    echo
    echo "  sudo apt-get upgrade"
    echo
    echo "The local ``apt`` repository is just that, **local**. It is not accessible"
    echo "remotely and `basename ${0}` will never enable that capability to ensure"
    echo "compliance with Oracle's asinine license requirements."
    echo
    echo "To run as a non-privileged user, make sure that"
    echo "* The user is allowed to run ``sudo apt-get`` via /etc/sudoers"
    echo "* You specify -d <working directory>"
    echo
    echo "By default, the script creates a temporary GPG keyring in the working"
    echo "directory. In order to use the current user's GPG chain instead, specify"
    echo "the key ID of an existing secret key. Run ``gpg -K`` to list available keys."
    echo
    echo "Known Issues"
    echo "------------"
    echo
    echo "* The Oracle download servers can be horribly slow. My script caches the downloads so you only need download each file once."
    echo
    echo "What is 'oab'?"
    echo "--------------"
    echo "Because, O.A.B! ;-)"
    echo

    # Only exit if we are not build docs.
    if [ "${MODE}" != "build_docs" ]; then
        exit 1
    fi
}

function build_docs() {
    copyright_msg build_docs > README.rst

    # Add the usage instructions
    usage build_docs >> README.rst

    # Add the CHANGES
    if [ -e CHANGES ]; then
        cat CHANGES >> README.rst
    fi

    # Add the AUTHORS
    if [ -e AUTHORS ]; then
        cat AUTHORS >> README.rst
    fi

    # Add the TODO
    if [ -e TODO ]; then
        cat TODO >> README.rst
    fi

    # Add the LICENSE
    if [ -e LICENSE ]; then
        cat LICENSE >> README.rst
    fi

    echo "Documentation built."
    exit 0
}

copyright_msg

# 'source' my common functions
if [ -r /tmp/common.sh ]; then
    source /tmp/common.sh
    if [ $? -ne 0 ]; then
        echo "ERROR! Couldn't import common functions from /tmp/common.sh"
        rm /tmp/common.sh 2>/dev/null
        exit 1
    else
        update_thyself
    fi
else
    echo "Downloading common.sh"
    wget --no-check-certificate -q "https://github.com/flexiondotorg/common/raw/master/common.sh" -O /tmp/common.sh
    chmod 666 /tmp/common.sh
    source /tmp/common.sh
    if [ $? -ne 0 ]; then
        echo "ERROR! Couldn't import common functions from /tmp/common.sh"
        rm /tmp/common.sh 2>/dev/null
        exit 1
    fi
fi

# Check we are running on a supported system in the correct way.
check_ubuntu "all"

BUILD_KEY=""
BUILD_CLEAN=0
SKIP_REBUILD=0
WD="/var/local/oab"

# Parse the options
OPTSTRING=bchk:sd:
while getopts ${OPTSTRING} OPT
do
    case ${OPT} in
        b) build_docs;;
        c) BUILD_CLEAN=1;;
        h) usage;;
        k) BUILD_KEY=${OPTARG};;
        s) SKIP_REBUILD=1;;
        d)
            WD="${OPTARG}"
            if [ ! -d "${WD}" ]; then
                error_msg "'${WD}' doesn't exist or is not a directory"
            fi
            # Need to convert relative paths to absolute ones since we are using 'cd' below
            WD="$(readlink -f "${WD}")"
            ;;
        *) usage;;
    esac
done
shift "$(( $OPTIND - 1 ))"


# Remove my, now disabled, Java PPA.
if [ -e /etc/apt/sources.list.d/flexiondotorg-java-${LSB_CODE}.list ]; then
    ncecho " [x] Removing ppa:flexiondotorg/java "
    rm -v /etc/apt/sources.list.d/flexiondotorg-java-${LSB_CODE}.list* >> "$log" 2>&1
    cecho success
fi

# Determine the build and runtime requirements.
BUILD_DEPS="build-essential debhelper defoma devscripts dpkg-dev git-core \
gnupg imvirt libasound2 libxi6 libxt6 libxtst6 rng-tools unixodbc unzip"
if [ "${LSB_ARCH}" == "amd64" ]; then
    BUILD_DEPS="${BUILD_DEPS} lib32asound2 ia32-libs"
fi

# Install the Java build requirements
ncecho " [x] Installing Java build requirements "
sudo apt-get install -y --no-install-recommends ${BUILD_DEPS} >> "$log" 2>&1 &
pid=$!;progress $pid

# Make sure the required dirs exist.
ncecho " [x] Making build directories "
mkdir -p "${WD}"/{deb,gpg,pkg} >> "$log" 2>&1 &
pid=$!;progress $pid

# Set the permissions appropriately for 'gpg'
chown root:root "${WD}"/gpg 2>/dev/null
chmod 0700 "${WD}"/gpg 2>/dev/null

# Remove the 'src' directory everytime.
ncecho " [x] Removing clones of https://github.com/rraptorr/sun-java6 "
rm -rfv "${WD}"/sun-java6* 2>/dev/null >> "$log" 2>&1
rm -rfv "${WD}"/src 2>/dev/null >> "$log" 2>&1 &
pid=$!;progress $pid

# Clone the code
ncecho " [x] Cloning https://github.com/rraptorr/sun-java6 "
cd "${WD}"/ >> "$log" 2>&1
git clone https://github.com/rraptorr/sun-java6 src >> "$log" 2>&1 &
pid=$!;progress $pid

# Get the last commit tag.
cd "${WD}"/src >> "$log" 2>&1
TAG=`git tag -l | tail -n1`

# Checkout the tagged, stable, version.
ncecho " [x] Checking out ${TAG} "
git checkout ${TAG} >> "$log" 2>&1 &
pid=$!;progress $pid

# Cet the current Debian package version and package urgency
DEB_VERSION=`head -n1 "${WD}"/src/debian/changelog | cut -d'(' -f2 | cut -d')' -f1 | cut -d'~' -f1`
DEB_URGENCY=`head -n1 "${WD}"/src/debian/changelog | cut -d'=' -f2`

# Determine the currently supported Java version and update
JAVA_VER=`echo ${DEB_VERSION} | cut -d'.' -f1`
JAVA_UPD=`echo ${DEB_VERSION} | cut -d'.' -f2 | cut -d'-' -f1`

# Try and dynamic find the JDK downloads
ncecho " [x] Getting Java SE download page"
wget "http://www.oracle.com/technetwork/java/javase/downloads/index.html" -O /tmp/oab-index.html >> "$log" 2>&1 &
pid=$!;progress $pid

# See if the Java version is on the download frontpage, otherwise look for it in
# the previous releases page.
DOWNLOAD_INDEX=`grep "/technetwork/java/javase/downloads/jdk-${JAVA_VER}u${JAVA_UPD}" /tmp/oab-index.html | grep "alt=\"Download JDK\"" | cut -d'<' -f3 | cut -d'"' -f2`
if [ -n "${DOWNLOAD_INDEX}" ]; then
    ncecho " [x] Getting current release download page "
    wget http://www.oracle.com/${DOWNLOAD_INDEX} -O /tmp/oab-download.html >> "$log" 2>&1 &
    pid=$!;progress $pid
else
    ncecho " [x] Getting previous releases download page "
    wget http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase6-419409.html -O /tmp/oab-download.html >> "$log" 2>&1 &
    pid=$!;progress $pid
fi

# Download the Oracle install packages.
for JAVA_BIN in jdk-${JAVA_VER}u${JAVA_UPD}-linux-i586.bin jdk-${JAVA_VER}u${JAVA_UPD}-linux-x64.bin
do
    # Get the download URL and size
    DOWNLOAD_URL=`grep ${JAVA_BIN} /tmp/oab-download.html | cut -d'{' -f2 | cut -d',' -f3 | cut -d'"' -f4`
    DOWNLOAD_SIZE=`grep ${JAVA_BIN} /tmp/oab-download.html | cut -d'{' -f2 | cut -d',' -f2 | cut -d':' -f2 | sed 's/"//g'`
    # Cookies required for download
    COOKIES="oraclelicensejdk-${JAVA_VER}u${JAVA_UPD}-oth-JPR=accept-securebackup-cookie;gpw_e24=http://edelivery.oracle.com"

    ncecho " [x] Downloading ${JAVA_BIN} : ${DOWNLOAD_SIZE} "
    wget --header="Cookie: ${COOKIES}" -c "${DOWNLOAD_URL}" -O "${WD}"/pkg/${JAVA_BIN} >> "$log" 2>&1 &
    pid=$!;progress_loop $pid

    ncecho " [x] Symlinking ${JAVA_BIN} "
    ln -s "${WD}"/pkg/${JAVA_BIN} "${WD}"/src/${JAVA_BIN} >> "$log" 2>&1 &
    pid=$!;progress_loop $pid
done

# Determine the new version
NEW_VERSION="${DEB_VERSION}~${LSB_CODE}1"

if [ "${SKIP_REBUILD}" -eq 1 -a -r "${WD}/deb/sun-java${JAVA_VER}_${NEW_VERSION}_${LSB_ARCH}.changes" ]; then
  echo " [!] Package exists, skipping build "
  echo "All done!"
  exit
fi

# Genereate a build message
BUILD_MESSAGE="Automated build for ${LSB_REL} using https://github.com/rraptorr/sun-java6"

# Change directory to the build directory
cd "${WD}"/src

# Update the changelog
ncecho " [x] Updating the changelog "
dch --distribution ${LSB_CODE} --force-distribution --newversion ${NEW_VERSION} --force-bad-version --urgency=${DEB_URGENCY} "${BUILD_MESSAGE}" >> "$log" 2>&1 &
pid=$!;progress $pid

# Build the binary packages
ncecho " [x] Building the packages "
dpkg-buildpackage -uc -b >> "$log" 2>&1 &
pid=$!;progress_can_fail $pid

if [ -e "${WD}"/sun-java${JAVA_VER}_${NEW_VERSION}_${LSB_ARCH}.changes ]; then
    # Remove any existing .deb files if the 'clean' option was selected.
    if [ ${BUILD_CLEAN} -eq 1 ]; then
        ncecho " [x] Removing existing .deb packages "
        rm -fv "${WD}"/deb/* >> "$log" 2>&1 &
        pid=$!;progress $pid
    fi

    # Populate the 'apt' repository with .debs
    ncecho " [x] Moving the packages "
    mv -v "${WD}"/sun-java${JAVA_VER}_${NEW_VERSION}_${LSB_ARCH}.changes "${WD}"/deb/ >> "$log" 2>&1
    mv -v "${WD}"/*sun-java${JAVA_VER}-*_${NEW_VERSION}_*.deb "${WD}"/deb/ >> "$log" 2>&1 &
    pid=$!;progress $pid
else
    error_msg "ERROR! Packages failed to build."
fi

# Create a temporary 'override' file, which may contain duplicates
echo "#Override" > /tmp/override
echo "#Package priority section" >> /tmp/override
for FILE in "${WD}"/deb/*.deb
do
    DEB_PACKAGE=`dpkg --info ${FILE} | grep Package | cut -d':' -f2`
    DEB_SECTION=`dpkg --info ${FILE} | grep Section | cut -d'/' -f2`
    echo "${DEB_PACKAGE} high ${DEB_SECTION}" >> /tmp/override
done

# Remove the duplicates from the overide file
uniq /tmp/override > "${WD}"/deb/override

# Create the 'apt' Packages.gz
ncecho " [x] Creating Packages.gz file "
cd "${WD}"/deb
dpkg-scanpackages . override 2>/dev/null > Packages
cat Packages | gzip -c9 > Packages.gz
rm "${WD}"/deb/override 2>/dev/null
cecho success

# Create a 'Release' file
ncecho " [x] Creating Release file "
cd "${WD}"/deb
echo "Origin: `hostname --fqdn`"                 >  Release
echo "Label: Java"                                >> Release
echo "Suite: ${LSB_CODE}"                       >> Release
echo "Version: ${LSB_REL}"                      >> Release
echo "Codename: ${LSB_CODE}"                    >> Release
echo "Date: `date -R`"                           >> Release
echo "Architectures: ${LSB_ARCH}"               >> Release
echo "Components: restricted"                     >> Release
echo "Description: Local Java Repository"         >> Release
echo "MD5Sum:"                                    >> Release
for PACKAGE in Packages*
do
    printf ' '`md5sum ${PACKAGE} | cut -d' ' -f1`" %16d ${PACKAGE}\n" `wc --bytes ${PACKAGE} | cut -d' ' -f1` >> Release
done
cecho success

# Skip anything todo with automated key creation if this script is running in
# an OpenVZ container.
if [[ `imvirt` != "OpenVZ" ]]; then
    # Do we need to create signing keys
    if [ -z "${BUILD_KEY}" ] && [ ! -e "${WD}"/gpg/pubring.gpg ] && [ ! -e "${WD}"/gpg/secring.gpg ] && [ ! -e "${WD}"/gpg/trustdb.gpg ]; then

        ncecho " [x] Create GnuPG configuration "
        echo "Key-Type: DSA" > "${WD}"/gpg-key.conf
        echo "Key-Length: 1024" >> "${WD}"/gpg-key.conf
        echo "Subkey-Type: ELG-E" >> "${WD}"/gpg-key.conf
        echo "Subkey-Length: 2048" >> "${WD}"/gpg-key.conf
        echo "Name-Real: `hostname --fqdn`" >> "${WD}"/gpg-key.conf
        echo "Name-Email: root@`hostname --fqdn`" >> "${WD}"/gpg-key.conf
        echo "Expire-Date: 0" >> "${WD}"/gpg-key.conf
        cecho success

        # Stop the system 'rngd'.
        /etc/init.d/rng-tools stop >> "$log" 2>&1

        ncecho " [x] Start generating entropy "
        rngd -r /dev/urandom -p /tmp/rngd.pid >> "$log" 2>&1 &
        pid=$!;progress $pid

        ncecho " [x] Creating signing key "
        gpg --homedir "${WD}"/gpg --batch --gen-key "${WD}"/gpg-key.conf >> "$log" 2>&1 &
        pid=$!;progress $pid

        ncecho " [x] Stop generating entropy "
        kill -9 `cat /tmp/rngd.pid` >> "$log" 2>&1 &
        pid=$!;progress $pid
        rm /tmp/rngd.pid 2>/dev/null

        # Start the system 'rngd'.
        /etc/init.d/rng-tools start >> "$log" 2>&1
    fi
fi

# Do we have signing keys or a user specified key, if so use them.
if [ -n "${BUILD_KEY}" ] || [ -e "${WD}"/gpg/pubring.gpg ] && [ -e "${WD}"/gpg/secring.gpg ] && [ -e "${WD}"/gpg/trustdb.gpg ]; then
    # Sign the Release
    ncecho " [x] Signing the 'Release' file "
    rm "${WD}"/deb/Release.gpg 2>/dev/null
    if [ -n "${BUILD_KEY}" ] ; then
        keyOption=(--default-key "${BUILD_KEY}")
    else
        keyOption=(--homedir "${WD}"/gpg)
    fi
    gpg "${keyOption[@]}" --armor --detach-sign --output "${WD}"/deb/Release.gpg "${WD}"/deb/Release >> "$log" 2>&1 &
    pid=$!;progress $pid

    if [ -z "${BUILD_KEY}" ] ; then
        # Export public signing key
        ncecho " [x] Exporting public key "
        gpg --homedir "${WD}"/gpg --export -a "`hostname --fqdn`" > "${WD}"/deb/pubkey.asc
        cecho success

        # Add the public signing key
        ncecho " [x] Adding public key "
        apt-key add "${WD}"/deb/pubkey.asc >> "$log" 2>&1 &
        pid=$!;progress $pid
    fi
fi

# Update apt cache if we're root
if [ "$(id -u)" == "0" ]; then
    echo "# Sun Java6 - https://github.com/flexiondotorg/oab-java6" > /etc/apt/sources.list.d/oab.list
    echo "deb file://${WD}/deb /"                                  >> /etc/apt/sources.list.d/oab.list
    apt_update
else
    echo -e "\nConsider adding the following line to /etc/apt/sources.list.d/oab.list, then run apt_update:\n"
    echo -e "  deb file://${WD}/deb /\n"
fi

echo "All done!"