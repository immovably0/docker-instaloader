FROM python:3.12-alpine

# Dépendances système
RUN apk add --no-cache \
    bash \
    chromium \
    chromium-chromedriver \
    sqlite \
    libstdc++

# Python
RUN pip install --upgrade pip

# Instaloader + gestion cookies navigateur
RUN pip install \
    instaloader==4.15.1 \
    browser-cookie3

# Dossier de travail
RUN mkdir /download
WORKDIR /download

# Script de lancement
ADD run_instaloader.sh /run_instaloader.sh
RUN chmod +x /run_instaloader.sh

# Variables optionnelles
ENV BROWSER=chrome

CMD /run_instaloader.sh /il_args.txt /il_targets.txt
