#!/bin/bash
#23456789+123456789+123456789+123456789+123456789+123456789+12345679+1234567989+
cat <<EO_HERE_DOC
Script for Backing Up Git Repositories

This script provides a way to easily back up a Git repository by creating a
compressed archive.

How it works:

The script performs a clone of the specified repository into a temporary 
directory. This creates a complete copy of the repository's history and files.

Example:

Bash
./backup_git_repository.sh https://url.git mydirectory

This command will:

Clone the repository located at https://url.git

Create a compressed archive (ZIP file) named mydirectory.zip containing the 
cloned repository.
Important: Delete the temporary directory where the repository was cloned 
(mydirectory in this example).

Important Note:

This script creates a backup of the entire repository, including all branches, 
tags, and commit history.
The script deletes the temporary directory used for cloning after creating the
archive.
EO_HERE_DOC

#git clone https://<PAT>@github.com/username/repo.git
#git clone https://username:password@github.com/username/repository.git
if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
else
    echo "Repository mirroring ongoing..."
    git clone --verbose --mirror ${1} ${2}
    echo "Compressing repository ongoing..."
    zip -r ${2}.zip ${2}
    echo "Removing directory"
    # Demander confirmation à l'utilisateur
    read -p "Do you want to remove the directory ${2} (Y/N) ?" response
    case ${response} in
        [Yy]* ) 
            rm -rfv ${2};
            ;;
        [Nn]* ) 
            ;;
        * ) echo "Please answer y or n.";;
    esac
fi
