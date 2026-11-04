#!/bin/sh

args="$(cat "$1" | xargs)"

targets="$(cat "$2" | xargs)"

# exec : Instaloader reçoit directement les signaux (docker stop) au lieu du shell
exec instaloader $args $targets
