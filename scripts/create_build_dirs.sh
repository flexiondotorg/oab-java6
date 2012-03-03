# Make sure the required dirs exist.
ncecho " [x] Making build directories "
mkdir -p $1/{deb,gpg,pkg} >> "$2" 2>&1 &
pid=$!;progress $pid

# Set the permissions appropriately for 'gpg'
chown root:root $1/gpg 2>/dev/null
chmod 0700 $1/gpg 2>/dev/null

