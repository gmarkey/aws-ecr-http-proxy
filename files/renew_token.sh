#!/bin/sh

set -e

# update the auth token
AUTH=$(grep  X-Forwarded-User ${DST_CONFIG} | awk '{print $4}'| uniq|tr -d "\n\r")

# retry till new get new token
while true; do
  TOKEN=$(aws ecr get-login --no-include-email | awk '{print $6}')
  [ ! -z "${TOKEN}" ] && break
  echo "Warn: Unable to get new token, wait and retry!"
  sleep 30
done


AUTH_N=$(echo AWS:${TOKEN}  | base64 |tr -d "[:space:]")

sed -i "s|${AUTH%??}|${AUTH_N}|g" ${DST_CONFIG}

nginx -s reload
