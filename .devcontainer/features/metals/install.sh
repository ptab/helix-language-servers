#!/usr/bin/env bash

set -eu

if ! command -v coursier &>/dev/null; then
    echo "Installing Coursier…"
    curl -fL "https://github.com/VirtusLab/coursier-m1/releases/latest/download/cs-aarch64-pc-linux.gz" | gzip -d >./cs
    chmod +x ./cs
    su -c "./cs setup --yes --apps coursier" "$_CONTAINER_USER"
fi

echo "Installing Metals…"
su - -c "coursier install metals" "$_CONTAINER_USER"
