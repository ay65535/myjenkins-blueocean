#!/bin/bash

# Fix permisseions
sudo chown -R jenkins:jenkins /var/jenkins_home/
ls -laF --color /var/jenkins_home/

# Resolve proxy related envs
# set -a && . /etc/environment && set +a

env | grep -iE 'proxy|java|jdk|jenkins|docker' | sort

# Execute update-cacert.sh
sudo /usr/local/bin/update-cacert.sh

# Execute install-cert.sh
sudo /usr/local/bin/install-cert.sh

# JENKINS_URLが設定されていない場合、現在のホスト名を使用して設定
if [ -z "$JENKINS_URL" ]; then
  os_name=$(uname)
  if [[ "$os_name" == "Linux" ]] || [[ "$os_name" == "Darwin" ]]; then
    JENKINS_HOST=$(hostname -f)
  elif [[ "$os_name" == "MINGW"* ]] || [[ "$os_name" == "MSYS"* ]]; then
    JENKINS_HOST=$(echo "$HOSTNAME.$USERDNSDOMAIN" | tr '[:upper:]' '[:lower:]')
  else
    JENKINS_HOST=localhost
  fi

  JENKINS_URL="http://${JENKINS_HOST}:8080/"
  echo "JENKINS_URL : $JENKINS_URL"

  export JENKINS_HOST JENKINS_URL
fi

## How to check the original entrypoint command:
# docker pull jenkins/jenkins:2.387.2
# docker inspect --format='{{json .Config.Entrypoint}}' jenkins/jenkins:2.387.2

## How to check the original entrypoint script:
# docker run --name temp-jenkins-container -d jenkins/jenkins:2.387.2 sleep infinity
# docker cp temp-jenkins-container:/usr/local/bin/jenkins.sh ./jenkins.sh
# docker stop temp-jenkins-container
# docker rm temp-jenkins-container

# Run the original entrypoint script
exec /usr/bin/tini -- /usr/local/bin/jenkins.sh "$@"
