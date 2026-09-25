#!/usr/bin/env bash
set -euo pipefail

VERSIONS=("${@:-7.0.0 7.0.1}")
COMPOSE_FILE="docker/testing/compose.yml"

for version in ${VERSIONS[@]}; do
  project="dmsf-${version//./-}"
  echo
  echo "=== Testing Redmine ${version} ==="

  REDMINE_VERSION="$version" docker compose -p "$project" -f "$COMPOSE_FILE" build redmine
  REDMINE_VERSION="$version" docker compose -p "$project" -f "$COMPOSE_FILE" up -d

  for _ in {1..60}; do
    if curl -fsS "http://localhost:3000/login" >/dev/null 2>&1; then
      break
    fi
    sleep 3
  done

  REDMINE_VERSION="$version" COMPOSE_FILE="$COMPOSE_FILE" ./docker/testing/smoke-test.sh

  docker compose -p "$project" -f "$COMPOSE_FILE" down -v
done
