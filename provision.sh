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

mkdir -p /var/basil/source
chown -R www-data:www-data /var/basil/source
mkdir -p /var/basil/tests
chown -R www-data:www-data /var/basil/tests
mkdir -p /var/log
chown -R www-data:www-data /var/log

sudo \
  LOCAL_SOURCE_PATH="$LOCAL_SOURCE_PATH" \
  COMPILER_VERSION="$COMPILER_VERSION" \
  CHROME_RUNNER_VERSION="$CHROME_RUNNER_VERSION" \
  FIREFOX_RUNNER_VERSION="$FIREFOX_RUNNER_VERSION" \
  DELEGATOR_VERSION="$DELEGATOR_VERSION" \
  WORKER_VERSION="$WORKER_VERSION" \
  RESULTS_BASE_URL="$RESULTS_BASE_URL" \
  docker compose up -d

sleep 10
sudo docker compose exec -T app php bin/console doctrine:database:create --if-not-exists
sudo docker compose exec -T app php bin/console doctrine:schema:update --force
