# 公式Jenkinsイメージをベースにする
FROM jenkins/jenkins:2.387.2

# ビルド引数を定義
ARG http_proxy
ARG https_proxy
ARG no_proxy

# セットアップウィザードをスキップするための環境変数を設定
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

USER root
# `http_proxy=$http_proxy https_proxy=$https_proxy no_proxy=$no_proxy` は
# ビルド時にだけプロキシを使用し、イメージには残さないためにコマンドの前に毎回記述しています。
RUN \
  http_proxy=$http_proxy https_proxy=$https_proxy no_proxy=$no_proxy \
    apt-get update \
  && http_proxy=$http_proxy https_proxy=$https_proxy no_proxy=$no_proxy DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends lsb-release \
  && http_proxy=$http_proxy https_proxy=$https_proxy no_proxy=$no_proxy \
    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
         https://download.docker.com/linux/debian/gpg \
  && echo "deb [arch=$(dpkg --print-architecture) \
          signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
          https://download.docker.com/linux/debian \
          $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
  && http_proxy=$http_proxy https_proxy=$https_proxy no_proxy=$no_proxy \
    apt-get update \
  && http_proxy=$http_proxy https_proxy=$https_proxy no_proxy=$no_proxy DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends docker-ce-cli \
  && rm -rf /var/lib/apt/lists/*

# Copy custom entrypoint script
COPY entrypoint.sh /entrypoint.sh

USER jenkins
# プラグインリストファイルをコピー
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
# jenkins-plugin-cliを使用してプラグインをインストール
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

ENTRYPOINT ["/entrypoint.sh"]
