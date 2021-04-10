#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

cd ${SCRIPTPATH}/../roles/

for d in */; do
    cd ${d}
    if [ -d ".git" ]; then
        echo
        echo "Directory: ${d}"
        git pull || true
    fi
    cd ..
done
