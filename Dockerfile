FROM gmarkey/openresty:1.17.8.2

USER root

RUN apk add --no-cache python3 py3-pip dumb-init jq \
 && pip install awscli \
 && apk --purge del py-pip

COPY files/startup.sh files/renew_token.sh /
COPY files/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

ENV PORT 5000
RUN chmod a+x /startup.sh /renew_token.sh

USER nobody

ENTRYPOINT ["/startup.sh"]
