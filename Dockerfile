FROM python:alpine

# Paquets système à jour (correctifs de sécurité Alpine)
RUN apk upgrade --no-cache

# Base de fuseaux horaires : permet d'utiliser TZ (ex. Europe/Paris) avec le mode cron
RUN apk add --no-cache tzdata

# pip et Instaloader : dernière version disponible au moment du build
# (le build doit se faire avec --pull --no-cache pour ne pas réutiliser une couche en cache)
RUN pip install --no-cache-dir --upgrade pip instaloader

# Dossier de travail
RUN mkdir /download
WORKDIR /download

# Scripts de lancement
COPY run_instaloader.sh run_job.sh entrypoint.sh /
RUN chmod +x /run_instaloader.sh /run_job.sh /entrypoint.sh

# Sans CRON_SCHEDULE : une exécution puis arrêt. Avec : crond reste actif (voir README)
CMD ["/entrypoint.sh"]
