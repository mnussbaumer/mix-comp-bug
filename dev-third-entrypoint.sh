#!/bin/sh

while true; do
    echo "\n\nFinding ip for Hostname: ${HOSTNAME}\n"
    
    RESPONSE=$(curl --unix-socket /var/run/docker.sock http://localhost/containers/json -G --data-urlencode 'filters={"label":["com.docker.compose.service=third"]}')
    NODE_NUMBER=$(echo $RESPONSE | jq --arg hostname "$HOSTNAME" -r '.[] | select(.Id | startswith($hostname)) | .Labels | .["com.docker.compose.container-number"]')

    IP_ADDRESS=$(echo $RESPONSE | jq --arg hostname "$HOSTNAME" -r '.[] | select(.Id | startswith($hostname)) | .NetworkSettings | .Networks | .["bugsbunny_default"] | .IPAddress')

    if [ -n "$IP_ADDRESS" ] && [ "$IP_ADDRESS" != "null" ]; then
	echo "\n\nFound ip address: ${IP_ADDRESS}\nStarting node with --name 'queues_server@${IP_ADDRESS}'\n"
	break;
    fi

    echo "NO IP_ADDRESS YET, retrying in 2s..."
    sleep 2
done

export MIX_BUILD_ROOT="_build_third_${NODE_NUMBER}"
export MIX_DEPS_PATH="deps_third_${NODE_NUMBER}"
# export MIX_OS_CONCURRENCY_LOCK=0
# export MIX_DEBUG=true

mix deps.get && mix compile

elixir --name "third@${IP_ADDRESS}" --cookie "dev_local_cookie" -S mix third.start
