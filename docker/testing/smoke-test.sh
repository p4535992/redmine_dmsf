#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-docker/testing/compose.yml}"

echo "[smoke] checking Redmine HTTP endpoint..."
curl -fsS "http://localhost:${REDMINE_PORT:-3000}/login" >/dev/null

echo "[smoke] checking ONLYOFFICE health endpoint..."
curl -fsS "http://localhost:${ONLYOFFICE_PORT:-8081}/healthcheck" >/dev/null

echo "[smoke] checking DMSF registration and ONLYOFFICE settings..."
docker compose -f "$COMPOSE_FILE" exec -T redmine bundle exec rails runner -e production '
abort "DMSF plugin is not registered" unless Redmine::Plugin.registered_plugins.key?(:redmine_dmsf)
settings = Setting.plugin_redmine_dmsf || {}
abort "ONLYOFFICE URL missing" if settings["dmsf_onlyoffice_document_server_url"].to_s.empty?
abort "ONLYOFFICE internal URL missing" if settings["dmsf_onlyoffice_document_server_internal_url"].to_s.empty?
abort "Redmine internal URL missing" if settings["dmsf_onlyoffice_redmine_internal_url"].to_s.empty?
abort "JWT secret missing" if settings["dmsf_onlyoffice_jwt_secret"].to_s.empty?
puts "DMSF + ONLYOFFICE smoke test OK"
'

echo "[smoke] all checks passed"
