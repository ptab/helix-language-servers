#!/usr/bin/env sh

set -eu

echo "Setup repositories…"
apk update

echo "Installing base features…"
apk add \
    bash \
    coreutils \
    curl \
    diffutils \
    fd \
    parallel \
    yq \
    wget

echo "Installing Node…"
apk add npm
