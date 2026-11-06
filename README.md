# docker-instaloader

Image Docker contenant `instaloader`. Voir [instaloader/instaloader](https://github.com/instaloader/instaloader) pour plus d'informations.

Ce projet s'inspire en partie de [shyd/docker-instagram-scraper](https://github.com/shyd/docker-instagram-scraper), une autre bonne option pour archiver Instagram.

## Versions d'Instaloader

Je fais de mon mieux pour garder l'image à jour à chaque nouvelle version d'Instaloader. Un tag est créé pour chaque [version d'Instaloader](https://github.com/instaloader/instaloader/releases).

Ce fork est reconstruit tous les lundis (et à chaque push sur `master`), toujours à partir de la dernière image de base et de la dernière version d'Instaloader.

`immovably/docker-instaloader:latest` : dernière version officielle

`immovably/docker-instaloader:a.b.c` : version a.b.c. Par exemple, la version alpha 4.3a1 s'obtient avec :
`docker pull immovably/docker-instaloader:4.3a1`

[Liste complète des tags disponibles](https://hub.docker.com/r/immovably/docker-instaloader/tags)

Les pull requests construisent et testent l'image, mais ne la publient jamais.

## Utilisation

Pour l'utilisation complète d'Instaloader, consulte [leur excellente documentation](https://instaloader.github.io/index.html).

L'un des objectifs de cette image est de te permettre de transmettre à Instaloader une liste d'arguments et une liste de cibles.

Crée un fichier contenant la liste des arguments à passer à Instaloader. Tu peux le nommer comme tu veux en local, mais il doit être monté dans le conteneur sous le nom `il_args.txt`. Je recommande au minimum les arguments `--login=mon_identifiant` et `--sessionfile`. Par exemple, mon fichier contient actuellement :

```
--login=mon_identifiant
--sessionfile=instaloader.sessionfile
--geotags
--fast-update
```

Crée un fichier contenant la liste des cibles à télécharger. Là encore, le nom local est libre, mais il doit être monté sous le nom `il_targets.txt`. D'après la [documentation d'Instaloader](https://instaloader.github.io/cli-options.html#what-to-download), une cible est un profil, un « #hashtag », @profil (tous les profils suivis par ce profil) ou, une fois connecté, `:feed` (les images de ton fil), `:stories` (les stories des comptes que tu suis) ou `:saved` (les publications enregistrées). Les cibles se séparent par des retours à la ligne ou des espaces.

```
utilisateur_1
utilisateur_2
#hashtag_1
[etc]
```

Tu peux ensuite lancer un nouveau conteneur en lui transmettant ces fichiers :

```
docker run --name instaloader -it \
    -v "$(pwd)/download:/download" \
    -v "$(pwd)/il_args.txt:/il_args.txt" \
    -v "$(pwd)/il_targets.txt:/il_targets.txt" \
    immovably/docker-instaloader
```

Sous Windows PowerShell, remplace les `\` de fin de ligne par un accent grave (backtick) et `$(pwd)/` par `${PWD}/`.

Par défaut, les médias sont téléchargés dans `./download/[cible]`. L'organisation des dossiers et des fichiers peut être modifiée avec les arguments d'Instaloader `--dirname-pattern` et `--filename-pattern`.

Le conteneur s'exécute par défaut en root : les fichiers écrits dans `./download` appartiennent donc à root sur la machine hôte. Pour les écrire avec ton propre utilisateur, ajoute `--user "$(id -u):$(id -g)"` à la commande ; le chemin du fichier de session doit alors être accessible en écriture pour cet utilisateur. Cette option est incompatible avec le mode cron ci-dessous, qui exige root.

## Relance planifiée (cron)

Par défaut, le conteneur lance Instaloader une fois puis s'arrête : il faut le redémarrer pour relancer l'appli. Pour éviter cela, définis la variable `CRON_SCHEDULE` : le conteneur reste alors actif et relance Instaloader selon ce planning.

| Variable | Rôle |
| --- | --- |
| `CRON_SCHEDULE` | Planning cron à 5 champs (minute heure jour mois jour_semaine), par exemple `0 */6 * * *` pour toutes les 6 heures. Sans cette variable, comportement inchangé. |
| `RUN_ON_START` | `true` pour lancer aussi une exécution dès le démarrage du conteneur (par défaut, la première exécution attend l'heure prévue). |
| `TZ` | Fuseau horaire du planning, par exemple `Europe/Paris`. Par défaut, UTC. |

```
docker run -d --name instaloader --restart unless-stopped \
    -e CRON_SCHEDULE="0 */6 * * *" \
    -e RUN_ON_START=true \
    -e TZ=Europe/Paris \
    -v "$(pwd)/download:/download" \
    -v "$(pwd)/il_args.txt:/il_args.txt" \
    -v "$(pwd)/il_targets.txt:/il_targets.txt" \
    immovably/docker-instaloader
```

Les messages d'Instaloader s'affichent avec `docker logs -f instaloader`. Si une exécution dure plus longtemps que l'intervalle prévu, la suivante est ignorée au lieu de se superposer.

Pour déclencher une exécution à la main dans le conteneur déjà lancé, sans le redémarrer :

```
docker exec instaloader /run_job.sh
```

Un intervalle très court multiplie les requêtes vers Instagram, ce qui peut entraîner des limitations ou le blocage du compte : évite de descendre sous quelques heures.

Ne publie jamais ton fichier de session (`*.sessionfile`) : il donne accès à ton compte Instagram.

## Avertissement

Cette image Docker n'est ni affiliée, ni autorisée, ni maintenue, ni approuvée par Instaloader, Instagram ou l'une de leurs filiales. Il s'agit d'un projet indépendant et non officiel. Utilisation à tes risques.

Il est possible que l'image ne permette pas d'utiliser toutes les fonctionnalités d'Instaloader, même si j'ai fait de mon mieux.
