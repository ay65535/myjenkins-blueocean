#!/bin/bash
#
# .EXAMPLE
#   ./run.sh
# .EXAMPLE
#   export JENKINS_URL=http://10.x.y.z:8080/
#   ./run.sh
# .EXAMPLE
#   JENKINS_URL=http://10.x.y.z:8080/ ./run.sh

# JENKINS_URLが設定されていない場合、現在のホスト名を使用して設定
# if [ -z "$JENKINS_URL" ]; then
#   os_name=$(uname)
#   if [[ "$os_name" == "Linux" ]] || [[ "$os_name" == "Darwin" ]]; then
#     JENKINS_HOST=$(hostname -f)
#   elif [[ "$os_name" == "MINGW"* ]] || [[ "$os_name" == "MSYS"* ]]; then
#     JENKINS_HOST=$(echo "$HOSTNAME.$USERDNSDOMAIN" | tr '[:upper:]' '[:lower:]')
#   else
#     JENKINS_HOST=localhost
#   fi

#   JENKINS_URL="http://${JENKINS_HOST}:8080/"
#   echo "JENKINS_URL : $JENKINS_URL"

#   export JENKINS_HOST JENKINS_URL
# fi

# Run your own myjenkins-blueocean image as a container in Docker
echo "Jenkinsを起動します。"
docker-compose up -d

# -----

# for debug

# docker-compose config
# docker-compose ps -a
# docker ps -a
# docker volume ls
# docker volume prune --force
# docker-compose logs -f jenkins-docker
# docker-compose logs -f jenkins-blueocean
# docker-compose run --entrypoint bash jenkins-blueocean
# docker run --rm --entrypoint='' jenkins/jenkins:2.387.2 ls -laF --color /etc/environment
# docker run --rm --entrypoint='' jenkins/jenkins:2.387.2 id
#   -v "$PWD"/etc/environment:/etc/environment \
#   -v "$PWD"/etc/sudoers.d/:/etc/sudoers.d/ \
# docker run --rm -u root -it \
#   -v "$PWD"/usr/local/bin/:/usr/local/sbin/ \
#   -v "$PWD"/usr/local/share/ca-certificates/:/usr/local/share/ca-certificates/ \
#   -v "$PWD"/usr/share/jenkins/ref/plugins.txt:/usr/share/jenkins/ref/plugins.txt \
#   -v "$PWD"/run/secrets/:/run/secrets/ \
#   --entrypoint=/bin/bash jenkins/jenkins:2.387.2
# docker ps -a

# Delete bind mounted host machine files
# docker-compose run --entrypoint '' jenkins-docker rm -rf /usr/local/share/ca-certificates/* /certs/client/* /var/jenkins_home/*

# docker run --rm --entrypoint '' docker:dind rm -rf /usr/local/share/ca-certificates/* /certs/client/* /var/jenkins_home/*
# ls -laFR --color ~/jenkins-volume

# Cleanup the Docker container and volume
# : "
set -ax && . ./.env && set +ax
HOST_UID=$(id -u)
HOST_GID=$(id -g)
export HOST_UID HOST_GID
docker-compose build
docker run --rm \
  -v "$VOLUME_ROOT/jenkins_home/:/var/jenkins_home/" \
  --entrypoint=/bin/chown docker:dind -R "$HOST_UID:$HOST_GID" /var/jenkins_home
ls -la $VOLUME_ROOT/jenkins_home
docker network ls
docker network create --subnet 10.6.80.0/24 jenkins-external
#docker network create --subnet 192.168.0.0/24 jenkins-external
docker-compose up -d
docker-compose ps -a
docker ps -a
docker-compose logs jenkins-blueocean
docker-compose logs -f jenkins-blueocean
# echo http:// :8080/
docker-compose exec jenkins-blueocean bash
docker-compose exec -u root jenkins-blueocean bash
docker-compose exec jenkins-blueocean sudo /usr/local/bin/update-cacert.sh /opt/java/openjdk
docker-compose exec jenkins-blueocean sudo /usr/local/bin/install-cert.sh /opt/java/openjdk
docker-compose exec -u root jenkins-blueocean /usr/local/bin/update-cacert.sh /opt/java/openjdk
docker-compose exec -u root jenkins-blueocean /usr/local/bin/install-cert.sh /opt/java/openjdk

JENKINS_AGENT_SSH_PUBKEY=$(cat ~/.ssh/jenkins_agent_key.pub)
docker run -d --rm --name=agent1 -p 10022:22 --network jenkins-external --ip 10.6.X.X -e JENKINS_AGENT_SSH_PUBKEY="$JENKINS_AGENT_SSH_PUBKEY" jenkins/ssh-agent:alpine
docker run -d --rm --name=agent1 -p 10022:22 --network host -e JENKINS_AGENT_SSH_PUBKEY="$JENKINS_AGENT_SSH_PUBKEY" jenkins/ssh-agent:alpine
docker run -d --rm --name=agent1 --network host -e JENKINS_AGENT_SSH_PUBKEY="$JENKINS_AGENT_SSH_PUBKEY" -e JENKINS_AGENT_LISTEN_ADDRESS=0.0.0.0 -e JENKINS_AGENT_PORT=10022 jenkins/ssh-agent:alpine
docker run -d --name=agent1 -p 10022:22 --network jenkins-external --ip 10.6.80.122 -e JENKINS_AGENT_SSH_PUBKEY="$JENKINS_AGENT_SSH_PUBKEY" jenkins/ssh-agent:alpine

docker-compose exec jenkins-docker sh

docker-compose run --rm --entrypoint='' jenkins-blueocean bash

docker run --rm -it --entrypoint='' myjenkins-blueocean:2.387.2-1 bash

docker-compose exec jenkins-blueocean \
  docker run -d --rm --name=agent1 -p 10022:22 -e JENKINS_AGENT_SSH_PUBKEY="$JENKINS_AGENT_SSH_PUBKEY" jenkins/ssh-agent:jdk11
docker-compose exec jenkins-blueocean mkdir /var/jenkins_home/.ssh
docker cp ~/.ssh/jenkins_agent_key jenkins-blueocean:/var/jenkins_home/.ssh/jenkins_agent_key
# mkdir $VOLUME_ROOT/jenkins_home/.ssh/ && cp ~/.ssh/jenkins_agent_key $VOLUME_ROOT/jenkins_home/.ssh/jenkins_agent_key
docker-compose exec jenkins-blueocean \
  ls -l /var/jenkins_home/.ssh/jenkins_agent_key
docker-compose exec jenkins-blueocean \
  ssh -i /var/jenkins_home/.ssh/jenkins_agent_key -p 10022 jenkins@jenkins-docker
docker-compose exec jenkins-blueocean docker ps -a
docker-compose exec jenkins-blueocean docker stop agent1

docker ps -a
docker logs agent1
# JENKINS_AGENT_SSH_PRVKEY=$(cat ~/.ssh/jenkins_agent_key)
ssh -i ~/.ssh/jenkins_agent_key jenkins@10.6.80.122 which -a git
docker stop agent1
docker rm agent1

docker-compose down
docker-compose down --remove-orphans --volumes
. ./.env
echo $VOLUME_ROOT
sudo rm -rf $VOLUME_ROOT
# docker run --rm \
#   -v $VOLUME_ROOT/jenkins_home/:/var/jenkins_home/ \
#   --entrypoint=/bin/sh docker:dind -c 'chmod -R 770 /var/jenkins_home/secrets /var/jenkins_home/users/'
# docker run --rm \
#   -v $VOLUME_ROOT/docker-certs/:/certs/client/ \
#   -v $VOLUME_ROOT/java-certs/:/opt/java/openjdk/lib/security/ \
#   -v $VOLUME_ROOT/jenkins_home/:/var/jenkins_home/ \
#   --entrypoint=/bin/sh docker:dind -c 'rm -rf /var/jenkins_home/* /var/jenkins_home/.* /certs/client/*'
ls -la $VOLUME_ROOT
ls -la $VOLUME_ROOT/jenkins_home
# "
