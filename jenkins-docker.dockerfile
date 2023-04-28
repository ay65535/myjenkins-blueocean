FROM jenkins/ssh-agent:alpine

ARG https_proxy

USER root

# Install Docker
RUN https_proxy=$https_proxy apk add --no-cache docker

# Add Docker entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER jenkins
