This script sets up a falter-build-system in a half automated manner. You can use this parameters:

```
Falter-build-script v0.0.5
To build falter-images, execute the options in this order.

-i | --init     initialise buildsystem
-s | --select   select the target, falter will be built for
-w | --write    write the package-selection to buildsystem
-m | --make     start building

optional:
-u | --update           updates with new patches from falter-repo.
                        After using this option, you need to start
                        again at option -s.
-b | --branch [$BRANCH] if you want to build falter on a different
                        OpenWrt-branch than master, give the branch
                        or tag. After executing this option start
                        again at -s.

EVER use only one option at the same time!
```
The buildsystem will reside in a subdirectory `falter-firmware/`. This is adjustible in the header
of the script.

You may provide your own diffconfig for OpenWrt in the file `diff_config_freifunk`. Thus you can
control, which packages will be included into the images.
