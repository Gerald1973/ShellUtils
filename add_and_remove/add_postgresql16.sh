#!/bin/bash

# Vérifier si l'utilisateur est root
if [ "$(id -u)" != "0" ]; then
   echo "Ce script doit être exécuté en tant que root" 1>&2
   exit 1
fi

# Mettre à jour la liste des paquets
echo "Mise à jour des paquets..."
apt-get update

# Installer les prérequis
echo "Installation des prérequis..."
apt-get install -y gnupg2 wget

# Ajouter le dépôt PostgreSQL
echo "Ajout du dépôt PostgreSQL..."
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Mettre à jour à nouveau après l'ajout du dépôt
apt-get update

# Installer PostgreSQL 16
echo "Installation de PostgreSQL 16..."
apt-get install -y postgresql-16 postgresql-client-16

# Vérifier que le service est démarré
echo "Démarrage du service PostgreSQL..."
systemctl start postgresql

# Activer le service au démarrage
systemctl enable postgresql

# Vérifier le statut du service
echo "Vérification du statut de PostgreSQL..."
systemctl status postgresql --no-pager

# Afficher la version installée
echo "Version de PostgreSQL installée :"
su - postgres -c "psql --version"

echo "Installation de PostgreSQL 16 terminée avec succès !"
echo "Pour configurer, connectez-vous avec : su - postgres"
echo "Puis utilisez la commande : psql"