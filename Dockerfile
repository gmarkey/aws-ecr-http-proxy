FROM openresty/openresty:1.15.8.3-2-alpine

USER root

RUN apk add --no-cache python py-pip \
 && pip install awscli==1.11.183 \
 && apk --purge del py-pip

COPY files/startup.sh files/renew_token.sh /
COPY files/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

ENV PORT 5000
RUN chmod a+x /startup.sh /renew_token.sh

USER nobody

ENTRYPOINT ["/startup.sh"]
