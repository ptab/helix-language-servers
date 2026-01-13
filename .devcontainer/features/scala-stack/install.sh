#!/usr/bin/env bash

set -eu

echo "Installing coursier…"
curl -fL "https://github.com/coursier/coursier/releases/download/v2.1.25-M19/cs-aarch64-pc-linux-static.gz" | gzip -d -c >./cs
chmod +x ./cs
su -c "./cs setup --yes --apps coursier" "$_CONTAINER_USER"

echo "Installing Scala…"
su -c "~/.local/share/coursier/bin/coursier install scala scalac scaladoc scalafix scalafmt" "$_CONTAINER_USER"

echo "Installing sbt…"
su -c "~/.local/share/coursier/bin/coursier install sbt sbtn" "$_CONTAINER_USER"

echo "Installing Metals…"
su -c "~/.local/share/coursier/bin/coursier install metals bloop" "$_CONTAINER_USER"
