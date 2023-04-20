#!/bin/bash

## EXAMPLE
# export PROXY_SERVER=192.0.2.1:8080
# export TRUST_HOST='example.com:8443,example2.com:443'
# ./install-cert.sh

if [ -z "$PROXY_SERVER" ]; then
  echo "Error: Proxy server is not specified. Please set the PROXY_SERVER environment variable."
  exit 1
fi

TRUST_HOST=${TRUST_HOST:-updates.jenkins.io:443}
IFS=',' read -ra TRUST_HOSTS <<<"${TRUST_HOST}"
if [ "${#TRUST_HOSTS[@]}" -eq 0 ]; then
  echo "Error: No trust hosts specified. Please set the TRUST_HOST environment variable with a comma-separated list of hosts."
  exit 1
fi

for TARGET_ARG in "${TRUST_HOSTS[@]}"; do
  IFS=":" read -ra TARGET_PARTS <<<"${TARGET_ARG}"
  TARGET_HOST=${TARGET_PARTS[0]}

  ## yes 1 | ..
  # 下記のプロンプトに 1 を自動入力する
  # => Server sent 3 certificate(s)
  # => Enter certificate to add to trusted keystore or 'q' to quit: [1]
  yes 1 | java -cp /usr/local/bin InstallCert --proxy="$PROXY_SERVER" "$TARGET_ARG"

  # Picked up JAVA_TOOL_OPTIONS の表示を抑制するために一旦 unset する
  JAVA_TOOL_OPTIONS_BAK=$JAVA_TOOL_OPTIONS
  unset JAVA_TOOL_OPTIONS

  # InstallCert は ${TARGET_HOST}-1 という名前の alias で jssecacerts を出力する
  keytool -exportcert -file "${TARGET_HOST}.cer" -alias "${TARGET_HOST}-1" -keystore jssecacerts -storepass changeit -noprompt

  # Delete the existing certificate with the same alias, if any
  keytool -delete -alias "${TARGET_HOST}-1" -cacerts -storepass changeit -noprompt >/dev/null

  # Import the new certificate
  keytool -importcert -file "${TARGET_HOST}.cer" -alias "${TARGET_HOST}-1" -cacerts -storepass changeit -noprompt

  # JAVA_TOOL_OPTIONS を復元
  export JAVA_TOOL_OPTIONS=$JAVA_TOOL_OPTIONS_BAK
done
