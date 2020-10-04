#!/bin/sh

set -e

BUILDDIR="falter-firmware"
CONFIG_FILE="$BUILDDIR/.config"			# configfile of OpenWrt-buildsystem
TARGET_CONFIGS=$(find "$(cd target_config || exit; pwd)" -type f)
RELEASE="diffconfigs/falter_19.07.4" 				# directory with diffconfigs
OPENWRT_RELEASE_TAG="v19.07.4"			# release-tag for OpenWrt
PACKAGE_SETS=$(find "$(cd $RELEASE || exit; pwd)" -type f) # diffconfigs from release-dir
BUILDOPTIONS=$(cat build_config/general)
VERSIONINFO=$(cat build_config/version)

config_buildsystem() {
    if [ -e $CONFIG_FILE ]; then
        rm $CONFIG_FILE
    fi
    # write targetconfig into diffconfig
    echo "$SELECTED_IMAGES" > $CONFIG_FILE
    echo "$BUILDOPTIONS" >> $CONFIG_FILE
    echo "$VERSIONINFO" >> $CONFIG_FILE
    # add diffconfig (packageset)
    ./falter.sh -w "$IMAGE_TYPE"
    ./falter.sh -m
}

package_firmwares() {
    TYPENAME=$(echo "$IMAGE_TYPE" | rev | cut -f1 -d'/' | rev)
    zip -r "$TYPENAME.zip" $BUILDDIR/bin/
    rm -rf ${BUILDDIR:?}/bin/*
}


##############
#    MAIN    #
##############

# check for builddir
if [ ! -d $BUILDDIR ]; then
    ./falter.sh -i
fi

# switch to release-basis
# TODO: write something to check for git hash: Do nothing, if the wished tag is already checked out...
if [ -n "$OPENWRT_RELEASE_TAG" ]; then
    TAG_HASH=$(cd $BUILDDIR; git rev-list -1 "$OPENWRT_RELEASE_TAG")
fi
CURRENT_HASH=$(cd $BUILDDIR; git rev-parse HEAD)
if [ -n "$OPENWRT_RELEASE_TAG" -a TAG_HASH != CURRENT_HASH ]; then
    ./falter.sh -b "$OPENWRT_RELEASE_TAG"
fi

if [ -z "$1" ]; then
    # build for every target all imagetypes. Uses the targets defined in
    # target_configs/ and imagetypes defined in the release-folder
    for IMAGE_TYPE in $PACKAGE_SETS; do
        for TARGET in $TARGET_CONFIGS; do
            SELECTED_IMAGES=$(cat "$TARGET")
            config_buildsystem
        done
        # package firmwares
        package_firmwares
    done
else
    # build just target mentioned in $1
    for IMAGE_TYPE in $PACKAGE_SETS; do
        SELECTED_IMAGES=$(cat "$1")
        config_buildsystem
        # package firmwares
        package_firmwares
    done
fi