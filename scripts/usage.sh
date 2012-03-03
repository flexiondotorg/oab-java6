function usage() {
    local MODE=${1}
    echo "Usage"
    echo
    echo "  sudo ${0}"
    echo
    echo "Optional parameters"
    echo "  -c | --clean : Remove pre-existing packages from '/var/local/oab/deb'"
    echo "  -h | --help : This help message"
    echo
    echo "How do I download and run this thing?"
    echo "====================================="
    echo "Like this."
    echo
    echo "  cd ~/"
    echo "  wget https://raw.github.com/tamersaadeh/oab-java7/master/`basename ${0}` -O `basename ${0}`"
    echo "  chmod +x `basename ${0}`"
    echo "  sudo ./`basename ${0}`"
    echo
    echo "How it works"
    echo "============"
    echo "This script is merely a wrapper for the most excllent Debian packaging"
    echo "scripts prepared by Janusz Dziemidowicz."
    echo
    echo "  - https://github.com/rraptorr/sun-java6"
    echo "  - https://github.com/rraptorr/oracle-java7"
    echo
    echo "This script is Based on the scirpt prepared by Martin Wimpress."
    echo
    echo "  - https://github.com/flexiondotorg/oab-java6"
    echo
    echo "The basic execution steps are:"
    echo
    echo "  - Remove, my now disabled, Java PPA 'ppa:flexiondotorg/java'."
    echo "  - Install the tools required to build the Java packages."
    echo "  - Create download cache in '/var/local/oab/pkg'."
    echo "  - Download the i586 and x64 Java install binaries from Oracle. Yes, both are required."
    echo "  - Clone the build scripts from https://github.com/rraptorr/sun-java6 and https://github.com/rraptorr/oracle-java7"
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
    echo "or"
    echo "  sudo apt-get install oracle-java7-jre"
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

usage
