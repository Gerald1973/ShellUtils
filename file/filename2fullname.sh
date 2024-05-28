#!/bin/bash
cat <<HEREDOC
This script finds all files in the current working directory, replaces / with §
in their paths, removes the first character, and then copies each file to a new
file with the modified path as its name. Note that this script may fail if the
modified filenames conflict with existing filenames. Also, this script does not
create the necessary directories for the new files, so if the directories do not
already exist, the cp command will fail. Be careful when running this script as 
it can modify your file system. Always make sure to have a backup of your files 
before running scripts that modify them.
HEREDOC
fichiers=($(find "$PWD" -type f))
for fichier in "${fichiers[@]}"
do
    echo ${fichier}
    tmp=${fichier//\//§}
    result=${tmp:1}
    echo ${result}
    cp ${fichier} ${result}
done