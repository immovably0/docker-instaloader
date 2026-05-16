FROM python:alpine

# Python
RUN pip install --upgrade pip

# Instaloader
RUN pip install \
    instaloader==4.15.1 
    
# Dossier de travail
RUN mkdir /download
WORKDIR /download

# Script de lancement
ADD run_instaloader.sh /run_instaloader.sh
RUN chmod +x /run_instaloader.sh

CMD /run_instaloader.sh /il_args.txt /il_targets.txt
