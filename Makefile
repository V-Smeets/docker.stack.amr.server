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
