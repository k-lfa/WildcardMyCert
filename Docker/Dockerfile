# Utiliser l'image de base Python pour exécuter Certbot
FROM python:3.10-slim

# Installer Certbot et le plugin OVH
RUN pip install certbot certbot-dns-ovh

# Copier le fichier ovh.ini pour l'authentification API
COPY ./app/.ovh.ini /root/.ovh.ini

# Assurer des permissions sécurisées pour le fichier d'identifiants
RUN chmod 600 /root/.ovh.ini

# Point d'entrée par défaut de l'image
ENTRYPOINT ["certbot"]
