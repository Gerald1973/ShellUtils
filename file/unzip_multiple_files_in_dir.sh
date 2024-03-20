#!/bin/bash

unzip_to_dir() {
    if [[ $# != 1 ]]
    then 
      echo I need a single argument, the name of the archive to extract
      return 1 
    fi
    target="${1%.zip}"
    echo "Target repository: ${target}"
    unzip "$1" -d "${target##*/}"
}

shopt -s dotglob nullglob

files=(*)
for file in "${files[@]}"; do
  echo "File name: ${file}"
  unzip_to_dir "${file}" 
done



# if [[ $# != 1 ]]
# then 
#   echo I need a single argument, the name of the archive to extract 
# else
#  target="${1%.zip}"
#  unzip "${1}" -d "${target##*/}"
# fi
