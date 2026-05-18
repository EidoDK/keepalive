FROM alpine:latest

RUN apk add --no-cache curl iputils

COPY keepalive.sh /usr/local/bin/keepalive.sh
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/keepalive.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]