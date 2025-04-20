#!/bin/bash
SRC_DIR="${HOME}/git/opencubicplayer/"
UNIFONT_OTF_PATH="/usr/share/fonts/opentype/unifont"
cd ${SRC_DIR}
sudo apt install unifont
sudo apt install libncurses6
sudo apt install libncurses-dev
sudo apt install libbz2-dev
sudo apt install libdiscid0
sudo apt install libdiscid-dev
sudo apt install libcjson1 libcjson-dev
sudo apt install libancient2 libancient-dev
sudo apt install libmad0-dev
git checkout v3.0.1
git submodule update --init --recursive
#/usr/share/fonts/opentype
#unifont_csur.otf  unifont_jp.otf  unifont.otf  unifont_upper.otf
make uninstall
make clean
./configure  --with-unifont-csur-otf=${UNIFONT_OTF_PATH}/unifont_csur.otf \
    --with-unifont-otf=${UNIFONT_OTF_PATH}/unifont.otf \
    --with-unifont-upper-otf=${UNIFONT_OTF_PATH}/unifont_upper.otf \
    --without-unifont-csur-ttf
make all
sudo make install
