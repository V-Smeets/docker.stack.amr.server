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

cat > /etc/rabbitmq/definitions.json <<EOT
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

exec docker-entrypoint.sh "$@"

# vim:ai:sw=4:
