# DMSF + ONLYOFFICE Docker test lab

This directory provides a disposable Redmine environment for testing the DMSF ONLYOFFICE integration from this branch.

The plugin currently declares Redmine **7.0.0 or newer**. The repository CI currently covers Redmine **7.0.0** and **7.0.1**, so those are the default versions used by the local matrix script.

## Services

- Redmine, built from the official Redmine image selected by `REDMINE_VERSION`
- PostgreSQL 16
- ONLYOFFICE Document Server with JWT enabled
- this repository copied into `plugins/redmine_dmsf`

The startup script automatically runs the DMSF plugin migrations and configures the plugin to use the Docker ONLYOFFICE service.

## Start Redmine 7.0.1

From the repository root:

```bash
cp docker/testing/.env.example docker/testing/.env
docker compose --env-file docker/testing/.env -f docker/testing/compose.yml up --build
```

Open:

- Redmine: http://localhost:3000
- ONLYOFFICE: http://localhost:8081

The normal initial Redmine administrator credentials are `admin` / `admin`; Redmine asks you to change the password after the first login.

## Test another Redmine version

Change `REDMINE_VERSION` in `docker/testing/.env`, for example:

```env
REDMINE_VERSION=7.0.0
```

Then rebuild:

```bash
docker compose --env-file docker/testing/.env -f docker/testing/compose.yml up --build
```

## Smoke test

With the stack running:

```bash
chmod +x docker/testing/smoke-test.sh
./docker/testing/smoke-test.sh
```

The smoke test verifies:

1. Redmine responds on the login page.
2. ONLYOFFICE reports healthy.
3. DMSF is registered in Redmine.
4. DMSF has the ONLYOFFICE public/internal URLs and JWT secret configured.

## Test the supported version matrix

```bash
chmod +x docker/testing/test-matrix.sh docker/testing/smoke-test.sh
./docker/testing/test-matrix.sh
```

By default this exercises:

- Redmine 7.0.0
- Redmine 7.0.1

You can pass explicit versions:

```bash
./docker/testing/test-matrix.sh 7.0.0 7.0.1
```

## Useful commands

Reset everything:

```bash
docker compose -f docker/testing/compose.yml down -v
```

Follow Redmine logs:

```bash
docker compose -f docker/testing/compose.yml logs -f redmine
```

Open a shell in Redmine:

```bash
docker compose -f docker/testing/compose.yml exec redmine bash
```

Re-run plugin migrations:

```bash
docker compose -f docker/testing/compose.yml exec redmine \
  bundle exec rake redmine:plugins:migrate NAME=redmine_dmsf RAILS_ENV=production
```

## Manual ONLYOFFICE integration test

1. Log in to Redmine.
2. Create or open a project.
3. Enable the DMSF module in the project settings.
4. Upload a supported Office document into DMSF.
5. Open the document through the ONLYOFFICE action.
6. Edit it and save/close the editor.
7. Confirm that DMSF creates a new revision instead of overwriting the previous one.

For callbacks and document downloads, ONLYOFFICE uses the internal Docker URL `http://redmine:3000`; Redmine uses `http://onlyoffice` for server-to-server calls, while the browser uses `http://localhost:8081`.
