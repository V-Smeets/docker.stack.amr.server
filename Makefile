#
STACK_NAME		= amr-server
TARGETS			= amqp \
			  certbot \
			  nginx
SECRET_NAMES		= amqp.admin.user \
			  amqp.admin.password \
			  amqp.amr.client.user \
			  amqp.amr.client.password \
			  amqp.amr.server.user \
			  amqp.amr.server.password \
			  amqp.shovel.client.user \
			  amqp.shovel.client.password \
			  amqp.shovel.server.user \
			  amqp.shovel.server.password \
			  certbot.directadmin.url \
			  certbot.directadmin.username \
			  certbot.directadmin.password
SECRET_FILE_NAMES	= ${SECRET_NAMES:%=secret.%}
PLATFORMS		= linux/amd64 \
			  linux/arm/v7

comma			:= ,
empty			:=
space			:= $(empty) $(empty)

# General
all::
clean::
distclean:: clean

# Secrets
all:: secrets
distclean::
	$(RM) ${SECRET_FILE_NAMES}
secrets: ${SECRET_FILE_NAMES}
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
secret.certbot.directadmin.url:
	echo "https://directadmin.example.com:2222" >$@
secret.certbot.directadmin.username:
	echo "user" >$@
secret.certbot.directadmin.password:
	echo "password" >$@

# Images
all:: images
images:
	docker buildx bake \
		$(foreach target,$(TARGETS), --set=$(target).platform="$(subst $(space),$(comma),$(PLATFORMS))") \
		--pull \
		$(foreach target,$(TARGETS), --set=$(target).output=type=registry)

# Stack
all:: stack
clean::
	docker stack rm ${STACK_NAME}
	-docker container wait `docker container ls --filter label=com.docker.stack.namespace="${STACK_NAME}" --quiet`
distclean::
	docker system prune --all --filter label=com.docker.stack.namespace="${STACK_NAME}" --volumes --force
stack:: docker-compose.yml
	docker stack deploy --compose-file docker-compose.yml --prune ${STACK_NAME}
docker-compose.yml: ${SECRET_FILE_NAMES}
