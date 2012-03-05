source /tmp/common.sh
lsb

##cd "$BASE/src/$1"

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

# Create the 'apt' Packages.gz
ncecho " [x] Creating $BASE/deb/Packages.gz file "
dpkg-scanpackages "$BASE/deb/" "$BASE/deb/override" 2>/dev/null > "$BASE/deb/Packages"
cat "$BASE/deb/Packages" | gzip -c9 > "$BASE/deb/Packages.gz"
rm "$BASE/deb/override" 2>/dev/null
cecho success

# Create a '"$BASE/deb/Release"' file
ncecho " [x] Creating $BASE/deb/Release file "
echo "Origin: `hostname --fqdn`"                 >  "$BASE/deb/Release"
echo "Label: Java"                                >> "$BASE/deb/Release"
echo "Suite: ${LSB_CODE}"                       >> "$BASE/deb/Release"
echo "Version: ${LSB_REL}"                      >> "$BASE/deb/Release"
echo "Codename: ${LSB_CODE}"                    >> "$BASE/deb/Release"
echo "Date: `date -R`"                           >> "$BASE/deb/Release"
echo "Architectures: ${LSB_ARCH}"               >> "$BASE/deb/Release"
echo "Components: restricted"                     >> "$BASE/deb/Release"
echo "Description: Local Java Repository"         >> "$BASE/deb/Release"
echo "MD5Sum:"                                    >> "$BASE/deb/Release"
for PACKAGE in "$BASE/deb/Packages"*
do
    printf ' '`md5sum ${PACKAGE} | cut -d' ' -f1`" %16d ${PACKAGE}\n" `wc --bytes ${PACKAGE} | cut -d' ' -f1` >> "$BASE/deb/Release"
done
cecho success
