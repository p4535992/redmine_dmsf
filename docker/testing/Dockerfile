ARG REDMINE_VERSION=7.0.1
FROM redmine:${REDMINE_VERSION}

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       curl \
       libpq-dev \
       libxapian-dev \
       libreoffice \
       postgresql-client \
       xapian-omega \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/redmine

COPY . /usr/src/redmine/plugins/redmine_dmsf
COPY docker/testing/additional_environment.rb /usr/src/redmine/config/additional_environment.rb
COPY docker/testing/storage.yml /usr/src/redmine/config/storage.yml
COPY docker/testing/start-redmine-dmsf.sh /usr/local/bin/start-redmine-dmsf

RUN chmod +x /usr/local/bin/start-redmine-dmsf \
    && bundle install \
    && bin/rails active_storage:install

CMD ["/usr/local/bin/start-redmine-dmsf"]
