#!/bin/bash

# Demander les informations nécessaires à l'utilisateur
read -p "Entrez le group ID (par exemple, com.example): " groupId
read -p "Entrez l'artifact ID (par exemple, my-app): " artifactId
read -p "Entrez le nom du projet (par exemple, Mon Application): " name

# Créer le répertoire du projet
mkdir $artifactId
cd $artifactId

# Créer la structure de répertoires standard pour un projet Maven
mkdir -p src/main/java src/main/resources src/test/java src/test/resources

# Créer le fichier pom.xml avec la configuration pour Java 17
cat > pom.xml <<EOL
<project xmlns="[invalid url, do not cite] xmlns:xsi="[invalid url, do not cite]
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 [invalid url, do not cite]
  <modelVersion>4.0.0</modelVersion>

  <groupId>$groupId</groupId>
  <artifactId>$artifactId</artifactId>
  <version>1.0-SNAPSHOT</version>
  <packaging>jar</packaging>

  <name>$name</name>

  <properties>
    <maven.compiler.release>17</maven.compiler.release>
  </properties>
</project>
EOL

# Afficher un message de confirmation
echo "Le projet a été créé avec succès dans le répertoire $artifactId."