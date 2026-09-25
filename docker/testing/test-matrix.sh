#!/usr/bin/env bash
set -euo pipefail

if (( $# > 0 )); then
  VERSIONS=("$@")
else
  VERSIONS=("7.0.0" "7.0.1")
fi

COMPOSE_FILE="docker/testing/compose.yml"

for version in "${VERSIONS[@]}"; do
  project="dmsf-${version//./-}"
  echo
  echo "=== Testing Redmine ${version} ==="

  cleanup() {
    docker compose -p "$project" -f "$COMPOSE_FILE" down -v || true
  }
  trap cleanup EXIT

  REDMINE_VERSION="$version" docker compose -p "$project" -f "$COMPOSE_FILE" build redmine
  REDMINE_VERSION="$version" docker compose -p "$project" -f "$COMPOSE_FILE" up -d

  ready=0
  for _ in {1..60}; do
    if curl -fsS "http://localhost:3000/login" >/dev/null 2>&1; then
      ready=1
      break
    fi
    sleep 3
  done

  if [[ "$ready" != "1" ]]; then
    docker compose -p "$project" -f "$COMPOSE_FILE" logs redmine
    echo "Redmine ${version} did not become ready" >&2
    exit 1
  fi

  REDMINE_VERSION="$version" \
    COMPOSE_FILE="$COMPOSE_FILE" \
    COMPOSE_PROJECT_NAME="$project" \
    bash docker/testing/smoke-test.sh

  cleanup
  trap - EXIT
done
