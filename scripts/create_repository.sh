source "$SCRIPTS/common.sh"
lsb

# Create a temporary 'override' file, which may contain duplicates
echo "#Override" > /tmp/override
echo "#Package priority section" >> /tmp/override
for FILE in "$BASE/deb/"*".deb"
do
    DEB_PACKAGE=`dpkg --info ${FILE} | grep Package | cut -d':' -f2`
    DEB_SECTION=`dpkg --info ${FILE} | grep Section | cut -d'/' -f2`
    echo "${DEB_PACKAGE} high ${DEB_SECTION}" >> /tmp/override
done

# Remove the duplicates from the overide file
uniq /tmp/override > "$BASE/deb/override"

# Create the apt.conf file
ncecho " [x] Generation $BASE/apt.conf configuration file "
echo "APT::FTPArchive::Release {"		> "$BASE/apt.conf"
echo "Origin \"`hostname --fqdn`\";"		>> "$BASE/apt.conf"
echo "Label \"Java\";"				>> "$BASE/apt.conf"
echo "Suite \"${LSB_CODE}\";"                   >> "$BASE/apt.conf"
echo "Codename \"${LSB_CODE}\";"                >> "$BASE/apt.conf"
echo "Architectures \"${LSB_ARCH}\";"           >> "$BASE/apt.conf"
echo "Components \"restricted\";"               >> "$BASE/apt.conf"
echo "Description \"Local Java Repository\";"   >> "$BASE/apt.conf"
echo "}"					>> "$BASE/apt.conf"
cecho success

# Create the 'apt' Packages.gz file
ncecho " [x] Creating $BASE/deb/Packages.gz file "
apt-ftparchive -c="$BASE/apt.conf" packages "$BASE/deb/" "$BASE/deb/override" 2>/dev/null > "$BASE/deb/Packages"
cat "$BASE/deb/Packages" | gzip -c9 > "$BASE/deb/Packages.gz"
rm "$BASE/deb/override" 2>/dev/null
cecho success

# Create the 'apt' Release file
ncecho " [x] Creating $BASE/deb/Release file "
apt-ftparchive -c="$BASE/apt.conf" release "$BASE/deb/"	> "$BASE/deb/Release"
cecho success

# Moving .deb file to the correct position
# This is a workaround until I figure out how to fix this bug
ncecho " [x] Moving .deb file "
mkdir -pv "$BASE/deb$BASE/deb/" >> "$LOG"
mv -v "$BASE/deb/"*".deb" "$BASE/deb$BASE/deb/" >>"$LOG"
cecho success
