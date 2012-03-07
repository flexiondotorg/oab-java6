#!/usr/bin/env bash

if [[ "$DOCS" == "" ]]; then
    DOCS="."
fi

source "$DOCS/common.sh" "$1"

NAME="oab-java.sh"

header "Usage"
echo
code "sudo ./$NAME"
echo
subheader "Optional parameters"
point "`partial_code "-c | --clean"` : Remove pre-existing packages from `partial_code "/var/local/oab/deb"`"
point "`partial_code "-h | --help"` : This help message"
echo
header "How do I download and run this thing?"
echo "Like this."
echo
code "cd ~/"
code "git clone https://github.com/tamersaadeh/oab-java.git"
code "cd oab-java/"
code "sudo ./$NAME"
echo
header "How it works"
echo "This script is merely a wrapper for the most excllent Debian packaging"
echo "scripts prepared by Janusz Dziemidowicz."
echo
link "rraptorr/sun-java6" "https://github.com/rraptorr/sun-java6"
link "rraptorr/oracle-java7" "https://github.com/rraptorr/oracle-java7"
echo
echo "This script is Based on the scirpt prepared by Martin Wimpress."
echo
link "flexiondotorg/oab-java6" "https://github.com/flexiondotorg/oab-java6"
echo
header "The basic execution steps are:"
echo
point "Remove, my now disabled, Java PPA 'ppa:flexiondotorg/java'."
point "Install the tools required to build the Java packages."
point "Create download cache in `partial_code "/var/local/oab/pkg"`."
point "Download the i586 and x64 Java install binaries from Oracle. Yes, `partial_em "both are required"`."
point "Clone the build scripts from `partial_link "rraptorr/sun-java6" "https://github.com/rraptorr/sun-java6"` and `partial_link "rraptorr/oracle-java7" "https://github.com/rraptorr/oracle-java7"`."
point "Build the Java packages applicable to your system."    
point "Create local `partial_code "apt"` repository in `partial_code "/var/local/oab/deb"` for the newly built Java Packages."
point "Create a GnuPG signing key in `partial_code "/var/local/oab/gpg"`, if none exists."
point "Sign the local `partial_code "apt"` repository using the local GnuPG signing key."
echo
header "What gets installed?"
em "Nothing!"
echo
echo "This script will no longer try and directly install or upgrade any Java packages, instead a local 'apt' repository is created that hosts locally built Java packages applicable to your system. It is up to you to installor upgrade the Java packages you require using `partial_code "apt-get"`, `partial_code "aptitude"` , or `partial_code "synaptic"`, etc. For example, once this script has been run you can simply install the JRE by executing the following from a shell."
echo
code "sudo apt-get install sun-java6-jre"
echo "or:"
code "sudo apt-get install oracle-java7-jre"
echo
echo "Or if you already have the \"official\" Ubuntu packages installed then you can upgrade by executing the folowing from a shell."
echo
code "sudo apt-get upgrade"
echo
echo "The local `partial_code "apt"` repository is just that, `partial_em "local"`. It is not accessible remotely and `partial_code "oab-java.sh"` will never enable that capability to ensure compliance with Oracle's asinine license requirements."
echo
header "Known Issues"
echo
point "The Oracle download servers can be horribly slow. My script caches the downloads so you only need download each file once."
echo
header "What is `partial_code "oab"`?"
i "Because, O.A.B! ;-)"
echo
