#!/usr/bin/env bash

set -eu

echo "Installing Java…"
mkdir -p /etc/apk/keys/
wget -O /etc/apk/keys/adoptium.rsa.pub https://packages.adoptium.net/artifactory/api/security/keypair/public/repositories/apk
echo 'https://packages.adoptium.net/artifactory/apk/alpine/main' >>/etc/apk/repositories
apk add temurin-21-jdk
