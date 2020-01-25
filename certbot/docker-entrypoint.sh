#!/bin/sh
#
certName="amr-ens"
domains="amr-ens.vsmeets.nl"
email="Vincent.VSmeets@GMail.com"

nginxServiceName="amr-server_nginx"

credentialsFile="/tmp/directadmin-credentials.ini"
keyFile="/etc/letsencrypt/live/amr-ens/privkey.pem"

touch "$credentialsFile"
chmod go-rwx "$credentialsFile"
sed 's/^/certbot_dns_directadmin:directadmin_url = /'		/run/secrets/certbot.directadmin.url		>"$credentialsFile"
sed 's/^/certbot_dns_directadmin:directadmin_username = /'	/run/secrets/certbot.directadmin.username	>>"$credentialsFile"
sed 's/^/certbot_dns_directadmin:directadmin_password = /'	/run/secrets/certbot.directadmin.password	>>"$credentialsFile"

certbotNginxName="certbot-nginx"
certbotNginxOutput=`pip show --files "$certbotNginxName"`
certbotNginxLocation=`echo "$certbotNginxOutput" | awk '\$1 == "Location:" { print \$2 }'`
certbotNginxFile=`echo "$certbotNginxOutput" | awk '/options-ssl-nginx.conf\$/ { print \$1 }'`
cp "$certbotNginxLocation/$certbotNginxFile" /etc/letsencrypt

keyFileHash="$(md5sum "$keyFile" 2>/dev/null)"
previousKeyFileHash="$keyFileHash"
while :
do
	certbot \
		certonly \
		--agree-tos \
		--email "$email" \
		--cert-name "$certName" \
		--domains "$domains" \
		--authenticator certbot-dns-directadmin:directadmin \
		--certbot-dns-directadmin:directadmin-credentials "$credentialsFile" \
		--non-interactive \
		--test-cert
	keyFileHash="$(md5sum "$keyFile" 2>/dev/null)"
	if [ "$keyFileHash" != "$previousKeyFileHash" ]
	then
		echo "The key file has changed!"
		filters="{\"label\": [\"com.docker.swarm.service.name=${nginxServiceName}\"]}"
		filtersEncoded="$(echo "$filters" | jq --slurp --raw-input --raw-output "@uri")"
		containerIds="$(
			curl \
				--silent \
				--unix-socket /var/run/docker.sock \
				http://localhost/containers/json?filters="$filtersEncoded" \
			| jq --raw-output '.[].Id')"
		for containerId in $containerIds
		do
			echo "Sending signal to container $containerId"
			curl \
				--silent \
				--unix-socket /var/run/docker.sock \
				--request POST \
				"http://localhost/containers/${containerId}/kill?signal=HUP"
		done
	fi
	previousKeyFileHash="$keyFileHash"
	sleep 43200
done
