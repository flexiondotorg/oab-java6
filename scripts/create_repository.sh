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

# This prevents the Filename field from containing a path other than './'.
# Having a filename with a path was generating the following error
# when running 'apt-get install sun-java6-jre':
#
# Failed to fetch file:///var/local/oab/deb//var/local/oab/deb//sun-java6-jre_6.31-1~precise1_all.deb  File not found
#
# The path was appearing twice and eliminating it from the filename field
# addressed the issue and allowed a successful install.

pushd "$BASE/deb"
apt-ftparchive -c="$BASE/apt.conf" packages . "$BASE/deb/override" 2>/dev/null > "$BASE/deb/Packages"
popd

cat "$BASE/deb/Packages" | gzip -c9 > "$BASE/deb/Packages.gz"
rm "$BASE/deb/override" 2>/dev/null
cecho success

# Create the 'apt' Release file
ncecho " [x] Creating $BASE/deb/Release file "
apt-ftparchive -c="$BASE/apt.conf" release "$BASE/deb/"	> "$BASE/deb/Release"
cecho success
