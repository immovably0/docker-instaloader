#!/bin/sh
# Une exécution d'Instaloader, sans chevauchement : si la précédente tourne
# encore, on passe. Utilisé par cron, RUN_ON_START et `docker exec`.

cd /download || exit 1

exec 9>/tmp/instaloader.lock
if ! flock -n 9; then
  echo "Exécution précédente encore en cours, lancement ignoré."
  exit 0
fi

exec /run_instaloader.sh /il_args.txt /il_targets.txt
