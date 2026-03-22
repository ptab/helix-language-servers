#!/usr/bin/env bash
set -eu

user_home="$(eval echo ~"$_CONTAINER_USER")"
lsp_version="262.2310.0"
kotlin_lsp_dir="$user_home"/kotlin-lsp
kotlin_release="https://download-cdn.jetbrains.com/kotlin-lsp/$lsp_version/kotlin-lsp-$lsp_version-linux-aarch64.zip"

echo "Setting up permissions for shared Gradle cache volume…"
su - "$_CONTAINER_USER" <<EOF
    mkdir -p $user_home/.gradle
EOF

echo "Installing kotlin-lsp…"
su - "$_CONTAINER_USER" <<EOF
    pushd $user_home

    curl -fL -o kotlin.zip "$kotlin_release" &&
        unzip kotlin.zip -d "$kotlin_lsp_dir" &&
        rm kotlin.zip

    # kotlin-lsp ships with a JRE that is not compiled for an Alpine distribution,
    # this makes it use the system installed one
    sed -i 's/exec "\$JAVA_BIN"/exec \"\$(which java)"/' $kotlin_lsp_dir/kotlin-lsp.sh
    popd
EOF

ln -s "$kotlin_lsp_dir"/kotlin-lsp.sh /usr/local/bin/kotlin-lsp
chmod +x /usr/local/bin/kotlin-lsp
