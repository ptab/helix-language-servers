#!/usr/bin/env bash

set -eu

echo "Installing Taplo…"
curl -fL "https://github.com/tamasfe/taplo/releases/latest/download/taplo-linux-aarch64.gz" | gzip -d >/usr/local/bin/taplo
chmod +x /usr/local/bin/taplo
