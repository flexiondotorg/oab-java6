source /tmp/common.sh
# Make sure the required dirs exist.
ncecho " [x] Making build directories "
mkdir -p "$2/{deb,gpg,pkg}" >> "$3" 2>&1 &
pid=$!;progress $pid

# Set the permissions appropriately for 'gpg'
chown root:root "$2/gpg" 2>/dev/null
chmod 0700 "$2/gpg" 2>/dev/null

