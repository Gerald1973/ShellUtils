#!/bin/bash



current_dir=$(pwd)
root_dir=${1}
cd ${root_dir}

#Find directories
TMP_IFS=${IFS}
IFS=$'\n'
dirs=($(find . -maxdepth 1 -type d ))
IFS=$TMP_IFS

echo "Number of directories: ${#dirs[@]}"
for dir in "${dirs[@]}"; do
  cd "${root_dir}/${dir}"
  pwd
  #Find files
  IFS=$'\n'
  lha_files=($(find *.lha  -maxdepth 1 -type f))
  IFS=$OLDIFS

  echo "Number of lha files: ${#lha_files[@]}"
  for lha_file in "${lha_files[@]}"; do
    lha -xvf "${lha_file}"
    rm -v "${lha_file}"
  done

done
IFS=${TMP_IFS}

cd ${current_dir}