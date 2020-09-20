# falter-firmware-builder
This script sets up a falter-build-system in a half automated manner. You can use this parameters:

```
Falter-build-script v0.0.6
To build falter-images, execute the options in this order.

-i | --init     initialise buildsystem
-s | --select   select the target, falter will be built for
-w | --write [FILE]     write the package-selection to buildsystem
-m | --make     start building

optional:
-u | --update           updates with new patches from falter-repo.
                        After using this option, you need to start
                        again at option -s.
-b | --branch [BRANCH]  if you want to build falter on a different
                        OpenWrt-branch than master, give the branch
                        or tag. After executing this option start
                        again at -s.

EVER use only one option at the same time!
```
The buildsystem will reside in a subdirectory `falter-firmware/`. This is adjustible in the header
of the script.

You may provide your own diffconfig for OpenWrt in the file `diff_config_freifunk`. Thus you can
control, which packages will be included into the images.


## Tutorial: Build a stable release
First clone this repo, then initialise the build system:
```
git clone https://github.com/Akira25/falter-firmware-builder.git
cd falter-firmware-builder
./falter.sh -i
```
Then, checkout the stable OpenWrt-release via the `-b` option. This will perform some additional
cleaning actions in the build-system.
```
./falter.sh -b v19.07.4
```

Select target and routers, images should be generated for. Standard is, to build the whole target ath79. You may add costum packages and build options in this step.
```
./falter.sh -s
```

Write the image-type's diffconfig to the buildsystem. There are diffconfigs for each of traditional Freifunk Berlin image-types.
```
./falter.sh -w falter_19.07.4/falter_19.07.4_tunneldigger
```
Finally start building by `./falter.sh -m`. The script will start the build process with CPU_CORES+1 threads and the option V=sc.