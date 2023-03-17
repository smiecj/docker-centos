#!/bin/bash
set -eo pipefail

init_repo_scripts=$(find / -maxdepth 1 -name "init_*_repo")

if [ -n "${NET}" ]; then
    set -a
    source /repo_${NET}
    for current_repo_script in "${init_repo_scripts[@]}"
    do
        sh /${current_repo_script}
    done
    set +a
fi