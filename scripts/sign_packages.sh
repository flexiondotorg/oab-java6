# Skip anything todo with automated key creation if this script is running in
# an OpenVZ container.
if [[ `imvirt` != "OpenVZ" ]]; then
    # Do we need to create signing keys
    if [ ! -e $1/gpg/pubring.gpg ] && [ ! -e $1/gpg/secring.gpg ] && [ ! -e $1/gpg/trustdb.gpg ]; then

        ncecho " [x] Create GnuPG configuration "
        echo "Key-Type: DSA" > $1/gpg-key.conf
        echo "Key-Length: 1024" >> $1/gpg-key.conf
        echo "Subkey-Type: ELG-E" >> $1/gpg-key.conf
        echo "Subkey-Length: 2048" >> $1/gpg-key.conf
        echo "Name-Real: `hostname --fqdn`" >> $1/gpg-key.conf
        echo "Name-Email: root@`hostname --fqdn`" >> $1/gpg-key.conf
        echo "Expire-Date: 0" >> $1/gpg-key.conf
        cecho success

        # Stop the system 'rngd'.
        /etc/init.d/rng-tools stop >> "$2" 2>&1

        ncecho " [x] Start generating entropy "  
        rngd -r /dev/urandom -p /tmp/rngd.pid >> "$2" 2>&1 &
        pid=$!;progress $pid

        ncecho " [x] Creating signing key "
        gpg --homedir $1/gpg --batch --gen-key $1/gpg-key.conf >> "$2" 2>&1 &
        pid=$!;progress $pid

        ncecho " [x] Stop generating entropy "
        kill -9 `cat /tmp/rngd.pid` >> "$2" 2>&1 &
        pid=$!;progress $pid
        rm /tmp/rngd.pid 2>/dev/null

        # Start the system 'rngd'.
        /etc/init.d/rng-tools start >> "$2" 2>&1
    fi
fi

# Do we have signing keys, if so use them.
if [ -e $1/gpg/pubring.gpg ] && [ -e $1/gpg/secring.gpg ] && [ -e $1/gpg/trustdb.gpg ]; then
    # Sign the Release
    ncecho " [x] Signing the 'Release' file "
    rm $1/deb/Release.gpg 2>/dev/null
    gpg --homedir $1/gpg --armor --detach-sign --output $1/deb/Release.gpg $1/deb/Release >> "$2" 2>&1 &
    pid=$!;progress $pid

    # Export public signing key
    ncecho " [x] Exporting public key "
    gpg --homedir $1/gpg --export -a "`hostname --fqdn`" > $1/deb/pubkey.asc
    cecho success

    # Add the public signing key
    ncecho " [x] Adding public key "
    apt-key add $1/deb/pubkey.asc >> "$2" 2>&1 &
    pid=$!;progress $pid
fi
