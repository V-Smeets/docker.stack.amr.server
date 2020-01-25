FROM certbot/certbot:latest

RUN apk add --no-cache \
	curl \
	jq \
	tini
RUN pip install \
	certbot-dns-directadmin

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "tini", "-g", "-v", "--" ]
CMD [ "/usr/local/bin/docker-entrypoint.sh" ]
