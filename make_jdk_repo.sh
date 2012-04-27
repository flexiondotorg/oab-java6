#!/bin/bash
set -e
USAGE="USAGE:\n sudo $0 distribution release gpg_sign_key_id, e.g.\n\n
sudo $0 ubuntu natty ABCD1234\n\n
gpg private and public key must exist in your current keyring\n
pbuilder must be installed on your system.\n
currently works on Ubuntu, for Ubuntu only.\n
Debian version on its way.\n
"

if [ -z "$*" ]; then
    echo -e $USAGE
    exit 1
fi

DISTRO=${1:?"Missing distribution param"}
RELEASE=${2:?"Missing release param"}
SIGN_KEY=${3:?"Missing gpg_sign_key_id param"}

TGZ="oab-${DISTRO}-${RELEASE}.tgz"

if [ ! -e "/var/cache/pbuilder/${TGZ}" ]; then
    pbuilder --create --components "main restricted universe multiverse" --distribution $RELEASE --basetgz /var/cache/pbuilder/${TGZ} --debootstrapopts --variant=buildd
fi
   pbuilder --execute --basetgz /var/cache/pbuilder/${TGZ} --distribution $RELEASE --save-after-exec -- ./jdk_installdeps

mkdir -p tmp
rm -rf tmp/*
gpg --export-secret-key -a $SIGN_KEY > tmp/privkey.asc
gpg --export -a $SIGN_KEY > tmp/pubkey.asc


sudo pbuilder --execute --bindmounts $(pwd) --basetgz /var/cache/pbuilder/${TGZ} --distribution $RELEASE  -- ./jdk_buildpkg $(readlink -f $(pwd)) $SIGN_KEY
rm -rf tmp/*
