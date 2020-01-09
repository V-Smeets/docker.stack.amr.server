#
VERSION			= $(shell git describe)
STACK_NAME		= amr-server
SECRET_NAMES		= amqp.admin.user \
			  amqp.admin.password \
			  amqp.amr.client.user \
			  amqp.amr.client.password \
			  amqp.amr.server.user \
			  amqp.amr.server.password \
			  amqp.shovel.client.user \
			  amqp.shovel.client.password \
			  amqp.shovel.server.user \
			  amqp.shovel.server.password
SECRET_FILE_NAMES	= ${SECRET_NAMES:%=secret.%}

# General
all::
clean::
distclean:: clean

# Secrets
all:: ${SECRET_FILE_NAMES}
distclean::
	$(RM) ${SECRET_FILE_NAMES}
secret.amqp.admin.user:
	echo "admin" >$@
secret.amqp.admin.password:
	openssl rand -base64 15 >$@
secret.amqp.amr.client.user:
	echo "amr-client" >$@
secret.amqp.amr.client.password:
	openssl rand -base64 15 >$@
secret.amqp.amr.server.user:
	echo "amr-server" >$@
secret.amqp.amr.server.password:
	openssl rand -base64 15 >$@
secret.amqp.shovel.client.user:
	echo "shovel-client" >$@
secret.amqp.shovel.client.password:
	openssl rand -base64 15 >$@
secret.amqp.shovel.server.user:
	echo "shovel-server" >$@
secret.amqp.shovel.server.password:
	openssl rand -base64 15 >$@

# stack
all:: docker-compose.yml
	docker-compose --file docker-compose.yml --project-name ${STACK_NAME} build
	docker stack deploy --compose-file docker-compose.yml --prune ${STACK_NAME}
clean::
	docker stack rm ${STACK_NAME}
	-docker container wait `docker container ls --filter label=com.docker.stack.namespace="${STACK_NAME}" --quiet`
distclean::
	docker system prune --all --filter label=com.docker.stack.namespace="${STACK_NAME}" --volumes --force
docker-compose.yml: ${SECRET_FILE_NAMES}
