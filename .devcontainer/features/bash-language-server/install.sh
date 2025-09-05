#!/bin/sh -eu

echo "Installing shellcheck..."
apt update && apt install -y shellcheck

echo "Installing bash-language-server..."
npm install -g bash-language-server
