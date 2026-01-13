#!/usr/bin/env bash

set -eu

echo "Installing bash-language-server…"
npm install -g bash-language-server

echo "Installing shfmt…"
apk add shfmt

echo "Installing shellcheck…"
apk add shellcheck
