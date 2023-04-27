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
: "
docker-compose build
docker-compose up -d
docker-compose logs jenkins-blueocean
docker-compose logs -f jenkins-blueocean
docker compose exec -it jenkins-blueocean bash
docker compose exec -it -u root jenkins-blueocean bash
docker-compose down --remove-orphans --volumes
. .env
echo $VOLUME_ROOT
sudo rm -rf $VOLUME_ROOT
ls -la $VOLUME_ROOT
"
