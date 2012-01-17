#!/usr/bin/env bash

# License
#
# A wrapper for Janusz Dziemidowicz Debian packaging scripts for Java.
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
VER="0.1.2"

function copyright_msg() {
    local MODE=${1}
    echo `basename ${0}`" v${VER} - Install Java ${JAVA_VER}u${JAVA_UPD} from locally built packages."
    echo "Copyright (c) `date +%Y` Flexion.Org, http://flexion.org. MIT License"
	echo
	echo "By running this script to download and/or install Java you acknowledge that "
	echo "you have read and accepted the terms of the Oracle end user license agreement."
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
    echo "  sudo ${0} -k [jre|jdk]"
    echo
    echo "So to install the JRE execute the following:"
    echo
    echo "  sudo ${0} -k jre"
    echo
    echo "Required parameters"
    echo "  -k : Specify the Java kit you want to install [jre|jdk]"
    echo
    echo "Optional parameters"
    echo "  -h : This help"
    echo
    echo "How do I download and run this thing?"
    echo "====================================="
    echo "The quick and simple solution is to do the following at the shell:"
    echo
    echo "  cd ~/"
    echo "  wget https://raw.github.com/flexiondotorg/oab-java6/master/`basename ${0}` -O `basename ${0}`"
    echo "  chmod +x `basename ${0}`"
    echo "  sudo ./`basename ${0}` -k [jre|jdk]"
    echo
    echo "How it works"
    echo "============"
    echo "This script is merely a wrapper for most excllent Debian packaging "
    echo "scripts prepared by Janusz Dziemidowicz."
    echo
    echo "  - https://github.com/rraptorr/sun-java6"
    echo
    echo "The basic execution steps are:"
    echo "  - Remove, my now disabled, Java PPA 'ppa:flexiondotorg/java'."
    echo "  - Install the tools required to build the packages."
    echo "  - Create download and build caches under '/var/local/oab'."
    echo "  - Download the i586 and x64 Java ${JAVA_VER} install binaries. Yes, both are required."
    echo "  - Clone the build scripts from https://github.com/rraptorr/sun-java6"
    echo "  - Build all the Java ${JAVA_VER}u${JAVA_UPD} packages applicable to your system."
    echo "  - Install the packages that were just built."
    echo
    echo "What gets installed?"
    echo "===================="
    echo "If you elect to install the JRE the following packages are installed:"
    echo
    echo "  * sun-java${JAVA_VER}-bin"
    echo "  * sun-java${JAVA_VER}-jre"
    echo "  * sun-java${JAVA_VER}-fonts"
    echo
    echo "If you elect to install the JDK this following packages are installed,"
    echo "in addition to those from the JRE above."
    echo
    echo "  * sun-java${JAVA_VER}-jdk"
    echo "  * sun-java${JAVA_VER}-source"
    echo
    echo "The Java browser plugin is installed, **but only if a supported web browser"
    echo "is already installed**. This is a safe guard to prevent servers from "
    echo "installing a web browser and all its dependencies."
    echo
    echo "  * sun-java${JAVA_VER}-plugin"
    echo
    echo "What is not installed?"
    echo "======================"
    echo "When electing to install the JDK the Java Development Kit demos and"
    echo "examples, 'sun-java${JAVA_VER}-demo' and the Java DB distribution of Apache"
    echo "Derby 'sun-java${JAVA_VER}-javadb' are not installed by default. Should you"
    echo "require those packages, execute the following:"
    echo
    echo "  sudo dpkg -i /var/local/oab/deb/sun-java${JAVA_VER}-demo_${JAVA_VER}.${JAVA_UPD}-3~${LSB_CODE}1_${LSB_ARCH}.deb"
    echo "  sudo dpkg -i /var/local/oab/deb/sun-java${JAVA_VER}-javadb_${JAVA_VER}.${JAVA_UPD}-3~${LSB_CODE}1_all.deb"
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
OPTSTRING=bhk:
while getopts ${OPTSTRING} OPT
do
    case ${OPT} in
        b) build_docs;;
        h) usage;;
        k) INST_KIT=`echo ${OPTARG} | tr '[A-Z]' '[a-z]'`;;
        *) usage;;
    esac
done
shift "$(( $OPTIND - 1 ))"

# Check the the select kit is valid.
if [ "${INST_KIT}" != "jre" ] && [ "${INST_KIT}" != "jdk" ]; then
    echo "ERROR! You must specify which Java kit you want to install, either 'jre' or 'jdk'."
    usage
fi

# Let's start doing something...
echo "Here we go..."

# Remove my, now disabled, Java PPA.
if [ -e /etc/apt/sources.list.d/flexiondotorg-java-${LSB_CODE}.list* ]; then
    ncecho " [x] Removing ppa:flexiondotorg/java "
    rm -v /etc/apt/sources.list.d/flexiondotorg-java-${LSB_CODE}.list* >> "$log" 2>&1
    cecho success
    apt_update
fi

# Determine the build and runtime requirements.
BUILD_DEPS="build-essential debhelper defoma devscripts dpkg-dev git-core libasound2 libxi6 libxt6 libxtst6 unixodbc unzip"
RUNTIME_DEPS="defoma java-common libasound2 libx11-6 libxext6 libxi6 libxt6 libxtst6 locales unixodbc"
if [ "${LSB_ARCH}" == "amd64" ]; then
    BUILD_DEPS="${BUILD_DEPS} lib32asound2 ia32-libs"
    RUNTIME_DEPS="${RUNTIME_DEPS} ia32-libs"
fi

# Install the Java build requirements
ncecho " [x] Installing Java ${JAVA_VER} build requirements "
apt-get install -y --no-install-recommends ${BUILD_DEPS} >> "$log" 2>&1 &
pid=$!;progress $pid

# Install the Java runtime requirements
ncecho " [x] Installing Java ${JAVA_VER} runtime requirements "
apt-get install -y --no-install-recommends ${RUNTIME_DEPS} >> "$log" 2>&1 &
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

# Build the list of .debs to be installed
INST_DEB="./sun-java6-bin_${NEW_VERSION}_${LSB_ARCH}.deb ./sun-java6-jre_${NEW_VERSION}_all.deb ./sun-java6-fonts_${NEW_VERSION}_all.deb"
if [ "${LSB_ARCH}" == "amd64" ]; then
    INST_DEB="${INST_DEB} ./ia32-sun-java6-bin_${NEW_VERSION}_${LSB_ARCH}.deb"
fi

# If the JDK was requested, then add the extra packages.
if [ "${INST_KIT}" == "jdk" ]; then
    INST_DEB="${INST_DEB} ./sun-java6-jdk_${NEW_VERSION}_${LSB_ARCH}.deb ./sun-java6-source_${NEW_VERSION}_all.deb"
fi

# Install the required JRE or JDK .debs
ncecho " [x] Installing Java ${JAVA_VER}u${JAVA_UPD} : [${INST_KIT}] "
cd /var/local/oab/deb >> "$log" 2>&1
dpkg -i ${INST_DEB} >> "$log" 2>&1 &
pid=$!;progress $pid

# Install the Java plugin .deb, if a supported browser is already installed.
# Prevents installing a browser and all its dependencies on a server.
BROWSER_INSTALLED=`update-alternatives --list x-www-browser 2>/dev/null`
if [ $? -eq 0 ]; then
    ncecho " [x] Installing Java ${JAVA_VER}u${JAVA_UPD} : [plugin] "
    cd /var/local/oab/deb >> "$log" 2>&1
    dpkg -i ./sun-java6-plugin_${NEW_VERSION}_${LSB_ARCH}.deb >> "$log" 2>&1 &
    pid=$!;progress $pid
else
    cecho " [!] Install of Java ${JAVA_VER}u${JAVA_UPD} : [plugin] skipped"
fi

echo "All done!"