# use docker-compose to run services
#!/bin/bash
set -eo pipefail

# get param
command=$1
composefile=$2

## build and push image
if [ "${command}" == "run" ]; then
    docker-compose -f ${composefile} up -d
elif [ "${command}" == "remove" ]; then
    docker-compose -f ${composefile} down --volumes
else
    echo "command not found!"
fi