# use docker buildx build and/or push image
#!/bin/bash
set -eo pipefail

# to skip env (will cause syntax error in expression)
skip_env_key_regex="(LS_COLORS|PATH|SSH_CONNECTION|LANG)"

# get param
command=$1
platform=$2
dockerfile=$3
image_tag=$4
main_path=$5

# check param

# get all dockerfile arg
args=$(cat ${dockerfile} | grep -E "^ARG " | sed 's#ARG ##g' | sed 's#=.*##g')

# generate build-arg
build_arg_key="--build-arg"
build_arg=""
# get all env and make build args
env_keys=`printenv | sed "s#=.*##g"`

for env_key in ${env_keys[@]}
do
    if [[ "${env_key}" =~ ${skip_env_key_regex} ]]; then
        continue
    fi

    arg_key_filter_ret=$(echo ${args} | grep -w "${env_key}") || true
    if [ -n "${arg_key_filter_ret}" ]; then
        build_arg="${build_arg} ${build_arg_key} ${env_key}=${!env_key}"
    fi
done

# multiple image tag
tag_key="-t"
IFS=',' read -r -a image_tag_arr <<< "${image_tag}"
image_tag=""
for current_image_tag in ${image_tag_arr[@]}
do
    image_tag="${image_tag} ${tag_key} ${current_image_tag}"
done

# multiple platform
if [ -n "${platform}" ]; then
    platform="--platform ${platform}"
fi

## build and push image
if [ "${command}" == "build" ]; then
    docker buildx build --output type=docker ${platform} ${build_arg} -f ${dockerfile} ${image_tag} ${main_path}
else
    docker buildx build ${build_arg} ${platform} --no-cache -f ${dockerfile} ${image_tag} ${main_path} --push
fi