#!/usr/bin/env bash

INITIAL_DIRECTORY=$PWD

# Setup
sudo \
  LOCAL_SOURCE_PATH="$LOCAL_SOURCE_PATH" \
  COMPILER_VERSION="$COMPILER_VERSION" \
  CHROME_RUNNER_VERSION="$CHROME_RUNNER_VERSION" \
  FIREFOX_RUNNER_VERSION="$FIREFOX_RUNNER_VERSION" \
  DELEGATOR_VERSION="$DELEGATOR_VERSION" \
  WORKER_VERSION="$WORKER_VERSION" \
  RESULTS_BASE_URL="$RESULTS_BASE_URL" \
  docker compose -f docker-compose.yml -f self-test/services.yml build

sudo \
  LOCAL_SOURCE_PATH="$LOCAL_SOURCE_PATH" \
  COMPILER_VERSION="$COMPILER_VERSION" \
  CHROME_RUNNER_VERSION="$CHROME_RUNNER_VERSION" \
  FIREFOX_RUNNER_VERSION="$FIREFOX_RUNNER_VERSION" \
  DELEGATOR_VERSION="$DELEGATOR_VERSION" \
  WORKER_VERSION="$WORKER_VERSION" \
  RESULTS_BASE_URL="$RESULTS_BASE_URL" \
  docker compose -f docker-compose.yml -f self-test/services.yml up -d

cd ./self-test/app || exit

sudo apt-get -qq update > /dev/null
sudo apt-get -qq install php8.1-cli php8.1-curl php8.1-dom php8.1-mbstring zip > /dev/null
curl https://getcomposer.org/download/latest-stable/composer.phar --output composer.phar --silent

if ! php composer.phar update --quiet; then
    exit 1
fi

if ! php composer.phar check-platform-reqs --quiet; then
    exit 1
fi

# Run
php ./vendor/bin/phpunit ./src/ApplicationTest.php
LAST_EXIT_CODE=$?

sudo docker logs callback-receiver | php ./vendor/bin/phpunit --stop-on-failure ./src/CallbackReceiverLogTest.php
LAST_EXIT_CODE=$?

## Teardown
cd "$INITIAL_DIRECTORY" || exit

sudo \
  LOCAL_SOURCE_PATH="non-empty-value" \
  COMPILER_VERSION="non-empty-value" \
  CHROME_RUNNER_VERSION="non-empty-value" \
  FIREFOX_RUNNER_VERSION="non-empty-value" \
  DELEGATOR_VERSION="non-empty-value" \
  WORKER_VERSION="non-empty-value" \
  RESULTS_BASE_URL="non-empty-value" \
  docker compose stop http-fixtures callback-receiver

sudo \
  LOCAL_SOURCE_PATH="$LOCAL_SOURCE_PATH" \
  COMPILER_VERSION="$COMPILER_VERSION" \
  CHROME_RUNNER_VERSION="$CHROME_RUNNER_VERSION" \
  FIREFOX_RUNNER_VERSION="$FIREFOX_RUNNER_VERSION" \
  DELEGATOR_VERSION="$DELEGATOR_VERSION" \
  WORKER_VERSION="$WORKER_VERSION" \
  RESULTS_BASE_URL="$RESULTS_BASE_URL" \
  docker compose up -d --remove-orphans

DB_TABLES=(
  "job"
  "test"
  "resource_reference"
  "worker_event"
  "source"
)

for TABLE in "${DB_TABLES[@]}"
  do
    echo "Removing all from $TABLE"

    sudo \
      LOCAL_SOURCE_PATH="non-empty-value" \
      COMPILER_VERSION="non-empty-value" \
      CHROME_RUNNER_VERSION="non-empty-value" \
      FIREFOX_RUNNER_VERSION="non-empty-value" \
      DELEGATOR_VERSION="non-empty-value" \
      WORKER_VERSION="non-empty-value" \
      RESULTS_BASE_URL="non-empty-value" \
      docker compose exec -T -e PGPASSWORD=password! postgres psql -U postgres -d worker-db -c "DELETE FROM ${TABLE}"

  done

sudo apt-get -qq -y remove php8.1-cli php8.1-curl php8.1-dom php8.1-mbstring zip > /dev/null
sudo apt-get -qq -y autoremove > /dev/null
sudo rm -Rf ./self-test

if [ 0 -ne "$LAST_EXIT_CODE" ]; then
    exit 1
fi
