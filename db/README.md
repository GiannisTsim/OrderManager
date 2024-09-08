Start MS SQL Server: `docker compose up -d --build`

Run migrations: `docker compose run --build --rm liquibase update`

Rollback migrations: `docker compose run --build --rm liquibase rollback-count 1000`