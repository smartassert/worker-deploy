#!/usr/bin/env bash

Services=(
  compiler
  chrome-runner
  firefox-runner
  delegator
  postgres
  caddy
  app
)


servicesList=$(
  sudo \
  COMPILER_VERSION="$COMPILER_VERSION" \
  CHROME_RUNNER_VERSION="$CHROME_RUNNER_VERSION" \
  FIREFOX_RUNNER_VERSION="$FIREFOX_RUNNER_VERSION" \
  DELEGATOR_VERSION="$DELEGATOR_VERSION" \
  WORKER_VERSION="$WORKER_VERSION" \
  RESULTS_BASE_URL="$RESULTS_BASE_URL" \
  docker compose ps --services --filter "status=running"
)

for Service in "${Services[@]}"
  do
    if ! echo "$servicesList" | grep "$Service"; then
        echo "$Service not ok"
        docker compose ps
        docker compose logs "$Service"
        exit 1
    fi
  done
