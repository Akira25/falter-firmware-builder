#!/bin/sh

# This script implements the tutorial given at http://10.31.44.119:10178/compiling-falter-images-for-freifunk-berlin/
# (only accessible in Freifunk-Berlin-net) from kls0e in a somehow automatted way. Falter, live long and prosperous. ;-)

# get amount of cpu-threads +1
THREADS_TMP=$(lscpu | grep "CPU(s):" | head -n 1 | rev | cut -d' ' -f 1)
THREADS=$(($THREADS_TMP + 1))
DIFFCONFIG=$(cat diff_config_freifunk)
BUILDDIR="falter-firmware"
VERSION="v0.0.5"

set -e

update_owrt() {
    ./scripts/feeds update -a
    ./scripts/feeds install -a
}

add_falter_feed() {
    # check if already included
    cp feeds.conf.default feeds.conf
    if [ "$(grep 'src-git falter https://github.com/Freifunk-Spalter/packages.git' feeds.conf)" != 0 ]; then
        echo "src-git falter https://github.com/Freifunk-Spalter/packages.git" >>feeds.conf
    fi
}

init_buildsystem() {
    git clone https://git.openwrt.org/openwrt/openwrt.git $BUILDDIR
    cd $BUILDDIR
    add_falter_feed
    update_owrt
}

update_source() {
    cd $BUILDDIR
    git pull
    update_owrt
}

branch_change() {
    cd $BUILDDIR
    echo "performing distclean on $BUILDDIR..."
    make distclean
    echo "switching branch to $1..."
    git checkout $1
    add_falter_feed
    update_owrt
}

write_diffconfig() {
    # write new diffconfig
    cd $BUILDDIR
    if [ -e diffconfig ]; then
        rm diffconfig && touch diffconfig
    fi
    ./scripts/diffconfig.sh > diffconfig

    # write diff for freifunk-packages
    for FLAG in $DIFFCONFIG; do
        echo "$FLAG" >>diffconfig
    done
    cp diffconfig .config
    #cat diffconfig >>.config
    make defconfig
}

case $1 in
    "-i" | "--init")
        init_buildsystem
    ;;
    "-s" | "--select")
        cd $BUILDDIR
        make menuconfig
    ;;
    "-w" | "--write")
        write_diffconfig
    ;;
    "-m" | "--make")
        cd $BUILDDIR
        echo "start building falter with $THREADS threads..."
        make -j$THREADS V=sc
    ;;
    "-u" | "--update")
        update_source
    ;;
    "-b" | "--branch")
        TAG=$2
        branch_change $TAG
    ;;
    *)
    echo -e "Falter-build-script $VERSION
To build falter-images, execute the options in this order.

-i | --init\tinitialise buildsystem
-s | --select\tselect the target, falter will be built for
-w | --write\twrite the package-selection to buildsystem
-m | --make\tstart building

optional:
-u | --update\t\tupdates with new patches from falter-repo.
\t\t\tAfter using this option, you need to start
\t\t\tagain at option -s.
-b | --branch [\$BRANCH]\tif you want to build falter on a different
\t\t\tOpenWrt-branch than master, give the branch
\t\t\tor tag. After executing this option start
\t\t\tagain at -s.

EVER use only one option at the same time!"
    ;;

esac
