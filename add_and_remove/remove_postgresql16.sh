#!/bin/bash

# Vérifier si l'utilisateur est root
if [ "$(id -u)" != "0" ]; then
   echo "Ce script doit être exécuté en tant que root" 1>&2
   exit 1
fi

# Arrêter le service PostgreSQL
systemctl stop postgresql

# Désactiver le service
systemctl disable postgresql

# Supprimer les paquets PostgreSQL
apt-get purge -y postgresql-16 postgresql-client-16 postgresql-common postgresql-client-common

# Supprimer les dépendances inutilisées
apt-get autoremove -y

# Supprimer les fichiers de configuration résiduels
rm -rf /etc/postgresql/16
rm -rf /etc/postgresql-common

# Supprimer les fichiers de données
rm -rf /var/lib/postgresql/16

# Supprimer les logs
rm -rf /var/log/postgresql

# Nettoyer le cache APT
apt-get clean

echo "PostgreSQL 16 a été complètement désinstallé."