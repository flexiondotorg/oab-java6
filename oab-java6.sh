#!/usr/bin/env bash

# License
#
# Create a local 'apt' repository for Ubuntu Java packages.
# Copyright (c) 2012 Flexion.Org, http://flexion.org/
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# References
#  - https://github.com/rraptorr/sun-java6

# Variables
JAVA_KIT="jdk"
JAVA_VER="6"
JAVA_UPD="30"
JAVA_REL="b12"
VER="0.1.3"

function copyright_msg() {
    local MODE=${1}
    echo `basename ${0}`" v${VER} - Create a local 'apt' repository for Ubuntu Java packages."
    echo "Copyright (c) `date +%Y` Flexion.Org, http://flexion.org. MIT License"
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
    if [ "${MODE}" != "build_docs" ]; then
        echo "  tail -f `pwd`/`basename ${0}`.log"
    else
	    echo "  tail -f ./`basename ${0}`.log"
    fi
    echo
}

function usage() {
    local MODE=${1}
    echo "Usage"
    echo
    echo "  sudo ${0}"
    echo
    echo "Optional parameters"
    echo "  -h : This help"
    echo
    echo "How do I download and run this thing?"
    echo "====================================="
    echo "Like this."
    echo
    echo "  cd ~/"
    echo "  wget https://raw.github.com/flexiondotorg/oab-java6/master/`basename ${0}` -O `basename ${0}`"
    echo "  chmod +x `basename ${0}`"
    echo "  sudo ./`basename ${0}`"
    echo
    echo "How it works"
    echo "============"
    echo "This script is merely a wrapper for the most excllent Debian packaging"
    echo "scripts prepared by Janusz Dziemidowicz."
    echo
    echo "  - https://github.com/rraptorr/sun-java6"
    echo
    echo "The basic execution steps are:"
    echo
    echo "  - Remove, my now disabled, Java PPA 'ppa:flexiondotorg/java'."
    echo "  - Install the tools required to build the Java packages."
    echo "  - Create download cache in '/var/local/oab/pkg'."
    echo "  - Download the i586 and x64 Java ${JAVA_VER} install binaries from Oracle. Yes, both are required."
    echo "  - Clone the build scripts from https://github.com/rraptorr/sun-java6"
    echo "  - Build the Java ${JAVA_VER}u${JAVA_UPD} packages applicable to your system."
    echo "  - Create local 'apt' repository in '/var/local/oab/deb' for the newly built Java Packages"
    echo
    echo "What gets installed?"
    echo "===================="
    echo "Nothing!"
    echo
    echo "This script will no longer try and directly install or upgrade any Java"
    echo "packages, instead a local 'apt' repository is created that hosts locally"
    echo "built Java packages applicable to your system. It is up to you to install"
    echo "or upgrade the Java packages you require using 'apt-get', 'aptitude' or"
    echo "'synaptic', etc. For example, once this script has been run you can simply"
    echo "install the JRE by executing the following from a shell."
    echo
    echo "  sudo apt-get install sun-java6-jre"
    echo
    echo "Or if you already have the \"official\" Ubuntu packages installed then you"
    echo "can upgrade by executing the folowing from a shell."
    echo
    echo "  sudo apt-get upgrade"
    echo
    echo "The local 'apt' repository is just that, **local**. It is not accessible"
    echo "remotely and `basename ${0}` will never enable that capability to ensure"
    echo "compliance with Oracle's asinine license requirements."
    echo
    echo "What is 'oab'?"
    echo "=============="
    echo "Because, O.A.B! ;-)"
    echo

    # Only exit if we are not build docs.
    if [ "${MODE}" != "build_docs" ]; then
        exit 1
    fi
}

function build_docs() {
    copyright_msg build_docs > README

    # Add the usage instructions
    usage build_docs >> README

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

copyright_msg

# 'source' my common functions
if [ -f /tmp/common.sh ]; then
    source /tmp/common.sh
    if [ $? -ne 0 ]; then
        echo "ERROR! Couldn't import common functions from common.sh"
        exit 1
    fi
else
    echo "Downloading common.sh"
    wget -q "http://bazaar.launchpad.net/~flexiondotorg/%2Bjunk/Common/download/head%3A/common.sh-20100825102958-j1cd344bsn112jxu-1/common.sh" -O /tmp/common.sh
    source /tmp/common.sh
    if [ $? -ne 0 ]; then
        echo "ERROR! Couldn't import common functions from common.sh"
        exit 1
    fi
fi

# Check we are running on a supported system in the correct way.
check_root
check_sudo
check_ubuntu "lucid maverick natty oneiric precise"
lsb

# Parse the options
OPTSTRING=bh
while getopts ${OPTSTRING} OPT
do
    case ${OPT} in
        b) build_docs;;
        h) usage;;
        *) usage;;
    esac
done
shift "$(( $OPTIND - 1 ))"

# Let's start doing something...
echo "Here we go..."

# Remove my, now disabled, Java PPA.
if [ -e /etc/apt/sources.list.d/flexiondotorg-java-${LSB_CODE}.list* ]; then
    ncecho " [x] Removing ppa:flexiondotorg/java "
    rm -v /etc/apt/sources.list.d/flexiondotorg-java-${LSB_CODE}.list* >> "$log" 2>&1
    cecho success
fi

# Determine the build and runtime requirements.
BUILD_DEPS="build-essential debhelper defoma devscripts dpkg-dev git-core libasound2 libxi6 libxt6 libxtst6 unixodbc unzip"
if [ "${LSB_ARCH}" == "amd64" ]; then
    BUILD_DEPS="${BUILD_DEPS} lib32asound2 ia32-libs"
fi

# Install the Java build requirements
ncecho " [x] Installing Java ${JAVA_VER} build requirements "
apt-get install -y --no-install-recommends ${BUILD_DEPS} >> "$log" 2>&1 &
pid=$!;progress $pid

# Make sure the required dirs exist.
ncecho " [x] Making build directories "
mkdir -p /var/local/oab/{deb,pkg} >> "$log" 2>&1 &
pid=$!;progress $pid

# Remove the 'src' directory everytime.
ncecho " [x] Removing clones of https://github.com/rraptorr/sun-java6 "
rm -rfv /var/local/oab/sun-java6*-${JAVA_VER}.${JAVA_UPD} 2>/dev/null >> "$log" 2>&1 &
pid=$!;progress $pid

# Checkout the code
ncecho " [x] Cloning https://github.com/rraptorr/sun-java6 "
cd /var/local/oab/ >> "$log" 2>&1
git clone git://github.com/rraptorr/sun-java6.git sun-java6-${JAVA_VER}.${JAVA_UPD} >> "$log" 2>&1 &
pid=$!;progress $pid

# Download the Oracle install packages.
for JAVA_PLAT in i586 x64
do
    JAVA_BIN="${JAVA_KIT}-${JAVA_VER}u${JAVA_UPD}-linux-${JAVA_PLAT}.bin"
    ncecho " [x] Downloading ${JAVA_BIN} : ~80MB "
    wget -c http://download.oracle.com/otn-pub/java/jdk/${JAVA_VER}u${JAVA_UPD}-${JAVA_REL}/${JAVA_BIN} -O /var/local/oab/pkg/${JAVA_BIN} >> "$log" 2>&1 &
    pid=$!;progress_loop $pid

    ncecho " [x] Symlinking ${JAVA_BIN} "
    ln -s /var/local/oab/pkg/${JAVA_BIN} /var/local/oab/sun-java6-${JAVA_VER}.${JAVA_UPD}/${JAVA_BIN} >> "$log" 2>&1 &
    pid=$!;progress_loop $pid
done

# Change directory to the build directory
cd /var/local/oab/sun-java6-${JAVA_VER}.${JAVA_UPD}/

# Get the version
VERSION=`head -n1 debian/changelog | cut -d'(' -f2 | cut -d')' -f1 | cut -d'~' -f1`
NEW_VERSION="${VERSION}~${LSB_CODE}1"

# Genereate a build message
BUILD_MESSAGE="Automated build for Ubuntu ${LSB_REL} using https://github.com/rraptorr/sun-java6"

# Update the changelog
ncecho " [x] Updating the changelog "
dch --distribution ${LSB_CODE} --force-distribution --newversion ${NEW_VERSION} --force-bad-version "${BUILD_MESSAGE}" >> "$log" 2>&1 &
pid=$!;progress $pid

# Build the binary packages
ncecho " [x] Building the packages "
dpkg-buildpackage -b >> "$log" 2>&1 &
pid=$!;progress_can_fail $pid

# Move the .deb files into the 'deb' directory
ncecho " [x] Moving the packages "
mv -v /var/local/oab/*sun-java6-*_${NEW_VERSION}_*.deb /var/local/oab/deb/ >> "$log" 2>&1
mv -v /var/local/oab/sun-java6_${NEW_VERSION}_${LSB_ARCH}.changes /var/local/oab/deb/ >> "$log" 2>&1 &
pid=$!;progress $pid

# Create the local 'override' file
echo "#Override" > /var/local/oab/deb/override
echo "#Package priority section" >> /var/local/oab/deb/override
for FILE in /var/local/oab/deb/*.deb
do
    DEB_PACKAGE=`dpkg --info ${FILE} | grep Package | cut -d':' -f2`
    DEB_SECTION=`dpkg --info ${FILE} | grep Section | cut -d'/' -f2`
    echo "${DEB_PACKAGE} high ${DEB_SECTION}" >> /var/local/oab/deb/override
done

# Create the local apt repository
ncecho " [x] Creating local 'apt' repository "
cd /var/local/oab/deb
dpkg-scanpackages . override 2>/dev/null > Packages
cat Packages | gzip -c9 > Packages.gz
cecho success

# Update apt cache
echo "deb file:///var/local/oab/deb /" > /etc/apt/sources.list.d/oab.list
apt_update

echo "All done!"