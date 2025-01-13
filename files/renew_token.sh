#!/bin/sh

set -e

# update the auth token
AUTH=$(grep  X-Forwarded-User ${DST_CONFIG} | awk '{print $4}'| uniq|tr -d "\n\r")

# retry till new get new token
while true; do
  TOKEN=$(aws ecr get-authorization-token --registry-ids $UPSTREAM_REGISTRY_ID | jq -r '.authorizationData[].authorizationToken')
  [ ! -z "${TOKEN}" ] && break
  echo "Warn: Unable to get new token, wait and retry!"
  sleep 30
done

sed -i "s|${AUTH%??}|${TOKEN}|g" ${DST_CONFIG}

nginx -c ${DST_CONFIG} -s reload
