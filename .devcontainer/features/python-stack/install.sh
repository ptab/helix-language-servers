#!/usr/bin/env bash

set -eu

echo "Installing Python…"
apk add \
    python3 \
    pipx \
    ruff

echo "Installing pylsp…"
pipx install --global python-lsp-server
