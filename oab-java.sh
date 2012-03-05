#!/usr/bin/env bash

# License
#
# Create a local 'apt' repository for Ubuntu Java packages.
# Copyright (c) 2012 Flexion.Org, http://flexion.org/
#
# Copyright (c) 2012 Tamer Saadeh <tamersaadeh@gmail.com>
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
#  - https://github.com/rraptorr/oracle-java7
#  - https://github.com/flexiondotorg/oab-java6
#  - http://ubuntuforums.org/showthread.php?t=1090731
#  - http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/gpg-cs.html

# Variables
export SCRIPTS="scripts"
export BASE="/var/local/oab"
export LOG="build.log"
export BUILD_KEY=""
export BUILD_CLEAN=0

export JAVA6="sun-java6"
export JAVA7="oracle-java7"

./$SCRIPTS/copywright_msg.sh

./$SCRIPTS/use_common.sh
source /tmp/common.sh

# Check we are running on a supported system in the correct way.
check_root
check_sudo
check_ubuntu "all"

# Parse the options
OPTSTRING=bchk:
while getopts ${OPTSTRING} OPT
do
    case ${OPT} in
        b|-build-docs)
          ./$SCRIPTS/build_docs.sh
          exit 0
        ;;
        c|-clean) BUILD_CLEAN=1;;
        h|-help)
          ./$SCRIPTS/usage.sh
          exit 0
        ;;
        k) BUILD_KEY=${OPTARG};;
        *)
          ./$SCRIPTS/usage.sh
          exit 1
        ;;
    esac
done
shift "$(( $OPTIND - 1 ))"

./$SCRIPTS/remove_ppa.sh

./$SCRIPTS/install_build_deps.sh

./$SCRIPTS/create_build_dirs.sh

# for sun-java6
./$SCRIPTS/get_build_scripts.sh "$JAVA6"
./$SCRIPTS/get_java6.sh

# for oracle-java7
./$SCRIPTS/get_build_scripts.sh "$JAVA7"
./$SCRIPTS/get_java7.sh

./$SCRIPTS/create_repository.sh

./$SCRIPTS/sign_packages.sh

# Update apt cache
echo "deb file://$BASE/deb /" > /etc/apt/sources.list.d/oab.list
apt_update

# remove download index and download release page
echo "removing extra files..." >> $LOG
rm -rf /tmp/oab-index.html
rm -rf /tmp/oab-download.html

# unset global variables
echo "unsetting variables..." >> $LOG
unset SCRIPTS
unset BASE
unset LOG
unset BUILD_KEY
unset BUILD_CLEAN
unset DEB_VERSION
unset DEB_URGENCY
unset JAVA_VER
unset JAVA_UPD
unset JAVA6
unset JAVA7

echo "All done!"
