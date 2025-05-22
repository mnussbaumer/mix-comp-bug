#!/bin/sh

while true; do
    echo "\n\nFinding ip for Hostname: ${HOSTNAME}\n"
    
    RESPONSE=$(curl --unix-socket /var/run/docker.sock http://localhost/containers/json -G --data-urlencode 'filters={"label":["com.docker.compose.service=server"]}')
    NODE_NUMBER=$(echo $RESPONSE | jq --arg hostname "$HOSTNAME" -r '.[] | select(.Id | startswith($hostname)) | .Labels | .["com.docker.compose.container-number"]')
    IP_ADDRESS=$(echo $RESPONSE | jq --arg hostname "$HOSTNAME" -r '.[] | select(.Id | startswith($hostname)) | .NetworkSettings | .Networks | .["bugsbunny_default"] | .IPAddress')

    if [ -n "$IP_ADDRESS" ] && [ "$IP_ADDRESS" != "null" ]; then
	echo "\n\nFound ip address: ${IP_ADDRESS}\nStarting node with --name 'server@${IP_ADDRESS}'\n"
	break;
    fi

    echo "NO IP_ADDRESS YET, retrying in 2s..."
    sleep 2
done

export MIX_BUILD_ROOT="_build_${NODE_NUMBER}"
export MIX_DEPS_PATH="deps_${NODE_NUMBER}"
export MIX_DEBUG=true
# export MIX_OS_CONCURRENCY_LOCK=0

mix deps.get && mix compile

echo -e "CURRENT folder:\n $(ls -la)\n\n$(pwd)\n\n"

elixir --name "server@${IP_ADDRESS}" --cookie "dev_local_cookie" -S mix server.start
