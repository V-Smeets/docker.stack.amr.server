#
DOCKER_USER_NAME	= vsmeets
STACK_NAME		= amr-server
VERSION			= $(shell git describe)
AMQP_IMAGE_NAME		= ${STACK_NAME}_amqp
AMQP_IMAGE_TAG		= ${DOCKER_USER_NAME}/${AMQP_IMAGE_NAME}
AMQP_IMAGE_VERSION_TAG	= ${AMQP_IMAGE_TAG}:${VERSION}

all::
clean::

# amqp
all:: ${AMQP_IMAGE_NAME}
clean::
	$(RM) ${AMQP_IMAGE_NAME}
${AMQP_IMAGE_NAME}: amqp/Dockerfile
	docker build --tag="${AMQP_IMAGE_TAG}" --tag="${AMQP_IMAGE_VERSION_TAG}" amqp
	touch $@

# stack
all:: docker-compose.yml
	docker stack deploy --compose-file docker-compose.yml ${STACK_NAME}
clean::
	docker stack rm ${STACK_NAME}
	-docker container wait `docker container ls --filter label=com.docker.stack.namespace="${STACK_NAME}" --quiet`
	docker system prune --all --filter label=com.docker.stack.namespace="${STACK_NAME}" --volumes --force
docker-compose.yml: ${AMQP_IMAGE_NAME}
