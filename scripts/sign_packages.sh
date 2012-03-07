source "$SCRIPTS/common.sh"

# Skip anything todo with automated key creation if this script is running in
# an OpenVZ container.
if [[ `imvirt` != "OpenVZ" ]]; then
    # Do we need to create signing keys
    if [ ! -e "$BASE/gpg/pubring.gpg" ] && [ ! -e "$BASE/gpg/secring.gpg" ] && [ ! -e "$BASE/gpg/trustdb.gpg" ]; then

        ncecho " [x] Create GnuPG configuration "
        echo "Key-Type: DSA" > "$BASE/gpg-key.conf"
        echo "Key-Length: 1024" >> "$BASE/gpg-key.conf"
        echo "Subkey-Type: ELG-E" >> "$BASE/gpg-key.conf"
        echo "Subkey-Length: 2048" >> "$BASE/gpg-key.conf"
        echo "Name-Real: `hostname --fqdn`" >> "$BASE/gpg-key.conf"
        echo "Name-Email: root@`hostname --fqdn`" >> "$BASE/gpg-key.conf"
        echo "Expire-Date: 0" >> "$BASE/gpg-key.conf"
        cecho success

        # Stop the system 'rngd'.
        /etc/init.d/rng-tools stop >> "$LOG" 2>&1

        ncecho " [x] Start generating entropy "  
        rngd -r /dev/urandom -p /tmp/rngd.pid >> "$LOG" 2>&1 &
        pid=$!;progress $pid

        ncecho " [x] Creating signing key "
        gpg --homedir "$BASE/gpg" --batch --gen-key "$BASE/gpg-key.conf" >> "$LOG" 2>&1 &
        pid=$!;progress $pid

        ncecho " [x] Stop generating entropy "
        kill -9 `cat /tmp/rngd.pid` >> "$LOG" 2>&1 &
        pid=$!;progress $pid
        rm /tmp/rngd.pid 2>/dev/null

        # Start the system 'rngd'.
        /etc/init.d/rng-tools start >> "$LOG" 2>&1
    fi
fi

# Do we have signing keys, if so use them.
if [ -e "$BASE/gpg/pubring.gpg" ] && [ -e "$BASE/gpg/secring.gpg" ] && [ -e "$BASE/gpg/trustdb.gpg" ]; then
    # Sign the Release
    ncecho " [x] Signing the 'Release' file "
    rm "$BASE/deb/Release.gpg" 2>/dev/null
    gpg --homedir "$BASE/gpg" --armor --detach-sign --output "$BASE/deb/Release.gpg" "$BASE/deb/Release" >> "$LOG" 2>&1 &
    pid=$!;progress $pid

    # Export public signing key
    ncecho " [x] Exporting public key "
    gpg --homedir "$BASE/gpg" --export -a "`hostname --fqdn`" > "$BASE/deb/pubkey.asc"
    cecho success

    # Add the public signing key
    ncecho " [x] Adding public key "
    apt-key add "$BASE/deb/pubkey.asc" >> "$LOG" 2>&1 &
    pid=$!;progress $pid
fi
