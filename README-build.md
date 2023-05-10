# README - ビルド手順

本稿ではJenkinsコンテナイメージのビルドについて記述します。

- [ビルド済みイメージ置き場](#ビルド済みイメージ置き場)
- [コンテナイメージビルド手順](#コンテナイメージビルド手順)

## ビルド済みイメージ置き場

[README.md](./README.md) 参照

## コンテナイメージビルド手順

### 前提

以降の手順は Docker がインストールされていることを前提とします。

Dockerのインストール手順は [Install Docker Engine on Ubuntu | Docker Documentation](https://docs.docker.com/engine/install/ubuntu/) 等を参照。

#### 動作確認済み環境

| OS           | docker --version      | docker-compose --version |
| ------------ | --------------------- | ------------------------ |
| Ubuntu 20.04 | 23.0.4, build f480fb1 | 1.25.0                   |

### ビルド手順

#### 環境変数を設定

`.env.template` を `.env` として複製し、各自の環境に合わせて設定する。

`.env` は `usr/local/bin/setenv.sh` で自動生成することもできる。 `setenv.sh` で生成する場合は下記の手順にしたがう。

1. 下記の例のように `proxy`, `no_proxy` 変数を設定する。

   ```sh
   proxy=http://xxx.xxx.xxx.xxx:xx
   no_proxy=localhost,example.com
   ```

2. `./usr/local/bin/setenv.sh >.env` を実行する。
3. `proxy`, `no_proxy` 変数に基づいて他の変数値も設定される。

#### ビルド

1. 必要に応じてプロキシサーバの証明書を取得し、 `./usr/local/share/ca-certificates/` 下に保存しておく。
2. 下記のコマンドでビルドする。

   ```sh
   docker-compose build
   ```
