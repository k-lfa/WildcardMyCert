#!/bin/bash

if [ -z "$1" ]; then
  echo "Erreur : Aucun argument fourni."
  exit 1
fi

current_dir="$(dirname "$(realpath "$0")")"
docker compose up
mv certs/live/$1 /etc/letsencrypt/live # Change dest parh if you need
systemctl restart apache2