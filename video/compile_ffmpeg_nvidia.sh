#!/bin/bash
NVIDIA_DIR="${HOME}/tmp/nvidia_ffmpeg"
rm -rfv ${NVIDIA_DIR}
echo "Install missing packages"
echo "========================"
sudo apt-get update -qq && sudo apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libgnutls28-dev \
  libmp3lame-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  meson \
  ninja-build \
  pkg-config \
  texinfo \
  wget \
  yasm \
  zlib1g-dev
sudo apt remove ffmpeg
mkdir -p ${NVIDIA_DIR}
cd ${NVIDIA_DIR}
echo "NVidia codec coder compilation (nvcc)"
echo "====================================="
git clone https://github.com/FFmpeg/nv-codec-headers.git
cd nv-codec-headers
make
sudo make install
cd ${NVIDIA_DIR}
echo "ffmpeg compilation"
echo "=================="
git clone https://github.com/FFmpeg/FFmpeg.git
sudo apt install build-essential yasm cmake libtool libc6 libc6-dev unzip wget libnuma1 libnuma-dev
cd ${NVIDIA_DIR}/FFmpeg
git checkout n7.1.1
./configure --enable-nonfree \
  --enable-gpl \
  --enable-nonfree \
  --enable-cuda-nvcc \
  --enable-libnpp \
  --enable-nvenc \
  --enable-nvdec \
  --enable-libass \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libfdk-aac \
  --enable-libopus \
  --enable-libvorbis \
  --enable-libass \
  --enable-libfreetype \
  --extra-cflags=-I/usr/local/cuda-12.8/include \
  --extra-ldflags=-L/usr/local/cuda-12.8/lib64
make -j $(nproc)
ls -l ffmpeg
./ffmpeg
sudo make install
echo "Verification"
ls -l /usr/local/bin/ffmpeg
type -a ffmpeg
more <<EndOfMore
Add /usr/local/bin/ to $PATH using the export command (see adding path permanently on Linux with bash for more info):
    echo "$PATH"
    export PATH=$PATH:/usr/local/bin
    echo "$PATH"
You can now use -hwaccel cuda switch for encoding. For instance:
    ffmpeg -y -hwaccel cuda -i input.file output.file
    /usr/local/bin/ffmpeg -y -hwaccel cuda -i input.file output.file
EndOFMore


