import os
import sys

class RemoveSpecialChars:

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
        return results
    
    def toCamelCase(self,string:str)->str:

        pass

    def go(self):
        listOffiles:list[os.DirEntry] = self.ls()
        numberOfFiles = len(listOffiles)
        if numberOfFiles > 0:
            for fileEntry in listOffiles:
                fullFileName:str = fileEntry.path
                fileNameWithExtension=fullFileName.split('/')[-1]
                onlyPath: str = fullFileName.replace(fileNameWithExtension,"")
                fileExtension = fileNameWithExtension.split('.')[-1]
                fileNameWithoutExtension:str = fileNameWithExtension.replace(f".{fileExtension}","").strip();
                if not fileNameWithoutExtension.isalnum():
                    fileNameWithoutSpecChar = ''.join(letter for letter in fileNameWithoutExtension.title() if letter.isalnum())
                    renamedFile:str = f"{onlyPath}{fileNameWithoutSpecChar}.{fileExtension}"
                    os.rename(fullFileName,renamedFile)
                    print (f"Rename ==> {fullFileName} to ==> {renamedFile}")
        else:
            print("No file.")
    
if len(sys.argv) != 2:
    print ("RemoveSpecialChars <directory_root>")
else:
    rootPath = sys.argv[1].strip()
    removeSpecialChars: RemoveSpecialChars = RemoveSpecialChars(rootPath)
    removeSpecialChars.go()
