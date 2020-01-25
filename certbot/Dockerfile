FROM certbot/certbot:latest

RUN apk add --no-cache jq
RUN pip install certbot-dns-directadmin

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
