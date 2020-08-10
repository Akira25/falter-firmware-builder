#!/bin/sh

# This script implements the tutorial given at http://10.31.44.119:10178/compiling-falter-images-for-freifunk-berlin/
# (only accessible in Freifunk-Berlin-net) from kls0e in a somehow automatted way. Falter, live long and prosperous. ;-)


THREADS=9 # amount of cpu-threads +1
DIFFCONFIG=$(cat diff_config_freifunk)
BUILDDIR="falter-firmware"
VERSION="v0.0.1"


update_owrt() {
    ./scripts/feeds update -a
    ./scripts/feeds install -a
}

init_buildsystem() {
	git clone https://git.openwrt.org/openwrt/openwrt.git $BUILDDIR
	cd $BUILDDIR
	cp feeds.conf.default feeds.conf

	# check if already included
	grep "src-git falter https://github.com/Freifunk-Spalter/packages.git" feeds.conf
	if [ $? != 0 ]; then
		echo "src-git falter https://github.com/Freifunk-Spalter/packages.git" >> feeds.conf
	fi
	update_owrt
}

update() {
	cd $BUILDDIR
	git pull
	update_owrt
}

write_diffconfig() {
	# write new diffconfig
	cd $BUILDDIR
	if [ -e diffconfig ]; then
		rm diffconfig && touch diffconfig
	fi
	for FLAG in $DIFFCONFIG; do
		echo $FLAG >> diffconfig
	done
	cat diffconfig >> .config
	make defconfig
}


case $1 in
	"-i"|"--init")
		init_buildsystem
		;;
	"-s"|"--select")
		cd $BUILDDIR
		make menuconfig
		;;
	"-w"|"--write")
		write_diffconfig
		;;
	"-m"|"--make")
		cd $BUILDDIR
		echo "start building falter with $THREADS threads..."
		make -j$THREADS V=s
		;;
	*)
		echo "Falter-script $VERSION
To build falter-images, execute the options in this order.

-i | --init\tinitialise buildsystem
-s | --select\tselect the target, falter will be built for
-w | --write\twrite the package-selection to buildsystem
-m | --make\tstart building

optional:
-u | --update\tupdates with new patches from falter-repo.
\t\tAfter using this option, you need to start
\t\tagain at option -s.

EVER use only one option at the same time!"
		;;

esac

