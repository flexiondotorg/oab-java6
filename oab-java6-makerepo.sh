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
#  - http://ubuntuforums.org/showthread.php?t=1090731
#  - http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/gpg-cs.html

# Variables
VER="0.1.5"

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
    echo "  - Download the i586 and x64 Java install binaries from Oracle. Yes, both are required."
    echo "  - Clone the build scripts from https://github.com/rraptorr/sun-java6"
    echo "  - Build the Java packages applicable to your system."    
    echo "  - Create local 'apt' repository in '/var/local/oab/deb' for the newly built Java Packages."
    echo "  - Create a GnuPG signing key in '/var/local/oab/gpg' if none exists."
    echo "  - Sign the local 'apt' repository using the local GnuPG signing key."
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
    echo "Known Issues"
    echo "============"
    echo
    echo "  - The Oracle download servers can be horribly slow. My script caches the"    
    echo "    downloads so you only need download each file once."
    echo "  - This script doesn't dynamically determine the download URLs for the"
    echo "    Java installers released by Oracle. Currently, when a new Java version is"
    echo "    released by Oracle this script must be updated to support that new version."
    echo "    I hope to address this limitation in the future."
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
    wget -q "https://github.com/flexiondotorg/common/raw/master/common.sh" -O /tmp/common.sh
    chmod 666 /tmp/common.sh
    source /tmp/common.sh
    if [ $? -ne 0 ]; then
        echo "ERROR! Couldn't import common functions from /tmp/common.sh"
        rm /tmp/common.sh 2>/dev/null
        exit 1
    fi
fi

# Check we are running on a supported system in the correct way.
check_root
check_sudo
check_ubuntu "all"

SIGN_KEY="$1"
OUTPUT_DIR="$2"

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


# Determine the build and runtime requirements.
BUILD_DEPS="build-essential debhelper defoma devscripts dpkg-dev git-core gnupg libasound2 libxi6 libxt6 libxtst6 unixodbc unzip"
if [ "${LSB_ARCH}" == "amd64" ]; then
    BUILD_DEPS="${BUILD_DEPS} lib32asound2 ia32-libs"
fi

# Install the Java build requirements - maybe redundant.
ncecho " [x] Installing Java build requirements "
apt-get install -y --no-install-recommends ${BUILD_DEPS} >> "$log" 2>&1 &
pid=$!;progress $pid

# Make sure the required dirs exist.
ncecho " [x] Making build directories "
mkdir -p /var/local/oab/{deb,gpg,pkg} >> "$log" 2>&1 &
pid=$!;progress $pid

# Set the permissions appropriately for 'gpg'
chown root:root /var/local/oab/gpg 2>/dev/null
chmod 0700 /var/local/oab/gpg 2>/dev/null

# copy in possibly cached files from host system
cp cache/*.bin /var/local/oab/pkg || /bin/true

# create default gpg config.
ncecho " [x] Create GnuPG configuration "
echo "Key-Type: DSA" > /var/local/oab/gpg-key.conf
echo "Key-Length: 1024" >> /var/local/oab/gpg-key.conf
echo "Subkey-Type: ELG-E" >> /var/local/oab/gpg-key.conf
echo "Subkey-Length: 2048" >> /var/local/oab/gpg-key.conf
echo "Name-Real: `hostname --fqdn`" >> /var/local/oab/gpg-key.conf
echo "Name-Email: root@`hostname --fqdn`" >> /var/local/oab/gpg-key.conf
echo "Expire-Date: 0" >> /var/local/oab/gpg-key.conf
cecho success

# Import signing keys
if [ ! -e /var/local/oab/gpg/pubring.gpg ] && [ ! -e /var/local/oab/gpg/secring.gpg ] && [ ! -e /var/local/oab/gpg/trustdb.gpg ]; then
    ncecho " [x] Importing signing key"
    gpg --homedir /var/local/oab/gpg --batch --import tmp/privkey.asc >> "$log" 2>&1 &
    gpg --homedir /var/local/oab/gpg --batch --import tmp/pubkey.asc >> "$log" 2>&1 &
    pid=$!;progress $pid
fi

# Remove the 'src' directory everytime.
ncecho " [x] Removing clones of https://github.com/rraptorr/sun-java6 "
rm -rfv /var/local/oab/sun-java6* 2>/dev/null >> "$log" 2>&1
rm -rfv /var/local/oab/src 2>/dev/null >> "$log" 2>&1 &
pid=$!;progress $pid

# Clone the code
ncecho " [x] Cloning https://github.com/rraptorr/sun-java6 "
cd /var/local/oab/ >> "$log" 2>&1
git clone git://github.com/rraptorr/sun-java6.git src >> "$log" 2>&1 &
pid=$!;progress $pid

# Cet the current Debian package version and package urgency
DEB_VERSION=`head -n1 /var/local/oab/src/debian/changelog | cut -d'(' -f2 | cut -d')' -f1 | cut -d'~' -f1`
DEB_URGENCY=`head -n1 /var/local/oab/src/debian/changelog | cut -d'=' -f2` 

# Determine the currently supported Java version and update
JAVA_VER=`echo ${DEB_VERSION} | cut -d'.' -f1`
JAVA_UPD=`echo ${DEB_VERSION} | cut -d'.' -f2 | cut -d'-' -f1`

# Determine the JAVA_REL based on known Java releases
if [ "${JAVA_VER}" != "6" ] && [ "${JAVA_UPD}" != "30" ]; then
    error_msg "ERROR! A new version of Java has been released. Update this script!"
fi    

# Damn it, if it weren't for having to know the release number this could be 
# entirely dynamic!
JAVA_REL="b12"

# Checkout the latest tagged release
cd /var/local/oab/src >> "$log" 2>&1
TAG=`git tag -l v${JAVA_VER}.${JAVA_UPD}-* | tail -n1`

ncecho " [x] Checking out ${TAG} "
git checkout ${TAG} >> "$log" 2>&1 &
pid=$!;progress $pid


# Download the Oracle install packages.
for JAVA_BIN in jdk-${JAVA_VER}u${JAVA_UPD}-linux-i586.bin jdk-${JAVA_VER}u${JAVA_UPD}-linux-x64.bin
do
    ncecho " [x] Downloading ${JAVA_BIN} : ~80MB "
    wget -c http://download.oracle.com/otn-pub/java/jdk/${JAVA_VER}u${JAVA_UPD}-${JAVA_REL}/${JAVA_BIN} -O /var/local/oab/pkg/${JAVA_BIN} >> "$log" 2>&1 &
    pid=$!;progress_loop $pid

    ncecho " [x] Symlinking ${JAVA_BIN} "
    ln -s /var/local/oab/pkg/${JAVA_BIN} /var/local/oab/src/${JAVA_BIN} >> "$log" 2>&1 &
    pid=$!;progress_loop $pid
done

# Determine the new version
NEW_VERSION="${DEB_VERSION}~${LSB_CODE}1"

# Genereate a build message
BUILD_MESSAGE="Automated build for ${LSB_REL} using https://github.com/rraptorr/sun-java6"

# Change directory to the build directory
cd /var/local/oab/src

# Update the changelog
ncecho " [x] Updating the changelog "
dch --distribution ${LSB_CODE} --force-distribution --newversion ${NEW_VERSION} --force-bad-version --urgency=${DEB_URGENCY} "${BUILD_MESSAGE}" >> "$log" 2>&1 &
pid=$!;progress $pid

# Build the binary packages
ncecho " [x] Building the packages "
dpkg-buildpackage -b >> "$log" 2>&1 &
pid=$!;progress_can_fail $pid

# Populate the 'apt' repository with .debs
ncecho " [x] Moving the packages "
mv -v /var/local/oab/sun-java${JAVA_VER}_${NEW_VERSION}_${LSB_ARCH}.changes /var/local/oab/deb/ >> "$log" 2>&1
mv -v /var/local/oab/*sun-java${JAVA_VER}-*_${NEW_VERSION}_*.deb /var/local/oab/deb/ >> "$log" 2>&1 &
pid=$!;progress $pid

# Create a temporary 'override' file, which may contain duplicates
echo "#Override" > /tmp/override
echo "#Package priority section" >> /tmp/override
for FILE in /var/local/oab/deb/*.deb
do
    DEB_PACKAGE=`dpkg --info ${FILE} | grep Package | cut -d':' -f2`
    DEB_SECTION=`dpkg --info ${FILE} | grep Section | cut -d'/' -f2`
    echo "${DEB_PACKAGE} high ${DEB_SECTION}" >> /tmp/override
done

# Remove the duplicates from the overide file
uniq /tmp/override > /var/local/oab/deb/override

# Create the 'apt' Packages.gz
ncecho " [x] Creating Packages.gz file "
cd /var/local/oab/deb
dpkg-scanpackages . override 2>/dev/null > Packages
cat Packages | gzip -c9 > Packages.gz
rm /var/local/oab/deb/override 2>/dev/null
cecho success

# Create a 'Release' file
ncecho " [x] Creating Release file "
cd /var/local/oab/deb
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


# Do we have signing keys, if so use them.
if [ -e /var/local/oab/gpg/pubring.gpg ] && [ -e /var/local/oab/gpg/secring.gpg ] && [ -e /var/local/oab/gpg/trustdb.gpg ]; then

    # Sign the Release
    ncecho " [x] Signing the 'Release' file "
    rm /var/local/oab/deb/Release.gpg 2>/dev/null
    gpg --trust-model always -u $SIGN_KEY --homedir /var/local/oab/gpg --armor --detach-sign --output /var/local/oab/deb/Release.gpg /var/local/oab/deb/Release 
        
#    # Add the public signing key
#    ncecho " [x] Adding public key "
#    apt-key add /var/local/oab/deb/pubkey.asc >> "$log" 2>&1 &
#    pid=$!;progress $pid             
fi

ncecho " [x] copying files to output directory "

mkdir -p $OUTPUT_DIR/ubuntu/$LSB_CODE
cp -pr /var/local/oab/deb/* $OUTPUT_DIR/ubuntu/$LSB_CODE
    

# Update apt cache
#echo "deb file:///var/local/oab/deb /" > /etc/apt/sources.list.d/oab.list
#apt_update

echo "All done!"
