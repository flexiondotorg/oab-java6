#!/usr/bin/env bash

# Bash utility functions I use in various shell scripts.
# Copyright (c) 2012 Martin Wimpress, http://flexion.org/
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

sp="/-\|"
log="build.log"

function error_msg() {
    local MSG="${1}"
    echo "${MSG}"
    exit 1
}

function cecho() {
    echo -e "$1"
    echo -e "$1" >>"$log"
    tput sgr0;
}

function ncecho() {
    echo -ne "$1"
    echo -ne "$1" >>"$log"
    tput sgr0
}

function spinny() {
    echo -ne "\b${sp:i++%${#sp}:1}"
}

function progress() {
    ncecho "  ";
    while [ /bin/true ]; do
        kill -0 $pid 2>/dev/null;
        if [[ $? = "0" ]]; then
            spinny
            sleep 0.25
        else
            ncecho "\b\b";
            wait $pid
            retcode=$?
            echo "$pid's retcode: $retcode" >> "$log"
            if [[ $retcode = "0" ]] || [[ $retcode = "255" ]]; then
                cecho success
            else
                cecho failed
                echo -e " [i] Showing the last 5 lines from the logfile ($log)...";
                tail -n5 "$log"
                exit 1;
            fi
            break 2;
        fi
    done
}

function progress_loop() {
    ncecho "  ";
    while [ /bin/true ]; do
        kill -0 $pid 2>/dev/null;
        if [[ $? = "0" ]]; then
            spinny
            sleep 0.25
        else
            ncecho "\b\b";
            wait $pid
            retcode=$?
            echo "$pid's retcode: $retcode" >> "$log"
            if [[ $retcode = "0" ]] || [[ $retcode = "255" ]]; then
                cecho success
            else
                cecho failed
                echo -e " [i] Showing the last 5 lines from the logfile ($log)...";
                tail -n5 "$log"
                exit 1;
            fi
            break 1;
        fi
    done
}

function progress_can_fail() {
    ncecho "  ";
    while [ /bin/true ]; do
        kill -0 $pid 2>/dev/null;
        if [[ $? = "0" ]]; then
            spinny
            sleep 0.25
        else
            ncecho "\b\b";
            wait $pid
            retcode=$?
            echo "$pid's retcode: $retcode" >> "$log"
            cecho success
            break 2;
        fi
    done
}

function check_root() {
    if [ "$(id -u)" != "0" ]; then
        error_msg "ERROR! You must execute the script as the 'root' user."
    fi
}

function check_user() {
    if [ "$(id -u)" == "0" ]; then
	    error_msg "ERROR! You must execute the script as a normal user."
    fi
}

function check_sudo() {
    if [ ! -n ${SUDO_USER} ]; then
        error_msg "ERROR! You must invoke the script using 'sudo'."
    fi
}

function lsb() {
    local CMD_LSB_RELEASE=`which lsb_release`
    if [ "${CMD_LSB_RELEASE}" == "" ]; then
	    error_msg "ERROR! 'lsb_release' was not found. I can't identify your distribution."
    fi
    LSB_ID=`lsb_release -i | cut -f2 | sed 's/ //g'`
    LSB_REL=`lsb_release -r | cut -f2 | sed 's/ //g'`
    LSB_CODE=`lsb_release -c | cut -f2 | sed 's/ //g'`
    LSB_DESC=`lsb_release -d | cut -f2`
    LSB_ARCH=`dpkg --print-architecture`
    LSB_MACH=`uname -m`
    LSB_NUM=`echo ${LSB_REL} | sed s'/\.//g'`
}

function check_ubuntu() {
    if [ "${1}" != "" ]; then
        SUPPORTED_CODENAMES="${1}"
    else
        SUPPORTED_CODENAMES="all"
    fi

    # Source the lsb-release file.
    lsb

    # Check if this script is supported on this version of Ubuntu.
    if [ "${SUPPORTED_CODENAMES}" == "all" ]; then
        SUPPORTED=1
    else
        SUPPORTED=0
        for CHECK_CODENAME in `echo ${SUPPORTED_CODENAMES}`
        do
            if [ "${LSB_CODE}" == "${CHECK_CODENAME}" ]; then
                SUPPORTED=1
            fi
        done
    fi

    if [ ${SUPPORTED} -eq 0 ]; then
        error_msg "ERROR! ${0} is not supported on this version of Ubuntu."
    fi
}

function replaceinfile() {
    SEARCH=${1}
    REPLACE=${2}
    FILEPATH=${3}
    FILEBASE=`basename ${3}`

    sed -e "s/${SEARCH}/${REPLACE}/" ${FILEPATH} > /tmp/${FILEBASE} 2>"$log"
    if [ ${?} -eq 0 ]; then
        mv /tmp/${FILEBASE} ${FILEPATH}
    else
        cecho "failed: ${SEARCH} - ${FILEPATH}"
    fi
}

function addlinetofile() {
    ADD_LINE=${1}
    FILEPATH=${2}

    CHECK_LINE=`grep -F "${ADD_LINE}" ${FILEPATH}`
    if [ ${?} -ne 0 ]; then
        echo "${ADD_LINE}" >> ${FILEPATH}
    fi
}

function interface_ip() {
    INTERFACE_IP=`ifconfig ${1} 2>/dev/null | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' | egrep -v '255|(127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' | sed 's/ //g'`
    if [ $? -ne 0 ]; then
        error_msg "ERROR! Could not get valid IP address from interface : ${1}"
    fi
}

function current_hostname() {
    CURRENT_HOSTNAME=`hostname -s | sed 's/ //g'`
    if [ "${CURRENT_HOSTNAME}" == "" ]; then
        error_msg "ERROR! Hostname is not correctly configured."
    fi
}

function current_domain() {
    CURRENT_DOMAIN=`hostname -d | sed 's/ //g'`

    # Hmm, still no domain name. Keep looking...
    if [ "${CURRENT_DOMAIN}" == "" ]; then
        CURRENT_DOMAIN=`grep domain /etc/resolv.conf | sed 's/domain //g' | sed 's/ //g'`
    fi

    # What?! Still can't determine the domain name. Look again...
    if [ "${CURRENT_DOMAIN}" == "" ]; then
        CURRENT_DOMAIN=`cat /etc/hostname | cut -d'.' -f2- | sed 's/ //g'`
    fi

    # OK, give up.
    if [ "${CURRENT_DOMAIN}" == "" ]; then
        error_msg "ERROR! Domain is not correctly configured."
    fi
}

function escape() {
    local escaped="'\''"
    echo "${1//\'/$escaped}"
}

function lowercase() {
    _LOWERCASE=`echo "${1}" | tr "[:upper:]" "[:lower:]"`
}

function appercase() {
    _UPPERCASE=`echo "${1}" | tr "[:lower:]" "[:upper:]"`
}

function add_repo_official() {
cat >/etc/apt/sources.list<<ENDOFSOURCES
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE} main restricted
deb-src http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE} main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE}-updates main restricted
deb-src http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE}-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE} universe
deb-src http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE} universe
deb http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE}-updates universe
deb-src http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE}-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team, and may not be under a free licence. Please satisfy yourself as to
## your rights to use the software. Also, please note that software in
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE} multiverse
deb-src http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE} multiverse
deb http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE}-updates multiverse
deb-src http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE}-updates multiverse

## Uncomment the following two lines to add software from the 'backports'
## repository.
## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE}-backports main restricted universe multiverse
deb-src http://gb.archive.ubuntu.com/ubuntu/ ${LSB_CODE}-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu ${LSB_CODE}-security main restricted
deb-src http://security.ubuntu.com/ubuntu ${LSB_CODE}-security main restricted
deb http://security.ubuntu.com/ubuntu ${LSB_CODE}-security universe
deb-src http://security.ubuntu.com/ubuntu ${LSB_CODE}-security universe
deb http://security.ubuntu.com/ubuntu ${LSB_CODE}-security multiverse
deb-src http://security.ubuntu.com/ubuntu ${LSB_CODE}-security multiverse

## Uncomment the following two lines to add software from Canonical's
## 'partner' repository.
## This software is not part of Ubuntu, but is offered by Canonical and the
## respective vendors as a service to Ubuntu users.
deb http://archive.canonical.com/ubuntu ${LSB_CODE} partner
deb-src http://archive.canonical.com/ubuntu ${LSB_CODE} partner

## This software is not part of Ubuntu, but is offered by third-party
## developers who want to ship their latest software.
deb http://extras.ubuntu.com/ubuntu ${LSB_CODE} main
deb-src http://extras.ubuntu.com/ubuntu ${LSB_CODE} main
ENDOFSOURCES
}

function add_repo_medibuntu() {
    ncecho " [x] Adding Medibuntu repo "
    echo "## Please report any bug on https://bugs.launchpad.net/medibuntu/"  > /etc/apt/sources.list.d/medibuntu.list
    echo "deb http://packages.medibuntu.org/ ${LSB_CODE} free non-free"     >> /etc/apt/sources.list.d/medibuntu.list
    echo "deb-src http://packages.medibuntu.org/ ${LSB_CODE} free non-free" >> /etc/apt/sources.list.d/medibuntu.list
    cecho success

    apt_update

    ncecho " [x] Adding Medibuntu key "
    apt-get --yes --quiet --allow-unauthenticated install medibuntu-keyring >>"$log" 2>&1 &
    pid=$!;progress $pid

    apt_update
    apt_install "app-install-data-medibuntu apport-hooks-medibuntu" "Medibuntu Hooks"
}

function add_repo_opera() {
    ncecho " [x] Adding Opera repo "
    echo "#Opera" > /etc/apt/sources.list.d/opera.list
    echo "deb http://deb.opera.com/opera/ stable non-free" >> /etc/apt/sources.list.d/opera.list
    wget -q -O - http://deb.opera.com/archive.key | apt-key add - >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function add_repo_dropbox() {
    ncecho " [x] Adding Dropbox repo "
    echo "#Dropbox" > /etc/apt/sources.list.d/dropbox.list
    echo "deb http://linux.dropbox.com/ubuntu ${LSB_CODE} main" >> /etc/apt/sources.list.d/dropbox.list
    echo "deb-src http://linux.dropbox.com/ubuntu ${LSB_CODE} main" >> /etc/apt/sources.list.d/dropbox.list
    apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function add_repo_spotify() {
    ncecho " [x] Adding Spotify repo "
    echo "deb http://repository.spotify.com stable non-free" > /etc/apt/sources.list.d/spotify.list
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4E9CFF4E >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function add_ppa_old() {
    local PPA=`echo "${1}" | sed 's/ppa://'`
    local PPA_KEY="${2}"
    local PPA_LIST=`echo "${PPA}-${LSB_CODE}.list" | sed 's/\//-/g'`
    ncecho " [x] Adding ${1} "
    if [ ${LSB_NUM} -le 904 ]; then
        echo "deb http://ppa.launchpad.net/${PPA} ${LSB_CODE} main" > /etc/apt/sources.list.d/${PPA_LIST}
        echo "deb-src http://ppa.launchpad.net/${PPA} ${LSB_CODE} main" >> /etc/apt/sources.list.d/${PPA_LIST}
        apt-key adv --recv-keys --keyserver keyserver.ubuntu.com ${PPA_KEY} >>"$log" 2>&1 &
    else
        add-apt-repository ppa:${PPA} >>"$log" 2>&1 &
    fi
    pid=$!;progress $pid
}

function add_ppa() {
    local PPA="${1}"
    ncecho " [x] Adding ${1} "
    add-apt-repository ${PPA} >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function purge_ppa() {
    local PPA="${1}"
    ncecho " [x] Purging ${1} "
    ppa-purge ${PPA} >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function source_install() {
    local SOURCE_DIR="${1}"
    local CONFIGURE_OPTS="${2}"
    cd /tmp/${SOURCE_DIR}
    ncecho " [x] Configure ${SOURCE_DIR} "
    ./configure "${CONFIGURE_OPTS}" >>"$log" 2>&1 &
    pid=$!;progress $pid

    ncecho " [x] Compile ${SOURCE_DIR} "
    make >>"$log" 2>&1 &
    pid=$!;progress $pid

    ncecho " [x] Install ${SOURCE_DIR} "
    make install >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function python_install() {
    local SOURCE_DIR="${1}"
    local INSTALL_OPTS="${2}"
    cd /tmp/${SOURCE_DIR}
    ncecho " [x] Install ${SOURCE_DIR} "
    python setup.py install >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function apt_install() {
    local PACKAGES="${1}"
    if [ "${2}" == "" ]; then
        local DESC=${1}
    else
        local DESC="${2}"
    fi
    ncecho " [x] Installing ${DESC} "
    apt-get -y install ${PACKAGES} >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function apt_purge() {
    local PACKAGES="${1}"
    if [ "${2}" == "" ]; then
        local DESC="${1}"
    else
        local DESC="${2}"
    fi
    ncecho " [x] Purging ${DESC} "
    apt-get -y remove --purge ${PACKAGES} >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function apt_update() {
    ncecho " [x] Update package list "
    apt-get -y update >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function apt_upgrade() {
    ncecho " [x] Upgrading "
    apt-get -y upgrade >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function apt_dist_upgrade() {
    ncecho " [x] Upgrading "
    apt-get -y dist-upgrade >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function apt_autoremove() {
    ncecho " [x] Auto-removing "
    apt-get -y autoremove ${PACKAGES} >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function wget_install_deb() {
    local DEB_URL="${1}"
    local DEB=`echo ${DEB_URL##*\/}`

    cd /tmp
    ncecho " [x] Downloading ${DEB} "
    wget -c "${DEB_URL}" -O /tmp/${DEB} >>"$log" 2>&1 &
    pid=$!;progress $pid

    ncecho " [x] Installing ${DEB} "
    GDEBI=`which gdebi | sed 's/ //g'`
    if [ ! -z ${GDEBI} ]; then
        gdebi -n /tmp/${DEB} >>"$log" 2>&1 &
    else
        dpkg -i /tmp/${DEB} >>"$log" 2>&1 &
    fi
    pid=$!;progress $pid
}

function wget_install_generic() {
    local URL="${1}"
    local INST_DIR="${2}"
    local FILE=`echo ${URL##*\/}`

    mkdir -p ${INST_DIR}
    ncecho " [x] Downloading ${FILE} "
    wget -c "${URL}" -O ${INST_DIR}/${FILE} >>"$log" 2>&1 &
    pid=$!;progress $pid
}

function wget_tarball() {
    local TARBALL_URL="${1}"
    if [ "${2}" == "" ]; then
        local TARBALL=`echo ${TARBALL_URL##*\/}`
    else
        local TARBALL="${2}"
    fi
    local TARBALL_FORMAT=`echo ${TARBALL##*\.}`
    TARBALL_DIR=`echo ${TARBALL} | sed 's/\.tgz//g' | sed 's/\.tar//g' | sed 's/\.gz//g' | sed 's/\.bz2//g' | sed 's/\.xz//g'`

    cd /tmp
    ncecho " [x] Downloading ${TARBALL_URL} "
    wget -c "${TARBALL_URL}" -O /tmp/${TARBALL} >>"$log" 2>&1 &
    pid=$!;progress $pid

    if [ "${TARBALL_FORMAT}" == "bz2" ]; then
        ncecho " [x] Unpacking ${TARBALL} "
        tar jxvf ${TARBALL} >>"$log" 2>&1 &
        pid=$!;progress $pid
    elif [ "${TARBALL_FORMAT}" == "gz" ] || [ "${TARBALL_FORMAT}" == "tgz" ]; then
        ncecho " [x] Unpacking ${TARBALL} "
        tar zxvf ${TARBALL} >>"$log" 2>&1 &
        pid=$!;progress $pid
    elif [ "${TARBALL_FORMAT}" == "xz" ]; then
        ncecho " [x] Unpacking ${TARBALL} "
        tar Jxvf ${TARBALL} >>"$log" 2>&1 &
        pid=$!;progress $pid
    else
        error_msg "ERROR! Unknown tarball format : ${TARBALL}"
    fi
}

function wget_install_src() {
    wget_tarball "${1}"
    source_install ${TARBALL_DIR} "${2}"
}

function system_application_menu() {
    ncecho " [x] Adding menu entry for ${1} "
    echo "[Desktop Entry]"       >  /usr/share/applications/${1}.desktop
    echo "Version=1.0"           >> /usr/share/applications/${1}.desktop
    echo "Exec=${2}"            >> /usr/share/applications/${1}.desktop
    echo "Icon=${3}"            >> /usr/share/applications/${1}.desktop
    echo "Name=${4}"            >> /usr/share/applications/${1}.desktop
    echo "Comment=${4} ${VER}" >> /usr/share/applications/${1}.desktop
    echo "Encoding=UTF-8"        >> /usr/share/applications/${1}.desktop
    echo "Terminal=false"        >> /usr/share/applications/${1}.desktop
    echo "Type=Application"      >> /usr/share/applications/${1}.desktop
    echo "Categories=${5}"      >> /usr/share/applications/${1}.desktop
    cecho success
}

function wget_common() {
    ncecho " [x] Updating common.sh "
    wget -c "https://github.com/flexiondotorg/common/raw/master/common.sh" -O /tmp/common.sh >>"$log" 2>&1 &
    pid=$!;progress $pid    
    chmod 666 /tmp/common.sh >>"$log" 2>&1
}

function update_thyself() {
    if [ ! -e /tmp/common.sh ]; then
        wget_common
    else
        local TODAY=`date +%Y-%m-%d`
        local COMMON=`stat /tmp/common.sh | grep Modify | cut -d' ' -f2 | sed s'/ //g'`
        if [ "${TODAY}" != "${COMMON}" ]; then
            wget_common
        fi
    fi
}
