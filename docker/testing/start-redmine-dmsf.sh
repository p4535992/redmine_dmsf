#!/usr/bin/env bash
set -euo pipefail

cd /usr/src/redmine

echo "[dmsf] waiting for PostgreSQL..."
until pg_isready -h "${REDMINE_DB_POSTGRES:-db}" -U "${REDMINE_DB_USERNAME:-redmine}" -d "${REDMINE_DB_DATABASE:-redmine}" >/dev/null 2>&1; do
  sleep 2
done

echo "[dmsf] running DMSF migrations..."
bundle exec rake redmine:plugins:migrate NAME=redmine_dmsf RAILS_ENV=production

echo "[dmsf] configuring ONLYOFFICE test endpoints..."
bundle exec rails runner -e production '
settings = (Setting.plugin_redmine_dmsf || {}).dup
settings["dmsf_onlyoffice_use_official_settings"] = "0"
settings["dmsf_onlyoffice_document_server_url"] = ENV.fetch("ONLYOFFICE_PUBLIC_URL", "http://localhost:8081")
settings["dmsf_onlyoffice_document_server_internal_url"] = ENV.fetch("ONLYOFFICE_INTERNAL_URL", "http://onlyoffice")
settings["dmsf_onlyoffice_redmine_internal_url"] = ENV.fetch("REDMINE_INTERNAL_URL", "http://redmine:3000")
settings["dmsf_onlyoffice_jwt_secret"] = ENV.fetch("ONLYOFFICE_JWT_SECRET", "dmsf-onlyoffice-dev-secret")
settings["dmsf_onlyoffice_jwt_algorithm"] = "HS256"
settings["dmsf_onlyoffice_jwt_header"] = "Authorization"
Setting.plugin_redmine_dmsf = settings
'

echo "[dmsf] Redmine is starting on port 3000"
exec bundle exec rails server -b 0.0.0.0 -p 3000 -e production
