# frozen_string_literal: true

# DMSF WebDAV middleware.
require Rails.root.join('plugins', 'redmine_dmsf', 'lib', 'redmine_dmsf', 'webdav', 'custom_middleware').to_s
config.middleware.insert_before ActionDispatch::Cookies, RedmineDmsf::Webdav::CustomMiddleware

# DMSF Active Storage support.
require 'active_storage/engine'
require Rails.root.join('plugins', 'redmine_dmsf', 'lib', 'redmine_dmsf', 'xapian_analyzer').to_s
config.active_storage.service = Rails.env.test? ? :test : :local
config.active_storage.analyzers.append RedmineDmsf::XapianAnalyzer
