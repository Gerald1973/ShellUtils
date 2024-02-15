#!/bin/bash
cat << DESCRIPTION
This scripts will modify the add or remove the permissions to the given path
example:
${0} /mydir/dir g+rwx,u+rwx g+rw,u+rw
DESCRIPTION
#Test the number of parameter
if [[ ${#} != 3 ]]; then
  echo "Incorrect number of arguments"
  echo "valid example ${0} /mydir/dir g+rwx,u+rwx g+rw,u+rw"
  exit 1
fi
read -p "Do you wish change the permission(s) on the directory ${1} with the permission ${2} and all of its files and subdirectories (Y/N) ?" yn
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