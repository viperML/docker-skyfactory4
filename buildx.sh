#!/usr/bin/env bash
set -eux -o pipefail

docker buildx build \
    --platform "$1" \
    --tag skyfactory-4:latest \
    .
