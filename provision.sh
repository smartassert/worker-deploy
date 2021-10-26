#!/usr/bin/env bash

function run_command_until_successful () {
  until "$@"
  do
      echo -e "\033[1mRetrying $*\033[0m"
      sleep 1
  done
}

run_command_until_successful sudo apt-get update
run_command_until_successful sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    gnupg-agent \
    lsb-release \
    software-properties-common

 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

run_command_until_successful sudo apt-get update
run_command_until_successful sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io

run_command_until_successful sudo apt-get autoremove -y
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

DOCKER_COMPOSE_BIN=/usr/local/bin/docker-compose
if [ ! -f "$DOCKER_COMPOSE_BIN" ]; then
  sudo curl \
    -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

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
  docker-compose up -d
sudo docker-compose exec -T app-web php bin/console doctrine:database:create --if-not-exists
sudo docker-compose exec -T app-web php bin/console doctrine:schema:update --force
