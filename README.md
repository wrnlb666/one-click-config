# one-click-config
My config installation script with one click

## Caution
All the config files are intended for my personal use. Backup your old config files so that there is a return.


## Installation
```sh
# target can be any directory with `rwx` permission
target=~/wrnlb/config
[[ -d "${target}" ]] || mkdir -p "${target}"
command cd "${target}"
git clone git@github.com:wrnlb666/one-click-config.git occ
command cd occ
./occ install occ
```
## Install with https
```sh
# target can be any directory with `rwx` permission
target=~/wrnlb/config
[[ -d "${target}" ]] || mkdir -p "${target}"
command cd "${target}"
git clone https://github.com/wrnlb666/one-click-config.git occ
command cd occ
./occ install occ
```
