#!/bin/bash
VERSION=${1}
echo "Switching to version ${VERSION}"
case ${VERSION} in
    8) 
        ln -vfns ~/programmation/tools/java/jdk8u392-b08 ~/programmation/tools/java/java
        ;;
    11)
        ln -vfns ~/programmation/tools/java/jdk-11.0.28+6 ~/programmation/tools/java/java
        ;;
    17)
        ln -vfns ~/programmation/tools/java/jdk-17.0.9+9 ~/programmation/tools/java/java
        ;;
    21)
	    ln -vfns ~/programmation/tools/java/jdk-21.0.9+10 ~/programmation/tools/java/java
        ;;
    *) 
        echo "Version ${1} unknown on this system."
        echo "usage: ${0} version"
        echo "Example:"
        echo "${0} 8"
        echo "To switch to Java 1.8"
        ;;
esac
echo "The current used version of Java is:"
java -version
