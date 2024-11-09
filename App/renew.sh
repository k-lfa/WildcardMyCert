#!/bin/bash
certbot certonly --dns-ovh --dns-ovh-credentials /etc/letsencrypt/ovh.ini -d *.$domain

# cron (tout les 2 mois)
#0 0 2 * * /usr/local/bin/certbot renew --quiet --dns-ovh-credentials /etc/letsencrypt/ovh.ini --dns-ovh --deploy-hook "systemctl reload nginx"
