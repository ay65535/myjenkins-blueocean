#!/bin/bash

# docker compose config

# if $USERDNSDOMAIN is set, ".$USERDNSDOMAIN" is appended to host name, otherwise empty
DOMAIN_PART=${USERDNSDOMAIN:+.$USERDNSDOMAIN}
lowercase_hostname=$(echo "${HOSTNAME:-$HOST}${DOMAIN_PART}" | tr '[:upper:]' '[:lower:]')
export JENKINS_URL="http://${lowercase_hostname}:8080"

export JENKINS_ADMIN_USER=xxxxx
export JENKINS_ADMIN_PASS=xxxxx

# Run your own myjenkins-blueocean image as a container in Docker
echo "$JENKINS_URL"
docker compose up -d

docker compose ps -a

# Accessing the Docker logs
#docker compose logs -f jenkins-blueocean

# Cleanup the Docker container and volume
#docker compose down --remove-orphans --volumes
#rm -rf ../../../../jenkins/
