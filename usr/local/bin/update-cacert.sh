#!/bin/bash

echo "::: $0 :::"
# for debug:
# env | grep -iE 'proxy|trust|java|jdk|jenkins|docker' | sort -f

# Get JAVA_HOME from the argument (if not defined)
JAVA_HOME=${JAVA_HOME:-$1}
# Add JAVA_HOME to PATH
PATH=$JAVA_HOME/bin:$PATH
# Export JAVA_HOME and PATH
export JAVA_HOME PATH

# 証明書が格納されているパス
CERT_PATH=/usr/local/share/ca-certificates

# 証明書が存在したら、 update-ca-certificates と keytool を実行する
mapfile -t CERTS < <(find "$CERT_PATH" -type f -name "*.crt" -o -name "*.pem")
if [ "${#CERTS[@]}" -gt 0 ]; then
  update-ca-certificates
fi
for cert in "${CERTS[@]}"; do
  if [ ! -f "$JAVA_HOME/lib/security/cacerts" ]; then
    cp -a "$JAVA_HOME/lib/security.default/cacerts" "$JAVA_HOME/lib/security/cacerts"
  fi

  filename="${cert%.*}"
  alias=$(basename "$filename")
  # Import proxy certificate into Java cacerts
  keytool -importcert -file "$cert" -alias "$alias" -trustcacerts -cacerts -storepass changeit -noprompt
done
