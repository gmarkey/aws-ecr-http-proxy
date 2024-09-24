FROM openresty/openresty:1.25.3.2-alpine

USER root

RUN apk add --no-cache aws-cli dumb-init

COPY files/startup.sh files/renew_token.sh /
COPY files/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

ENV PORT 5000
RUN chmod a+x /startup.sh /renew_token.sh

USER nobody

ENTRYPOINT ["/startup.sh"]
