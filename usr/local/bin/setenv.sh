#!/bin/bash

if [ -n "$PROXY" ]; then
  http_proxy=$PROXY
  https_proxy=$PROXY
  HTTP_PROXY=$http_proxy
  HTTPS_PROXY=$https_proxy
  PROXY_SERVER=${PROXY//http*:\/\//}
  PROXY_HOST=${PROXY_SERVER%%:*}
  PROXY_PORT=${PROXY_SERVER##*:}
  JAVA_TOOL_OPTIONS="-Dhttp.proxyHost=$PROXY_HOST -Dhttp.proxyPort=$PROXY_PORT -Dhttps.proxyHost=$PROXY_HOST -Dhttps.proxyPort=$PROXY_PORT"
fi

if [ -n "$NO_PROXY" ]; then
  no_proxy=$NO_PROXY
  NO_PROXY_PIPE=$(echo "$NO_PROXY" | tr ',' '|')
  JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS} -Dhttp.nonProxyHosts='${NO_PROXY_PIPE}'"
fi

echo "PROXY_HOST=$PROXY_HOST"
echo "PROXY_PORT=$PROXY_PORT"
echo "PROXY_SERVER=$PROXY_SERVER"
echo "PROXY=$PROXY"
echo "http_proxy=$http_proxy"
echo "HTTP_PROXY=$HTTP_PROXY"
echo "https_proxy=$https_proxy"
echo "HTTPS_PROXY=$HTTPS_PROXY"
echo "no_proxy=$no_proxy"
echo "NO_PROXY=$NO_PROXY"
echo "JAVA_TOOL_OPTIONS=\"$JAVA_TOOL_OPTIONS\""
echo "TRUST_HOST=$TRUST_HOST"
