#!/bin/bash

# 証明書が格納されているパス
CERT_PATH=/usr/local/share/ca-certificates

# 証明書が存在したら、 update-ca-certificates と keytool を実行する
mapfile -t CERTS < <(find "$CERT_PATH" -type f -name "*.crt" -o -name "*.pem")
if [ "${#CERTS[@]}" -gt 0 ]; then
  update-ca-certificates
fi
for cert in "${CERTS[@]}"; do
  filename="${cert%.*}"
  alias=$(basename "$filename")
  # Import proxy certificate into Java cacerts
  keytool -importcert -file "$cert" -alias "$alias" -trustcacerts \
    -cacerts -storepass changeit -noprompt
done
