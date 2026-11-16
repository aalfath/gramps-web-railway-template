# Changelog

## 26.11.2 (2026-11-16)

- First release: Gramps Web 26.11.2 (Gramps Web API 3.25.3), `ghcr.io/gramps-project/grampsweb:26.11.2@sha256:80a1d75ca0f67f9203aecca60f7639312a2769fe0af45b34608b0add64f7c07f`.
- One service runs gunicorn and the Celery worker, with all data on one `/data` volume, plus Railway Redis.
- First account created from `OWNER_USERNAME` / `OWNER_PASSWORD`. Self-registration off by default.
