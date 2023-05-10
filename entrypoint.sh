#!/bin/bash

# Fix permisseions
sudo chown -R jenkins:jenkins /var/jenkins_home/
ls -laF --color /var/jenkins_home/

# Resolve proxy related envs
# set -a && . /etc/environment && set +a

echo "::: $0 :::"
# for debug:
# env | grep -iE 'proxy|trust|java|jdk|jenkins|docker' | sort -f

# Execute update-cacert.sh
sudo /usr/local/bin/update-cacert.sh "$JAVA_HOME"

# Execute install-cert.sh
sudo /usr/local/bin/install-cert.sh "$JAVA_HOME"

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
