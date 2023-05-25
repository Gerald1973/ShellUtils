#!/bin/bash
shopt -s dotglob
shopt -s nullglob
GIT_REPOSITORY=~/git
cd ${GIT_REPOSITORY}
echo $(pwd)
directories=(*/)
echo ${directories}
for directory in "${directories[@]}"; do 
 cd ${directory}
 echo "Directory : ${directory}"
 git status
 cd ${GIT_REPOSITORY}
done