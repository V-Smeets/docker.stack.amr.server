FROM certbot/certbot:latest

RUN pip install certbot-dns-directadmin

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
