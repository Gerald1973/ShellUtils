#!/bin/bash
#Test the number of parameter
if [[ ${#} != 3 ]]; then
cat <<-DESCRIPTION
This script modifies file permissions (read, write, execute) for a specified path and its contained files.
Example:
${0} /mydir/dir g+rwx,u+rwx g+rw,u+rw

${0}: Represents the script's name.

Directory part:
===============

g+rwx: Adds read, write, and execute permissions for the group.
u+rwx: Adds read, write, and execute permissions for the owner.

File part:
==========

g+rw: Adds read and write permissions for the group.
u+rw: Adds read and write permissions for the owner.

DESCRIPTION
  echo "Incorrect number of arguments"
  echo "valid example ${0} /mydir/dir g+rwx,u+rwx g+rw,u+rw"
  exit 1
fi
read -p "Do you want to change the permissions on the directory ${1} with the permissions ${2} and all of its files and subdirectories (Y/N)?" yn
echo ${yn}
echo ${1}
echo ${2}
echo ${3}
case $yn in
    [Yy]* ) 
        echo "Yes!!!!"
        find "${1}" -type d -exec chmod -Rv "${2}" {} \;
        find "${1}" -type f -exec chmod -Rv "${3}" {} \;
        ;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
esac