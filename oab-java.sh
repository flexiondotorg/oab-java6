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
SCRIPTS="scripts"
BASE="/var/local/oab"

BUILD_KEY=""
BUILD_CLEAN=0

JAVA6="sun-java6"
JAVA7="oracle-java7"

./$SCRIPTS/copywright_msg.sh

./$SCRIPTS/use_common.sh
source /tmp/common.sh

# Override log
log="${PWD}/`basename ${0}`.log"

# Check we are running on a supported system in the correct way.
check_root
check_sudo
check_ubuntu "all"

#if [ "${LSB_CODE}" == "precise" ]; then
#    error_msg "ERROR! Ubuntu Precise is not currently supported see https://github.com/rraptorr/sun-java6/issues/5"
#fi

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

./$SCRIPTS/remove_ppa.sh "$log"

./$SCRIPTS/install_build_deps.sh "$log"

./$SCRIPTS/build_scripts.sh "$BASE" "$log"

# for sun-java6
./$SCRIPTS/build_scripts.sh "$BASE" "$log" "$JAVA6"
./$SCRIPTS/get_java.sh "$BASE" "$log" "$JAVA6" "$BUILD_CLEAN"

# for oracle-java7
./$SCRIPTS/build_scripts.sh "$BASE" "$log" "$JAVA7"
./$SCRIPTS/get_java.sh "$BASE" "$log" "$JAVA7" "$BUILD_CLEAN"

./$SCRIPTS/create_repository.sh "$BASE" "$log"

./$SCRIPTS/sign_packages.sh "$BASE" "$log"

# Update apt cache
echo "deb file://$BASE/deb /" > /etc/apt/sources.list.d/oab.list
apt_update

echo "All done!"
