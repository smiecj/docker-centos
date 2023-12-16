# use docker-compose to run services
#!/bin/bash
set -eo pipefail

# get param
command=$1
composefile=$2

# cli
if [ "$CLI" == "docker" ]; then
    CLI="docker-compose"
elif [ "$CLI" == "podman" ]; then
    # pip3 install podman-compose
    CLI="podman-compose"
fi

## build and push image
if [ "${command}" == "run" ]; then
    ${CLI} -f ${composefile} up -d
elif [ "${command}" == "remove" ]; then
    ${CLI} -f ${composefile} down --volumes
else
    echo "command not found!"
fi