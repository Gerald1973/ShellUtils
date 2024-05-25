#!/bin/bash
cat <<HEREDOC
This Bash script renames files in a specified directory by adding a prefix and 
converting the original filename, which is a timestamp, into a formatted date 
string.
The new filename consists of the prefix, the formatted date, and the original 
file extension.

Usage:
======

This script is run from the command line with two arguments: the directory path
and the prefix. For example:

./epoch2name.sh prefix_ /path/to/directory
HEREDOC
prefixe="${1}"
path="${2}"
files=($(ls -A1 ${path}))
for element in "${files[@]}"
do
  if  [[ -f "${path}/${element}" ]] then
    base_name="${element%.*}"
    extension="${element##*.}"
    milli_second="${base_name: -3}"
    datte_str=$(date -d @${base_name::-3} '+%Y%m%d_%H%M')
    full_file_name="${path}/${prefixe}${datte_str}_${milli_second}.${extension}"
    echo "Rename ${path}/${element} to ${full_file_name}"
    mv "${path}/${element}" ${full_file_name}
  fi
done
