FROM python:alpine

# Paquets système à jour (correctifs de sécurité Alpine)
RUN apk upgrade --no-cache

# Base de fuseaux horaires : permet d'utiliser TZ (ex. Europe/Paris) avec le mode cron
RUN apk add --no-cache tzdata

# pip, Instaloader et browser_cookie3 : dernières versions disponibles au moment du build
# (le build doit se faire avec --pull --no-cache pour ne pas réutiliser une couche en cache).
# browser_cookie3 n'est pas installé avec Instaloader mais il est requis par --load-cookies.
# Sa dépendance lz4 n'a pas de wheel pour Alpine (musl) : elle est compilée avec des
# outils de build temporaires, supprimés dans la même couche.
RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && pip install --no-cache-dir --upgrade pip instaloader browser_cookie3 \
    && apk del .build-deps

# Dossier de travail
RUN mkdir /download
WORKDIR /download

# Scripts de lancement
COPY run_instaloader.sh run_job.sh entrypoint.sh /
RUN chmod +x /run_instaloader.sh /run_job.sh /entrypoint.sh

# Sans CRON_SCHEDULE : une exécution puis arrêt. Avec : crond reste actif (voir README)
CMD ["/entrypoint.sh"]
