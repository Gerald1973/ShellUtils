#!/bin/bash
for letter in {a..z}
do
    echo ${letter}
    mkdir ${letter}
done
for letter in {a..z}
do
    find ./${letter^}* -maxdepth 0 -type f -exec mv -v {} ${letter} \;
    find ./${letter}*  -maxdepth 0 -type f -exec mv -v {} ${letter} \;
done
for number in {0..9}
do
     mkdir ${number}
done
for number in {0..9}
do
    find ./${number}* -maxdepth 0 -type f -exec mv -v {} ${number} \;
done
mkdir '#'
find ./*  -maxdepth 0 -type f -exec mv -v {} '#' \;
