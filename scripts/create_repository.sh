# Create a temporary 'override' file, which may contain duplicates
echo "#Override" > /tmp/override
echo "#Package priority section" >> /tmp/override
for FILE in $1/deb/*.deb
do
    DEB_PACKAGE=`dpkg --info ${FILE} | grep Package | cut -d':' -f2`
    DEB_SECTION=`dpkg --info ${FILE} | grep Section | cut -d'/' -f2`
    echo "${DEB_PACKAGE} high ${DEB_SECTION}" >> /tmp/override
done

# Remove the duplicates from the overide file
uniq /tmp/override > $1/deb/override

# Create the 'apt' Packages.gz
ncecho " [x] Creating Packages.gz file "
cd $1/deb
dpkg-scanpackages . override 2>/dev/null > Packages
cat Packages | gzip -c9 > Packages.gz
rm $1/deb/override 2>/dev/null
cecho success

# Create a 'Release' file
ncecho " [x] Creating Release file "
cd $1/deb
echo "Origin: `hostname --fqdn`"                 >  Release
echo "Label: Java"                                >> Release
echo "Suite: ${LSB_CODE}"                       >> Release
echo "Version: ${LSB_REL}"                      >> Release
echo "Codename: ${LSB_CODE}"                    >> Release
echo "Date: `date -R`"                           >> Release
echo "Architectures: ${LSB_ARCH}"               >> Release
echo "Components: restricted"                     >> Release
echo "Description: Local Java Repository"         >> Release 
echo "MD5Sum:"                                    >> Release
for PACKAGE in Packages*
do
    printf ' '`md5sum ${PACKAGE} | cut -d' ' -f1`" %16d ${PACKAGE}\n" `wc --bytes ${PACKAGE} | cut -d' ' -f1` >> Release
done
cecho success
