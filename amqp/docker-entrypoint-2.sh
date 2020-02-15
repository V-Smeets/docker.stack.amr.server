#!/bin/bash
#

function hex2bin()
{
    sed 's/\([0-9A-F]\{2\}\)/\\\\\\x\1/gI' | xargs printf
}

function asHex()
{
    od --address-radix=n --format=x1 --output-duplicates "$@" | \
	tr -d '\r\n '
}

function rabbit_password_hashing_sha256()
{
    passwordFile="$1"
    password="$(< "$passwordFile")"
    passwordB64="$(echo -n "$password" | base64)"
    saltB64="$(head -c 4 /dev/urandom | base64)"
    saltedPasswordB64="$(echo "$saltB64$passwordB64" | base64 -d | base64)"
    hashB64="$(echo -n "$saltedPasswordB64" | base64 -d | sha256sum | head -c 64 | hex2bin | base64)"
    saltedHashB64="$(echo "$saltB64$hashB64" | base64 -d | base64)"
    echo "$saltedHashB64"
}

configFile="/etc/rabbitmq/rabbitmq.conf"
cat > "$configFile" <<-EOT
listeners.tcp.default = 5672
default_user = $(< /run/secrets/amqp.admin.user)
default_pass = $(< /run/secrets/amqp.admin.password)
loopback_users.$(< /run/secrets/amqp.admin.user) = false
management.tcp.port = 15672
management.path_prefix = /amqp
EOT

definitionsFile="/etc/rabbitmq/definitions.json"
if [ -f "/var/lib/rabbitmq/.erlang.cookie" ]
then
    # Don't overwrite any changed settings.
    rm -f "$definitionsFile"
else
	cat > "$definitionsFile" <<-EOT
	{
	    "global_parameters": [
		{
		    "name": "cluster_name",
		    "value": "rabbit@amr-server"
		}
	    ],
	    "users": [
		{
		    "name": "$(< /run/secrets/amqp.admin.user)",
		    "password_hash": "$(rabbit_password_hashing_sha256 /run/secrets/amqp.admin.password)",
		    "hashing_algorithm": "rabbit_password_hashing_sha256",
		    "tags": "administrator"
		},
		{
		    "name": "$(< /run/secrets/amqp.amr.client.user)",
		    "password_hash": "$(rabbit_password_hashing_sha256 /run/secrets/amqp.amr.client.password)",
		    "hashing_algorithm": "rabbit_password_hashing_sha256",
		    "tags": ""
		},
		{
		    "name": "$(< /run/secrets/amqp.amr.server.user)",
		    "password_hash": "$(rabbit_password_hashing_sha256 /run/secrets/amqp.amr.server.password)",
		    "hashing_algorithm": "rabbit_password_hashing_sha256",
		    "tags": ""
		},
		{
		    "name": "$(< /run/secrets/amqp.shovel.client.user)",
		    "password_hash": "$(rabbit_password_hashing_sha256 /run/secrets/amqp.shovel.client.password)",
		    "hashing_algorithm": "rabbit_password_hashing_sha256",
		    "tags": ""
		},
		{
		    "name": "$(< /run/secrets/amqp.shovel.server.user)",
		    "password_hash": "$(rabbit_password_hashing_sha256 /run/secrets/amqp.shovel.server.password)",
		    "hashing_algorithm": "rabbit_password_hashing_sha256",
		    "tags": ""
		}
	    ],
	    "vhosts": [
		{
		    "name": "/"
		}
	    ],
	    "permissions": [
		{
		    "user": "$(< /run/secrets/amqp.admin.user)",
		    "vhost": "/",
		    "configure": ".*",
		    "write": ".*",
		    "read": ".*"
		},
		{
		    "user": "$(< /run/secrets/amqp.amr.client.user)",
		    "vhost": "/",
		    "configure": ".*",
		    "write": ".*",
		    "read": ""
		},
		{
		    "user": "$(< /run/secrets/amqp.amr.server.user)",
		    "vhost": "/",
		    "configure": ".*",
		    "write": "",
		    "read": ".*"
		},
		{
		    "user": "$(< /run/secrets/amqp.shovel.client.user)",
		    "vhost": "/",
		    "configure": "",
		    "write": "",
		    "read": ".*"
		},
		{
		    "user": "$(< /run/secrets/amqp.shovel.server.user)",
		    "vhost": "/",
		    "configure": "",
		    "write": ".*",
		    "read": ""
		}
	    ]
	}
	EOT
	echo "management.load_definitions = $definitionsFile" >> "$configFile"
fi

exec docker-entrypoint.sh "$@"

# vim:ai:sw=4:
