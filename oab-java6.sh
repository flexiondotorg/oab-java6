#!/usr/bin/env bash

# License
#
# A wrapper for Janusz Dziemidowicz 'sun-java6' Debian packaging scripts that
# installs Java 6 by building packages locally.
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
VER="0.1.0"

function copyright_msg() {
    echo `basename ${0}`" v${VER} - Install Java 1.${JAVA_VER}.0.${JAVA_UPD} from locally built packages."
    echo "Copyright (c) `date +%Y` Flexion.Org, http://flexion.org. MIT License"
	echo
	echo "By running this script to download and install Java you acknowledge that "
	echo "you have read and accepted the terms of the end user license agreement."
	echo
	echo "  - http://www.oracle.com/technetwork/java/javase/terms/license/"
	echo
	echo "If you want to see what this script while it is running then execute the"
	echo "following from another shell:"
	echo
	echo "  tail -f ${0}.log"
    echo
}

# Usage instructions.
function usage() {
    local MODE=${1}
    echo "Usage"
    echo
    echo "  sudo ${0} -k [jre|jdk]"
    echo
    echo "Required parameters"
    echo "  -k : Specify the Java kit you want to install [jre|jdk]"
    echo
    echo "Optional parameters"
    echo "  -h : This help"
    echo
    echo "How it works"
    echo "============"
    echo "This scripts is merely a wrapper for most excllent Debian packaging "
    echo "scripts prepared by Janusz Dziemidowicz for Sun Java 6."
    echo
    echo "  - https://github.com/rraptorr/sun-java6"
    echo
    echo "The basic execution steps are:"
    echo "  - Remove, my now disabled, Java PPA 'ppa:flexiondotorg/java'."
    echo "  - Install the tools required to build the packages."
    echo "  - Create download and build caches under '/var/local/oab'."
    echo "  - Download the i586 and x64 Java 6 install binaries. Yes, both are required."
    echo "  - Clone the build scripts from https://github.com/rraptorr/sun-java6"
    echo "  - Build all the Sun Java 6 packages applicable to your system."
    echo "  - Install the packages that were just built."
    echo
    echo "What gets installed?"
    echo "===================="
    echo "If you elect to install the JRE the following packages are installed:"
    echo
    echo "  * sun-java6-bin    - Sun Java(TM) Runtime Environment (JRE) 6"
    echo "  * sun-java6-jre    - Sun Java(TM) Runtime Environment (JRE) 6"
    echo "  * sun-java6-plugin - Java(TM) Plug-in, Java SE 6"
    echo "  * sun-java6-fonts  - Lucida TrueType fonts (from the Sun JRE)"
    echo
    echo "If you elect to install the JDK this following packages are installed,"
    echo "in addition to those from the JRE above."
    echo
    echo "  * sun-java6-jdk    - Sun Java(TM) Development Kit (JDK) 6"
    echo "  * sun-java6-source - Sun Java(TM) Development Kit (JDK) 6 source files"
    echo
    echo "What is not installed?"
    echo "======================"
    echo "When electing to install the JDK the Java Development Kit demos and"
    echo "examples, 'sun-java6-demo' and the Java DB distribution of Apache"
    echo "Derby 'sun-java6-javadb' are not installed by default. Should you"
    echo "require those packages, execute the following:"
    echo
    echo "  sudo dpkg -i /var/local/oab/deb/sun-java6-demo_6.30-2~${LSB_CODE}1_${LSB_ARCH}.deb"
    echo "  sudo dpkg -i /var/local/oab/deb/sun-java6-javadb_6.30-2~${LSB_CODE}1_all.deb"
    echo
    if [ "${LSB_ARCH}" == "amd64" ] || [ "${MODE}" == "build_docs" ]; then
        echo "On 64-bit systems the Java Runtime Environment for 32-bit systems, 'ia32-sun-java6-bin',"
        echo "is not installed by default. If you require that package execute the following:"
        echo
        echo "  sudo dpkg -i /var/local/oab/deb/ia32-sun-java6-bin_6.30-2~${LSB_CODE}1_amd64.deb"
        echo
    fi

    # Only exit if we are not build docs.
    if [ "${MODE}" != "build_docs" ]; then
        exit 1
    fi
}

function build_docs() {
    copyright_msg > README

    # Add the usage instructions
    usage build_docs >> README

    # Add the CHANGES
    if [ -e CHANGES ]; then
        cat CHANGES >> README
    fi

    # Add the LICENSE
    if [ -e LICENSE ]; then
        cat LICENSE >> README
    fi

    echo "Documentation built."
    exit 1
}

function dpkg_install() {
    local DEB="${1}"
    ncecho " [x] Installing ${DEB} "
    dpkg -i "${DEB}" >> "$log" 2>&1 &
    pid=$!;progress $pid
}

copyright_msg ${1}

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
    echo "ERROR! You must specify what Java kit you want to install, either 'jre' or 'jdk'."
    usage
fi

# Let's start doing something...
echo "Here we go..."

# Remove my, now disabled, PPA.
ncecho " [x] Removing ppa:flexiondotorg/java "
rm -v /etc/apt/sources.list.d/flexiondotorg-java-${LSB_CODE}.list* >> "$log" 2>&1
cecho success

apt_update

# Install the build requirements.
ncecho " [x] Installing development tools  "
apt-get install -y --no-install-recommends build-essential debhelper devscripts dpkg-dev git-core >> "$log" 2>&1 &
pid=$!;progress $pid

# Make sure the required dirs exist.
ncecho " [x] Making build directories "
mkdir -p /var/local/oab/{deb,pkg} >> "$log" 2>&1 &
pid=$!;progress $pid

# Remove the 'src' directory everytime.
ncecho " [x] Removing clones of https://github.com/rraptorr/sun-java6 "
rm -rfv /var/local/oab/sun-java6-6.30 2>/dev/null >> "$log" 2>&1 &
pid=$!;progress $pid

# Checkout the code
ncecho " [x] Cloning https://github.com/rraptorr/sun-java6 "
cd /var/local/oab/ >> "$log" 2>&1
git clone git://github.com/rraptorr/sun-java6.git sun-java6-6.30 >> "$log" 2>&1 &
pid=$!;progress $pid

# Download the Oracle install packages.
for JAVA_PLAT in i586 x64
do
    JAVA_BIN="${JAVA_KIT}-${JAVA_VER}u${JAVA_UPD}-linux-${JAVA_PLAT}.bin"
    ncecho " [x] Downloading ${JAVA_BIN} : ~80MB "
    wget -c http://download.oracle.com/otn-pub/java/jdk/${JAVA_VER}u${JAVA_UPD}-${JAVA_REL}/${JAVA_BIN} -O /var/local/oab/pkg/${JAVA_BIN} >> "$log" 2>&1 &
    pid=$!;progress_loop $pid

    ncecho " [x] Symlinking ${JAVA_BIN} "
    ln -s /var/local/oab/pkg/${JAVA_BIN} /var/local/oab/sun-java6-6.30/${JAVA_BIN} >> "$log" 2>&1 &
    pid=$!;progress_loop $pid
done

# Change directory to the build directory
cd /var/local/oab/sun-java6-6.30/

# Get the version
VERSION=`head -n1 debian/changelog | cut -d'(' -f2 | cut -d')' -f1 | cut -d'~' -f1`
PPA_VERSION="${VERSION}~${LSB_CODE}1"

# Genereate a build message
BUILD_MESSAGE="Automated build for Ubuntu ${LSB_REL} using https://github.com/rraptorr/sun-java6"

# Update the changelog
ncecho " [x] Updating the changelog "
dch --distribution ${LSB_CODE} --force-distribution --newversion ${PPA_VERSION} --force-bad-version "${BUILD_MESSAGE}" >> "$log" 2>&1 &
pid=$!;progress $pid

# Build the binary packages
ncecho " [x] Building the packages "
dpkg-buildpackage -b >> "$log" 2>&1 &
pid=$!;progress_can_fail $pid

# Move the .deb files into the 'deb' directory
ncecho " [x] Moving the packages "
mv -v /var/local/oab/sun-java6-*_6.30-2~${LSB_CODE}1_*.deb /var/local/oab/deb/ >> "$log" 2>&1
mv -v /var/local/oab/sun-java6_6.30-2~${LSB_CODE}1_${LSB_ARCH}.changes /var/local/oab/deb/ >> "$log" 2>&1 &
pid=$!;progress $pid

# Install the JRE.
dpkg_install "/var/local/oab/deb/sun-java6-bin_${PPA_VERSION}_${LSB_ARCH}.deb"
dpkg_install "/var/local/oab/deb/sun-java6-plugin_${PPA_VERSION}_${LSB_ARCH}.deb"
dpkg_install "/var/local/oab/deb/sun-java6-jre_${PPA_VERSION}_all.deb"
dpkg_install "/var/local/oab/deb/sun-java6-fonts_${PPA_VERSION}_all.deb"

# If the JDK was requested, then install the extra packages.
if [ "${INST_KIT}" == "jdk" ]; then
    dpkg_install "/var/local/oab/deb/sun-java6-jdk_${PPA_VERSION}_${LSB_ARCH}.deb"
    dpkg_install "/var/local/oab/deb/sun-java6-source_${PPA_VERSION}_all.deb"
fi

echo "All done!"
