#!/bin/sh

args="$(cat "$1" | xargs)"

targets="$(cat "$2" | xargs)"

# Cookies de navigateur (voir README) : les variables s'ajoutent aux options d'Instaloader.
# Les guillemets préservent les chemins qui contiennent des espaces.
set --
if [ -n "${IL_LOAD_COOKIES:-}" ]; then
  set -- "$@" "--load-cookies=$IL_LOAD_COOKIES"
fi
if [ -n "${IL_COOKIEFILE:-}" ]; then
  set -- "$@" "--cookiefile=$IL_COOKIEFILE"
fi

# exec : Instaloader reçoit directement les signaux (docker stop) au lieu du shell
exec instaloader "$@" $args $targets
