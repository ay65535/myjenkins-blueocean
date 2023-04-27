#!/bin/bash

## EXAMPLE
# export PROXY_SERVER=192.0.2.1:8080
# export TRUST_HOST='example.com:8443,example2.com:443'
# ./install-cert.sh

echo "::: $0 :::"
# for debug:
# env | grep -iE 'proxy|trust|java|jdk|jenkins|docker' | sort -f

# Get JAVA_HOME from the argument (if not defined)
JAVA_HOME=${JAVA_HOME:-$1}
# Add JAVA_HOME to PATH
PATH=$JAVA_HOME/bin:$PATH
# Export JAVA_HOME and PATH
export JAVA_HOME PATH

# if $PROXY_SERVER not set, then skip
if [ -z "$PROXY_SERVER" ]; then
  if [ -z "$http_proxy" ]; then
    echo "Skip: PROXY_SERVER / http_proxy is not set."
    exit 0
  else
    # IPアドレス or ホスト名部分だけ抽出
    PROXY_SERVER=${http_proxy#*//}
    PROXY_SERVER=${PROXY_SERVER%/}
  fi
fi

if [ ! -f "$JAVA_HOME/lib/security/cacerts" ]; then
  cp -a "$JAVA_HOME/lib/security.default/cacerts" "$JAVA_HOME/lib/security/cacerts"
fi

TRUST_HOST=${TRUST_HOST:-updates.jenkins.io:443}
IFS=',' read -ra TRUST_HOSTS <<<"${TRUST_HOST}"

for TARGET_ARG in "${TRUST_HOSTS[@]}"; do
  IFS=":" read -ra TARGET_PARTS <<<"${TARGET_ARG}"
  TARGET_HOST=${TARGET_PARTS[0]}

  # > yes 1 | ... プロンプトに 1 を自動入力する (サーバーから取得した証明書のうち1番目をインポート)
  # >/dev/null ... 取得した証明書の内容がstdoutに大量に表示されるので抑制
  # 2>&1 | grep -v 'Picked up JAVA_TOOL_OPTIONS' ... JAVA_TOOL_OPTIONSの検出通知がstderrに表示されてうるさいので抑制
  yes 1 | java -cp /usr/local/bin InstallCert --proxy="$PROXY_SERVER" "$TARGET_ARG" 2>&1 >/dev/null | grep -v 'Picked up JAVA_TOOL_OPTIONS'

  # InstallCert は ${TARGET_HOST}-1 という名前の alias で jssecacerts を出力する
  keytool -exportcert -file "${TARGET_HOST}.cer" -alias "${TARGET_HOST}-1" -keystore jssecacerts -storepass changeit -noprompt 2>&1 | grep -v 'Picked up JAVA_TOOL_OPTIONS'

  # Delete the existing certificate with the same alias, if any
  keytool -delete -alias "${TARGET_HOST}-1" -cacerts -storepass changeit -noprompt 2>&1 >/dev/null | grep -v 'Picked up JAVA_TOOL_OPTIONS'

  # Import the new certificate
  keytool -importcert -file "${TARGET_HOST}.cer" -alias "${TARGET_HOST}-1" -cacerts -storepass changeit -noprompt 2>&1 | grep -v 'Picked up JAVA_TOOL_OPTIONS'

  # Delete intermediate file
  rm "${TARGET_HOST}.cer"
done

# Delete intermediate file
rm jssecacerts
