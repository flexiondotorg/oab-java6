# 'source' my common functions
#if [ -r /tmp/common.sh ]; then
#    source /tmp/common.sh
#    if [ $? -ne 0 ]; then
#        echo "ERROR! Couldn't import common functions from /tmp/common.sh"
#        rm /tmp/common.sh 2>/dev/null
#        exit 1
#    else
#        source /tmp/common.sh
#        update_thyself        
#    fi
#else
#    echo "Downloading common.sh"
#    wget --no-check-certificate -q "https://github.com/flexiondotorg/common/raw/master/common.sh" -O /tmp/common.sh
#    chmod 666 /tmp/common.sh
#    source /tmp/common.sh
#    if [ $? -ne 0 ]; then
#        echo "ERROR! Couldn't import common functions from /tmp/common.sh"
#        rm /tmp/common.sh 2>/dev/null
#        exit 1
#    fi
#fi
cp ./$SCRIPTS/common.sh /tmp
