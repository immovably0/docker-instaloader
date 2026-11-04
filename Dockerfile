FROM python:alpine

# Paquets système à jour (correctifs de sécurité Alpine)
RUN apk upgrade --no-cache

# pip et Instaloader : dernière version disponible au moment du build
# (le build doit se faire avec --pull --no-cache pour ne pas réutiliser une couche en cache)
RUN pip install --no-cache-dir --upgrade pip instaloader


# Dossier de travail
RUN mkdir /download
WORKDIR /download

# Script de lancement
ADD run_instaloader.sh /run_instaloader.sh
RUN chmod +x /run_instaloader.sh

CMD /run_instaloader.sh /il_args.txt /il_targets.txt
