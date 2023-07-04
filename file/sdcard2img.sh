#!/bin/bash
lsblk
read -p "Enter the source device e.g. /dev/sda1 :" DEV_SRC
read -p "Enter the target device e.g. /home/myname/myimage.img :" FIL_TGT
sudo umount ${DEV_SRC} || { echo "umount failed but not to worry" ; : ; } 
sudo dd if="${DEV_SRC}" of="${FIL_TGT}" bs=1MB status=progress &&
sudo chmod 666 ${FIL_TGT} &&
while true; do
    read -p "Do you wish to compress this image ? " yn
    case $yn in
        [Yy]* ) 
            directory=$(dirname ${FIL_TGT}) ;
            filename=$(basename -- "${FIL_TGT}")
            cd ${directory}
            tar cvfz "${filename}.tar" "${filename}"; 
            break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done