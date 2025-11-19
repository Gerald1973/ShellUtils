#!/bin/bash

# Variables pour le projet
GROUP_ID="com.smilesmile1973"
ARTIFACT_ID="AuthenticatorOauth2"
VERSION="1.0-SNAPSHOT"
JAVA_VERSION="17"
PACKAGE_PATH=$(echo $GROUP_ID | tr '.' '/')

# Création des répertoires
echo "Création de la structure du projet Maven..."
mkdir -p $ARTIFACT_ID/src/main/java/$PACKAGE_PATH
mkdir -p $ARTIFACT_ID/src/main/resources
mkdir -p $ARTIFACT_ID/src/test/java/$PACKAGE_PATH
mkdir -p $ARTIFACT_ID/src/test/resources

# Création du fichier pom.xml
echo "Création du fichier pom.xml..."
cat <<EOL > $ARTIFACT_ID/pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>$GROUP_ID</groupId>
    <artifactId>$ARTIFACT_ID</artifactId>
    <version>$VERSION</version>

    <properties>
        <maven.compiler.source>$JAVA_VERSION</maven.compiler.source>
        <maven.compiler.target>$JAVA_VERSION</maven.compiler.target>
    </properties>

</project>
EOL

# Création d'une classe Java principale
echo "Création d'une classe Java principale..."
cat <<EOL > $ARTIFACT_ID/src/main/java/$PACKAGE_PATH/App.java
package $GROUP_ID;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello, Maven!");
    }
}
EOL

# Affichage de la structure créée
echo "Structure du projet créée :"
tree $ARTIFACT_ID || find $ARTIFACT_ID  # Utilise tree si disponible, sinon find

echo "Projet Maven créé avec succès !"
echo "Pour compiler et exécuter :"
echo "  cd $ARTIFACT_ID"
echo "  mvn clean install"
echo "  mvn exec:java -Dexec.mainClass=\"$GROUP_ID.App\""
