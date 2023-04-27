# Set the base image
ARG JENKINS_VERSION


#
# Build stage (Java)
#

# 公式Jenkinsイメージをベースにする
FROM jenkins/jenkins:${JENKINS_VERSION} AS javabuild

# ビルド引数を定義
ARG PROXY
ARG NO_PROXY

USER root

COPY etc/environment /etc/environment
COPY --chmod=755 usr/local/bin/* /usr/local/bin/
COPY usr/local/share/ca-certificates/* /usr/local/share/ca-certificates/
COPY usr/share/jenkins/ref/plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN setenv.sh >/etc/environment && \
    set -a && . /etc/environment && set +a && \
    #
    # Clone InstallCert
    git clone --depth=1 https://github.com/escline/InstallCert.git /InstallCert && \
    # Build & run InstallCert
    javac /InstallCert/InstallCert.java && \
    cp /InstallCert/*.class /usr/local/bin/ && \
    update-cacert.sh && \
    install-cert.sh

USER jenkins
RUN set -a && . /etc/environment && set +a && \
    # jenkins-plugin-cliを使用してプラグインをインストール
    jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt --list 2>&1 | grep -v 'Picked up JAVA_TOOL_OPTIONS'


#
# Build stage (Apt)
#

FROM jenkins/jenkins:${JENKINS_VERSION} AS aptbuild

# ビルド引数を定義
ARG PROXY
ARG NO_PROXY

USER root
# `http_proxy=$PROXY https_proxy=$PROXY no_proxy=$NO_PROXY` は
# ビルド時にだけプロキシを使用し、イメージには残さないためにコマンドの前に毎回記述しています。
RUN http_proxy=$PROXY https_proxy=$PROXY no_proxy=$NO_PROXY \
    apt-get update && \
    #
    http_proxy=$PROXY https_proxy=$PROXY no_proxy=$NO_PROXY DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes \
    apt-get install -y --no-install-recommends lsb-release sudo && \
    #
    http_proxy=$PROXY https_proxy=$PROXY no_proxy=$NO_PROXY \
    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg && \
    #
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian $(lsb_release -cs) stable" >/etc/apt/sources.list.d/docker.list && \
    #
    http_proxy=$PROXY https_proxy=$PROXY no_proxy=$NO_PROXY \
    apt-get update && \
    #
    http_proxy=$PROXY https_proxy=$PROXY no_proxy=$NO_PROXY DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes \
    apt-get install -y --no-install-recommends docker-ce-cli && \
    #
    rm -rf /var/lib/apt/lists/*

# InstallCert.classをビルドステージからコピー
COPY --from=javabuild /InstallCert/*.class /usr/local/bin/
# Copy installed plugins from javabuild stage to final stage
COPY --from=javabuild /usr/share/jenkins/ref/plugins /usr/share/jenkins/ref/plugins


#
# Final stage
#

FROM aptbuild

# セットアップウィザードをスキップするための環境変数を設定
ENV JAVA_OPTS="${JAVA_OPTS} -Djenkins.install.runSetupWizard=false"

USER root

COPY etc/environment /etc/environment
COPY --chmod=0440 etc/sudoers.d/* /etc/sudoers.d/
COPY --chmod=755 usr/local/bin/* /usr/local/bin/
COPY usr/share/jenkins/ref/init.groovy.d/* /usr/share/jenkins/ref/init.groovy.d/

# Copy custom entrypoint script
COPY --chown=jenkins:jenkins --chmod=755 entrypoint.sh /entrypoint.sh

RUN cp -a /opt/java/openjdk/lib/security/ /opt/java/openjdk/lib/security.default

USER jenkins

# エントリーポイントを上書きし、証明書を追加するスクリプトを実行
ENTRYPOINT ["/entrypoint.sh"]
