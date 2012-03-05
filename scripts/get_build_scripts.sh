source /tmp/common.sh
# Remove the 'src' directory everytime.
ncecho " [x] $1: Removing previous clones of build scripts "
rm -rfv "$BASE/$1"* 2>/dev/null >> "$LOG" 2>&1
rm -rfv "$BASE/src/$1" 2>/dev/null >> "$LOG" 2>&1 &
pid=$!;progress $pid

# Clone the code
ncecho " [x] $1: Cloning build scripts "
cd "$BASE/" >> "$LOG" 2>&1
git clone "https://github.com/rraptorr/$1" "$BASE/src/$1" >> "$LOG" 2>&1 &
pid=$!;progress $pid

# Get the last commit tag.
cd "$BASE/src/$1" >> "$LOG" 2>&1
TAG=`git tag -l | tail -n1`

# Checkout the tagged, stable, version.
ncecho " [x] $1: Checking out ${TAG} "
git checkout "${TAG}" >> "$LOG" 2>&1 &
pid=$!;progress $pid
