# https://github.com/adoptium/containers/blob/02264a4d3e57b92e02dc415fa4fc8aec7a4e3d62/11/jdk/alpine/Dockerfile.releases.full
FROM docker:dind AS eclipse-temurin--11-jdk-alpine

ARG https_proxy

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk
ENV PATH $JAVA_HOME/bin:$PATH

# Default to UTF-8 file.encoding
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# fontconfig and ttf-dejavu added to support serverside image generation by Java programs
RUN https_proxy=$https_proxy \
    apk add --no-cache fontconfig libretls musl-locales musl-locales-lang ttf-dejavu tzdata zlib

ENV JAVA_VERSION jdk-11.0.19+7

RUN https_proxy=$https_proxy \
    apk add --no-cache openjdk11

RUN echo Verifying install ... \
    && fileEncoding="$(echo 'System.out.println(System.getProperty("file.encoding"))' | jshell -s -)"; [ "$fileEncoding" = 'UTF-8' ]; rm -rf ~/.java \
    && echo javac --version && javac --version \
    && echo java --version && java --version \
    && echo Complete.

# ----------

# https://github.com/jenkinsci/docker-ssh-agent/blob/master/11/alpine/Dockerfile
FROM eclipse-temurin--11-jdk-alpine

ARG https_proxy
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}

ENV JENKINS_AGENT_HOME=${JENKINS_AGENT_HOME}

ARG AGENT_WORKDIR="${JENKINS_AGENT_HOME}/agent"
# Persist agent workdir path through an environment variable for people extending the image
ENV AGENT_WORKDIR=${AGENT_WORKDIR}

RUN addgroup -g "${gid}" "${group}" \
    # Set the home directory (h), set user and group id (u, G), set the shell, don't ask for password (D)
    && adduser -h "${JENKINS_AGENT_HOME}" -u "${uid}" -G "${group}" -s /bin/bash -D "${user}" \
    # Unblock user
    && passwd -u "${user}" \
    # Prepare subdirectories
    && mkdir -p "${JENKINS_AGENT_HOME}/.ssh/" "${JENKINS_AGENT_HOME}/.jenkins/" "${AGENT_WORKDIR}" \
    && chown -R "${uid}":"${gid}" "${JENKINS_AGENT_HOME}" "${AGENT_WORKDIR}" \
    # https://docs.docker.com/engine/install/linux-postinstall/
    # https://garafu.blogspot.com/2019/07/operate-user-group-on-alpine.html
    && addgroup -S docker \
    && addgroup -S $user docker


RUN https_proxy=$https_proxy \
    apk add --no-cache \
    bash \
    git-lfs \
    less \
    netcat-openbsd \
    openssh \
    patch

# setup SSH server
RUN sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' \
        -e 's/#PermitUserEnvironment.*/PermitUserEnvironment yes/' \
    && mkdir /var/run/sshd

# VOLUME directive must happen after setting up permissions and content
VOLUME "${AGENT_WORKDIR}" "${JENKINS_AGENT_HOME}"/.jenkins "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

# Alpine's ssh doesn't use $PATH defined in /etc/environment, so we define `$PATH` in `~/.ssh/environment`
# The file path has been created earlier in the file by `mkdir -p` and we also have configured sshd so that it will
# allow environment variables to be sourced (see `sed` command related to `PermitUserEnvironment`)
RUN echo "PATH=${PATH}" >> ${JENKINS_AGENT_HOME}/.ssh/environment
COPY setup-sshd entrypoint-docker.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-sshd /usr/local/bin/entrypoint-docker.sh

EXPOSE 22

ENTRYPOINT ["entrypoint-docker.sh"]
