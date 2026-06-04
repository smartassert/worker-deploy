#!/usr/bin/env bash

function run_command_until_successful () {
  until "$@"
  do
      echo -e "\033[1mRetrying $*\033[0m"
      sleep 1
  done
}

# Add Docker's official
run_command_until_successful sudo apt-get update
run_command_until_successful sudo apt-get install -y \
    ca-certificates \
    curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker apt repository
# Intentionally disable shellcheck 1091 which isn't pleased with ". /etc/os-release"
# This is third-party code that works and so is best left as-is
# shellcheck disable=SC1091
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

run_command_until_successful sudo apt update

run_command_until_successful sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

run_command_until_successful sudo apt-get autoremove -y
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
