FROM rabbitmq:3-alpine
COPY enabled_plugins \
	/etc/rabbitmq/

COPY docker-entrypoint-2.sh \
	/usr/local/bin/

ENTRYPOINT ["docker-entrypoint-2.sh"]
CMD ["rabbitmq-server"]
