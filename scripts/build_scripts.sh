source /tmp/common.sh
# Remove the 'src' directory everytime.
ncecho " [x] Removing previous clones of build scripts "
rm -rfv $1/$3* 2>/dev/null >> "$2" 2>&1
rm -rfv $1/src/$3 2>/dev/null >> "$2" 2>&1 &
pid=$!;progress $pid

# Clone the code
ncecho " [x] Cloning build scripts "
cd $1/ >> "$2" 2>&1
git clone https://github.com/rraptorr/$3 src/$3 >> "$2" 2>&1 &
pid=$!;progress $pid

# Get the last commit tag.
cd $1/src/$3 >> "$2" 2>&1
TAG=`git tag -l | tail -n1`

# Checkout the tagged, stable, version.
ncecho " [x] Checking out ${TAG} "
git checkout ${TAG} >> "$2" 2>&1 &
pid=$!;progress $pid
