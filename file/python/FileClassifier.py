import os
import sys

# List directories alfa


class FileClassifier:
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
            if element.is_file():
                results.append(element)
            pass
        results.sort(key=getFieldToSort)
        print(f"Number of files: {len(results)}")
        return results

    def divideList(self, number: int) -> dict[str, list[os.DirEntry]]:
        results: dict[str, list[os.DirEntry]] = {}
        listOfFiles = self.ls()
        mapValues = [
            listOfFiles[x : x + number] for x in range(0, len(listOfFiles), number)
        ]
        c:int = 0
        for tmps in mapValues:
            fileNameFrom: str = tmps[0].name
            extension: str = fileNameFrom.split(".")[-1]
            fileNameFrom = fileNameFrom.replace(f".{extension}", "")
            fileNameFrom = fileNameFrom[0:12]

            fileNameTo: str = tmps[len(tmps) - 1].name
            extension: str = fileNameTo.split(".")[-1]
            fileNameTo = fileNameTo.replace(f".{extension}", "")
            fileNameTo = fileNameTo[0:12]
            mapKey = f"{fileNameFrom}_{fileNameTo}"
            if mapKey in results:
                suffixe=str(c).zfill(2)
                mapKey = f"{fileNameFrom}{suffixe}_{fileNameTo}{suffixe}"
                c = c + 1
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
                fullTarget = f"{target}/{src.name}"
                if not os.path.exists(fullTarget):
                    #print(f"Rename {src.path} to {fullTarget}")
                    os.rename(src,fullTarget)
        pass


if len(sys.argv) != 3:
    print("FileClassifier <directory_root> <max_number_of_files>")
else:
    print(f"Directory to divide           : {sys.argv[1].strip()}")
    print(f"Max number of sub directories : {sys.argv[2].strip()}")
    rootPath = sys.argv[1].strip()
    maxNumberOfFiles = int(sys.argv[2].strip())
    directoryClassifier: FileClassifier = FileClassifier(rootPath)
    directoryClassifier.createSubDir(maxNumberOfFiles)


