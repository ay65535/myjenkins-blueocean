ARG JENKINS_VERSION=2.387.2

#
# Build stage (Java)
#

# 公式Jenkinsイメージをベースにする
FROM jenkins/jenkins:${JENKINS_VERSION} as javabuild

# Set the ARG for the proxy server
ARG PROXY
ARG NO_PROXY
ARG TRUST_HOST

USER root

COPY scripts/setenv.sh scripts/update-cacert.sh scripts/install-cert.sh /usr/local/bin/

# Add your proxy certificate
COPY conf/my_proxy.crt /usr/local/share/ca-certificates/

# プラグインリストファイルをコピー
COPY conf/plugins.txt /

RUN update-cacert.sh && \
  setenv.sh >/etc/environment && \
  set -a && . /etc/environment && set +a && \
  # Clone InstallCert
  git clone --depth=1 https://github.com/escline/InstallCert.git /InstallCert

# Build & run InstallCert
RUN javac /InstallCert/InstallCert.java && \
  cp /InstallCert/*.class /usr/local/bin/ && \
  set -a && . /etc/environment && set +a && \
  install-cert.sh

# jenkins-plugin-cliを使用してプラグインをインストール
USER jenkins
RUN set -a && . /etc/environment && set +a && \
  jenkins-plugin-cli --plugin-file /plugins.txt


#
# Final stage
#

# 公式Jenkinsイメージをベースにする
FROM jenkins/jenkins:${JENKINS_VERSION}

# ビルド引数を定義
ARG PROXY
ARG NO_PROXY

# セットアップウィザードをスキップするための環境変数を設定
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

USER root

# InstallCert.classをビルドステージからコピー
COPY --from=javabuild /InstallCert/*.class /usr/local/bin/

# Copy installed plugins from javabuild stage to final stage
COPY --from=javabuild /usr/share/jenkins/ref/plugins /usr/share/jenkins/ref/plugins

# 管理ユーザを作成するスクリプトをコピー
COPY scripts/create_admin_user.groovy /usr/share/jenkins/ref/init.groovy.d/

# Add your proxy certificate
COPY conf/my_proxy.crt /usr/local/share/ca-certificates/

COPY scripts/update-cacert.sh scripts/install-cert.sh /usr/local/bin/

# Copy custom entrypoint script
COPY --chown=jenkins:jenkins  scripts/entrypoint.sh /entrypoint.sh

# `http_proxy=$PROXY https_proxy=$PROXY no_proxy=$NO_PROXY` は
# ビルド時にだけプロキシを使用し、イメージには残さないためにコマンドの前に毎回記述しています。
RUN http_proxy=$PROXY https_proxy=$PROXY no_proxy=$NO_PROXY \
  apt-get update \
  && http_proxy=$PROXY https_proxy=$PROXY no_proxy=$NO_PROXY DEBIAN_FRONTEND=noninteractive \
  apt-get install -y --no-install-recommends lsb-release sudo \
  && echo "jenkins ALL=(root) NOPASSWD: /usr/sbin/update-ca-certificates" > /etc/sudoers.d/jenkins \
  && chmod 0440 /etc/sudoers.d/jenkins \
  && http_proxy=$PROXY https_proxy=$PROXY no_proxy=$NO_PROXY \
  curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg \
  && echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
  && http_proxy=$PROXY https_proxy=$PROXY no_proxy=$NO_PROXY \
  apt-get update \
  && http_proxy=$PROXY https_proxy=$PROXY no_proxy=$NO_PROXY DEBIAN_FRONTEND=noninteractive \
  apt-get install -y --no-install-recommends docker-ce-cli \
  && rm -rf /var/lib/apt/lists/* \
  && echo 'jenkins ALL=(ALL) NOPASSWD: /usr/local/bin/update-cacert.sh, /usr/local/bin/install-cert.sh' >/etc/sudoers.d/jenkins-scripts \
  && chmod 0440 /etc/sudoers.d/jenkins-scripts
  # && unset http_proxy https_proxy no_proxy

USER jenkins

# エントリーポイントを上書きし、証明書を追加するスクリプトを実行
ENTRYPOINT ["/entrypoint.sh"]
