import os
import sys

# List directories alfa


class DirectoryClassifier:
    __rootPath: str

    def __init__(self, rootPath: str) -> None:
        self.__rootPath = rootPath
        pass

    def ls(self) -> list[os.DirEntry]:
        def getFieldToSort(dirEntry: os.DirEntry):
            return dirEntry.path

        results: list[os.DirEntry] = []
        tmps = os.scandir(self.__rootPath)
        for element in tmps:
            if element.is_dir():
                print(f"Element path: {element.path} Element name: {element.name}")
                results.append(element)
            pass
        results.sort(key=getFieldToSort)
        print(f"Number of subdirectories: {len(results)}")
        return results

    def divideList(self, number: int) -> dict[str, list[os.DirEntry]]:
        results: dict[str, list[os.DirEntry]] = {}
        listOfSubDirectories = self.ls()
        mapValues = [
            listOfSubDirectories[x : x + number]
            for x in range(0, len(listOfSubDirectories), number)
        ]
        for tmps in mapValues:
            mapKey = f"{tmps[0].name[0:14]}_{tmps[len(tmps)-1].name[0:15]}"
            results[mapKey] = tmps
        return results

    def createSubDir(self, subDirByDir: int):
        dictionary = self.divideList(subDirByDir)
        subdirNames = list(dictionary.keys())
        for subDirName in subdirNames:
            target = f"{self.__rootPath}/{subDirName}"
            if not os.path.exists(target):
                os.mkdir(target)
                print(f"Directory {target} created.")
            srcs = dictionary[subDirName]
            for src in srcs:
                fullTarget=f"{target}/{src.name}"
                if not os.path.exists(fullTarget):
                    print(f"Rename {src.path} to {fullTarget}")
                    os.rename(src,fullTarget)
        pass


if len(sys.argv) != 3:
    print ("DirectoryClassifier <directory_root> <max_number_of_subdir>")
else:
    print(f"Directory to divide : {sys.argv[1].strip()}")
    print(f"Max number of sub directories : {sys.argv[2].strip()}")
    rootPath = sys.argv[1].strip()
    maxNumberofSubDir=int(sys.argv[2].strip())
    directoryClassifier: DirectoryClassifier = DirectoryClassifier(rootPath)
    directoryClassifier.createSubDir(maxNumberofSubDir)
