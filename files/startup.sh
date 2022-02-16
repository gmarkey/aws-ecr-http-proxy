#!/usr/bin/dumb-init /bin/sh

set -e

if [ -z "$UPSTREAM" ] ; then
  echo "UPSTREAM not set."
  exit 1
fi

if [ -z "$PORT" ] ; then
  echo "PORT not set."
  exit 1
fi

if [ -z "$RESOLVER" ] ; then
  echo "RESOLVER not set."
  exit 1
fi

if [ -z "$AWS_DEFAULT_REGION" ] ; then
  echo "AWS_DEFAULT_REGION not set."
  exit 1
fi

UPSTREAM_WITHOUT_PORT=$( echo ${UPSTREAM} | sed -r "s/.*:\/\/(.*):.*/\1/g")

SCHEME=http
export SRC_CONFIG=/usr/local/openresty/nginx/conf/nginx.conf
export DST_CONFIG=${DST_CONFIG:=/tmp/nginx.conf}

cp ${SRC_CONFIG} ${DST_CONFIG}
cp $(dirname ${SRC_CONFIG})/mime.types $(dirname ${DST_CONFIG})/mime.types

# Update nginx config
sed -i -e s!UPSTREAM!"$UPSTREAM"!g $DST_CONFIG
sed -i -e s!PORT!"$PORT"!g $DST_CONFIG
sed -i -e s!RESOLVER!"$RESOLVER"!g $DST_CONFIG
sed -i -e s!CACHE_MAX_SIZE!"$CACHE_MAX_SIZE"!g $DST_CONFIG
sed -i -e s!CACHE_KEY!"$CACHE_KEY"!g $DST_CONFIG
sed -i -e s!SCHEME!"$SCHEME"!g $DST_CONFIG

# add the auth token in default.conf
AUTH=$(grep  X-Forwarded-User $DST_CONFIG | awk '{print $4}'| uniq|tr -d "\n\r")
TOKEN=$(aws ecr get-login --no-include-email | awk '{print $6}')
AUTH_N=$(echo AWS:${TOKEN}  | base64 |tr -d "[:space:]")
sed -i "s|${AUTH%??}|${AUTH_N}|g" $DST_CONFIG

nginx -c ${DST_CONFIG} -t
nginx -c ${DST_CONFIG} -g 'daemon off;' &

while jobs %%: do
  NOW=$(date +%s)
  DELTA=$(( ${NOW} - ${LAST:=0} ))
  if [[ ${DELTA} -gt ${RENEW_INTERVAL} ]]; then
    LAST=${NOW}
    /renew_token.sh
  fi
  sleep 10 # check if the nginx job is active every 10s
done
