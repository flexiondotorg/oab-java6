source /tmp/common.sh
# Remove the 'src' directory everytime.
ncecho " [x] Removing previous clones of build scripts "
rm -rfv $2/$4* 2>/dev/null >> "$3" 2>&1
rm -rfv $2/src/$4 2>/dev/null >> "$3" 2>&1 &
pid=$!;progress $pid

# Clone the code
ncecho " [x] Cloning build scripts "
cd $2/ >> "$3" 2>&1
git clone https://github.com/rraptorr/$4 src/$4 >> "$3" 2>&1 &
pid=$!;progress $pid

# Get the last commit tag.
cd $2/src/$4 >> "$3" 2>&1
TAG=`git tag -l | tail -n1`

# Checkout the tagged, stable, version.
ncecho " [x] Checking out ${TAG} "
git checkout ${TAG} >> "$3" 2>&1 &
pid=$!;progress $pid
