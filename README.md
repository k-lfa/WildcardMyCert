
# WildcardMyCert

**WildcardMyCert** est un outil conçu pour automatiser la génération de certificats wildcard, évitant l'apparition de vos sous-domaines dans les logs de transparence des certificats (CT logs).
L'émission d'un certificat wildcard avec Let's Encrypt nécessite habituellement une intervention manuelle pour ajouter un enregistrement TXT contenant le challenge de validation. **WildcardMyCert** simplifie ce processus en intégrant automatiquement le challenge dans votre DNS, et rend le renouvellement trimestriel de vos certificats totalement automatisé.

## Prérequis

Cet outil est configuré pour fonctionner avec l'API d'OVH, mais peut être adapté pour d'autres fournisseurs compatibles avec certbot ou acme. Retrouvez la liste complète des fournisseurs supportés ici : [Certbot DNS Providers](https://github.com/acmesh-official/acme.sh/wiki/dnsapi).

### Préparation

Avant de générer un certificat, créez un token d'API auprès d'OVH :  
- Accédez à : [Création de Token API OVH](https://www.ovh.com/auth/api/createToken)

**Permissions API nécessaires** :
```
GET /domain/zone/
GET /domain/zone/{domain.name}/
GET /domain/zone/{domain.ext}/status
GET /domain/zone/{domain.ext}/record
GET /domain/zone/{domain.ext}/record/*
POST /domain/zone/{domain.ext}/record
POST /domain/zone/{domain.ext}/refresh
DELETE /domain/zone/{domain.ext}/record/*
```

**Autoriser votre compte à utiliser l'API** : [Console OVH API](https://eu.api.ovh.com/console/?section=%2Fme&branch=v1#get-/me)

## Utilisation sans Docker

> **Note** : Générez et configurez le token de votre fournisseur DNS avant de continuer (voir la section OVH ci-dessus).

1. **Configurer vos tokens** :
   ```bash
   nano .ovh.ini
   # Ajoutez les tokens générés précédemment
   ```

2. **Installer les dépendances** :
   ```bash
   cd App
   bash install.sh
   ```

3. **Lancer la génération de certificat** :
   ```bash
   chmod 600 .ovh.ini
   # Changer la variable $domain dans la commande
   certbot certonly --dns-ovh --dns-ovh-credentials .ovh.ini -d *.$domain --non-interactive --agree-tos --register-unsafely-without-email
   ```

4. **Configurer le renouvellement automatique** :
   Ajoutez la tâche suivante à votre crontab pour renouveler automatiquement le certificat tous les 2 mois :
   ```cron
   0 0 2 * * /usr/local/bin/certbot renew --quiet --dns-ovh-credentials /etc/letsencrypt/ovh.ini --dns-ovh --deploy-hook "systemctl reload nginx"
   ```

## Utilisation avec Docker

> **Note** : Générez et configurez le token de votre fournisseur DNS avant de continuer (voir la section OVH ci-dessus).

1. **Configurer vos tokens** :
   ```bash
   nano .ovh.ini
   # Ajoutez les tokens générés précédemment
   ```

2. **configurer & déployer le conteneur** :
   ```bash
   cd Docker
   # Changer la variable $domain dans docker-compose.yml
   docker compose up
   ```

3. **Récupérer les certificats et redémarrer le service web** :
   ```bash
   mv certs/live/$domain /etc/letsencrypt/live
   systemctl restart apache2
   ```

4. **Configurer le renouvellement automatique** :
   Ajoutez la tâche suivante à votre crontab pour renouveler automatiquement le certificat tous les 2 mois (changer la variable domain)
   ```cron
   0 0 2 * * /root/WildcardMyCert/Docker/renew-cert.sh $mydomain
   ```
> **Remarque** : Le script renew-cert.sh renouvel les certificats, remplace les anciens et redémarre le service web. Adapter le chemin de certificat du script selon votre configuration  

## Architecture recommandée

**WildcardMyCert** peut être utilisé selon deux modèles d'architecture :

### Sur le serveur web (non recommandé)
Cette configuration expose le token de gestion DNS sur le serveur web, ce qui peut poser des risques de sécurité.

### Sur un serveur de management dédié (recommandé)
- **Génération des certificats** de manière centralisée.
- **Transfert des certificats** vers les serveurs web.
- **Redémarrage des services web à distance** pour appliquer les nouveaux certificats.

> **Remarque** : Assurez-vous de configurer l'authentification SSH par clé entre le serveur de management et les serveurs web.
