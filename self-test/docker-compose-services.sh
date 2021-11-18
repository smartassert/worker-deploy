#!/usr/bin/env bash

Services=(
  compiler
  chrome-runner
  firefox-runner
  delegator
  postgres
  nginx
  app-web
)

for Service in "${Services[@]}"
  do
    if ! sudo docker-compose ps --services --filter "status=running" | grep "$Service"; then
        echo "$Service not ok"
        docker-compose ps
        docker-compose logs "$Service"
        exit 1
    fi
  done
