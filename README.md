# one-click-config
My config installation script with one click

## Caution
All the config files are intended for my personal use. Backup your old config files so that there is a return.


## Installation
```sh
[[ -d ~/wrnlb/config ]] || mkdir -p ~/wrnlb/config
command cd ~/wrnlb/config
git clone git@github.com:wrnlb666/one-click-config.git occ
command cd occ
./occ install occ
```
## Install with https
```sh
[[ -d ~/wrnlb/config ]] || mkdir -p ~/wrnlb/config
command cd ~/wrnlb/config
git clone https://github.com/wrnlb666/one-click-config.git occ
command cd occ
./occ install occ
```
