#!/bin/bash
SRC_DIR="${HOME}/git/vice/vice"
sudo apt -y install autoconf
sudo apt -y install automake
sudo apt -y install build-essential      # (contains gcc, make)
sudo apt -y install byacc
sudo apt -y install flex
sudo apt -y install xa65                 # needed to build the vsid driver
sudo apt -y install gawk                 # or mawk
sudo apt -y install libgtk-3-dev
sudo apt -y install texinfo
sudo apt -y install texlive-fonts-recommended
sudo apt -y install texlive-latex-extra  # needed for the VICE logo in the pdf
sudo apt -y install dos2unix             # only used when doing `make dist`
sudo apt -y install libpulse-dev         # for Pulse Audio sound support
sudo apt -y install libasound2-dev       # for ALSA sound support
sudo apt -y install libglew-dev          # for OpenGL hardware scaling support
sudo apt -y install libcurl4-openssl-dev # for WiC64, >= 7.71.0 is required
sudo apt -y install libgif-dev       # GIF screenshot support
sudo apt -y install libpcap-dev      # Ethernet support
sudo apt -y install libsdl2-dev
sudo apt -y install libsdl2-image-dev
sudo apt -y install libavcodec-dev     # for video capturing support
sudo apy -y install libavformat-dev
sudo apt -y install libswscale-dev
sudo apt -y install libmp3lame-dev     # required for MP3 encoding
sudo apt -y install libmpg123-dev      # required for MP3 decoding (and for
                                        # mp3@64 cartridge support)
sudo apt -y install libvorbis-dev      # Ogg/Vorbis support
sudo apt -y install libflac-dev        # FLAC support

cd ${SRC_DIR}
echo "Now Iam in the " $(pwd) "directory"
make clean
./autogen.sh
./configure --enable-arch=native \
    --with-resid \
    --enable-sdl2ui \
    --enable-ethernet \
    --with-pulse
make -j2
./src/x64sc
