FROM python:alpine

RUN apk add --no-cache \
	certbot \
	curl \
	jq \
	tini

RUN apk add --no-cache --virtual .build-deps \
	gcc \
	libffi-dev \
	linux-headers \
	musl-dev \
	openssl-dev \
	py2-pip \
    && pip install \
	certbot-dns-directadmin \
	certbot-nginx \
    && apk del .build-deps

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "tini", "-g", "-v", "--" ]
CMD [ "docker-entrypoint.sh" ]
