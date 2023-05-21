#!/bin/bash -v
NVIDIA_DIR="${HOME}/tmp/nvidia_ffmpeg"
sudo apt install nvidia-cuda-toolkit
sudo apt remove ffmpeg
mkdir -p ${NVIDIA_DIR}
cd ${NVIDIA_DIR}
echo "NVidia codec coder compilation (nvcc)"
echo "====================================="
git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
cd nv-codec-headers
sudo make install
cd ${NVIDIA_DIR}
echo "ffmpeg compilation"
echo "=================="
git clone https://git.ffmpeg.org/ffmpeg.git
sudo apt install build-essential yasm cmake libtool libc6 libc6-dev unzip wget libnuma1 libnuma-dev
cd ${NVIDIA_DIR}/ffmpeg
./configure --enable-nonfree --enable-cuda-nvcc --enable-libnpp --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64
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


