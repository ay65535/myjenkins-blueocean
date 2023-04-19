#!/bin/bash

# Update certificate store
update-ca-certificates

# JENKINS_URLが設定されていない場合、現在のホスト名を使用して設定
if [ -z "${JENKINS_URL}" ]; then
  JENKINS_URL="http://$(hostname):8080"
  export JENKINS_URL
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
