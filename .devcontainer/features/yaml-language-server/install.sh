#!/usr/bin/env bash

set -eu

if ! command -v yamlfix &>/dev/null; then
    echo "Installing yamlfix…"
    pipx install yamlfix
fi

echo "Installing yaml-language-server…"
npm install -g yaml-language-server
