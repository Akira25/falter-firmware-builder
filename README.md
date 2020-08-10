This script sets up a falter-build-system in a half automated manner. You can use this parameters:

```
To build falter-images, execute the options in this order.

-i | --init     initialise buildsystem
-s | --select   select the target, falter will be built for
-w | --write    write the package-selection to buildsystem
-m | --make     start building

optional:
-u | --update   updates with new patches from falter-repo.
                After using this option, you need to start
                again at option -s.

EVER use only one option at the same time!
```
The buildsystem will reside in a subdirectory `falter-firmware/`. This is adjustible in the header
of the script.