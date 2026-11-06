#!/bin/sh
# Point d'entrée de l'image.
#   - Sans CRON_SCHEDULE : une seule exécution, puis le conteneur s'arrête
#     (comportement historique).
#   - Avec CRON_SCHEDULE : le conteneur reste actif et relance Instaloader
#     selon le planning cron.
#
# Variables :
#   CRON_SCHEDULE  planning cron à 5 champs, ex. "0 */6 * * *"
#   RUN_ON_START   "true" pour lancer aussi une exécution au démarrage
#   TZ             fuseau horaire du planning, ex. Europe/Paris (UTC par défaut)
set -eu

if [ -z "${CRON_SCHEDULE:-}" ]; then
  exec /run_instaloader.sh /il_args.txt /il_targets.txt
fi

if [ "$(id -u)" != "0" ]; then
  echo "CRON_SCHEDULE nécessite d'exécuter le conteneur en root (retire --user)." >&2
  exit 1
fi

# Vérifie que le planning compte bien 5 champs (globbing désactivé pour les '*')
set -f
# shellcheck disable=SC2086
set -- $CRON_SCHEDULE
set +f
if [ "$#" -ne 5 ]; then
  echo "CRON_SCHEDULE invalide : 5 champs attendus (minute heure jour mois jour_semaine), reçu : \"$CRON_SCHEDULE\"" >&2
  exit 1
fi

# La sortie du job est redirigée vers celle du conteneur (visible avec docker logs)
echo "$CRON_SCHEDULE /run_job.sh >/proc/1/fd/1 2>&1" > /etc/crontabs/root
echo "Planning cron : $CRON_SCHEDULE (TZ=${TZ:-UTC})"

if [ "${RUN_ON_START:-false}" = "true" ]; then
  /run_job.sh || true
fi

exec crond -f -l 8 -L /dev/stdout
