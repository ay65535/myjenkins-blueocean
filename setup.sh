# https://www.jenkins.io/doc/book/installing/docker/

# Create a bridge network in Docker
docker network create jenkins

# download and run the docker:dind Docker image
docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind --storage-driver overlay2

# Build a new docker image
docker build -t myjenkins-blueocean:2.346.1-1 .

# Run your own myjenkins-blueocean image as a container in Docker
docker run --name jenkins-blueocean --restart=on-failure --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:2.346.1-1

# Accessing the Docker container
docker exec -it jenkins-blueocean bash

# Accessing the Docker logs
docker logs jenkins-docker
docker logs jenkins-blueocean

# Accessing the Jenkins home directory
