[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/gramps-web-1?utm_medium=integration&utm_source=button&utm_campaign=gramps-web)

# Gramps Web on Railway

A one-click Railway template for [Gramps Web](https://www.grampsweb.org/), the open-source web app for collaborative genealogy built on Gramps.

## What it deploys

| Service | Source | Public | Storage |
| --- | --- | --- | --- |
| Gramps Web | this repo (`Dockerfile`, official `ghcr.io/gramps-project/grampsweb:26.11.2` pinned by digest; Gramps Web API 3.25.3) | Yes, HTTPS on port 5000 | Volume at `/data` |
| Redis | Railway Redis | No (private network) | Railway volume |

The Gramps Web service runs the web server (gunicorn, 2 workers) and the Celery background worker (imports, exports, reports, thumbnails) in one container. Both need the same media files and family tree, and Railway can't share a volume between services. The worker restarts by itself if it exits.

Everything lives on the `/data` volume: the family tree database (`/data/grampsdb`), media (`/data/media`), user accounts (`/data/users`), search index, caches and server-side backups (`/data/backups`).

## Variables

| Variable | Default | Notes |
| --- | --- | --- |
| `OWNER_USERNAME` | `owner` | First account, created at first boot with the Admin role |
| `OWNER_PASSWORD` | generated | Password of that account. Find it in the service's Variables tab. Change it in the app after your first login |
| `GRAMPSWEB_SECRET_KEY` | generated | Flask secret. Changing it logs everyone out |
| `REDIS_URL` | `${{Redis.REDIS_URL}}` | Celery broker (db 0) and rate limits (db 1) |
| `PORT` | `5000` | Port gunicorn listens on |

The account is created only when the user database is empty, so changing `OWNER_PASSWORD` later has no effect. Change the password in the app instead.

Set in the Dockerfile, and you can override any of them with a service variable:

- `GRAMPSWEB_TREE=Gramps Web`: name of the family tree, created empty on first boot.
- `GRAMPSWEB_REGISTRATION_DISABLED=true`: no self-registration. The owner adds users under Settings > Manage users.
- `GUNICORN_NUM_WORKERS=2`, `CELERY_CONCURRENCY=1`: raise them on a bigger plan.
- `GRAMPSWEB_PROXY_FIX_X_FOR=1`: trust Railway's proxy, so rate limits apply per client IP.
- `GRAMPSWEB_BASE_URL` is set to `https://$RAILWAY_PUBLIC_DOMAIN` at start. Set it yourself if you add a custom domain.

Optional, not set by the template: e-mail (`GRAMPSWEB_EMAIL_HOST`, `GRAMPSWEB_EMAIL_PORT`, `GRAMPSWEB_EMAIL_HOST_USER`, `GRAMPSWEB_EMAIL_HOST_PASSWORD`, `GRAMPSWEB_DEFAULT_FROM_EMAIL`) for password resets and notifications, AI chat (`GRAMPSWEB_LLM_MODEL` and related settings), and OIDC login. See the [configuration docs](https://www.grampsweb.org/install_setup/configuration/).

## First use

1. Open the service's public URL and sign in as `owner` with `OWNER_PASSWORD`.
2. Import a family tree (Gramps XML `.gramps`, GEDCOM and more) under Import, or start adding people.
3. Add family members under Settings > Manage users.

## Updates

The service builds from this repo's `main` branch. When the Gramps Web pin in the `Dockerfile` is bumped here, Railway shows an "update available" notice on your project, and you choose when to apply it. Read `CHANGELOG.md` first. Back up the `/data` volume (or download a backup from Gramps Web's Export page) before you update.

## Health check

`/` (the web app's index page, served by the API server) answers 200 without login.

## Local run

```sh
docker build -t gramps-web-railway .
docker run -d --name redis redis:8
docker run -p 5000:5000 -v gramps-data:/data --link redis \
  -e REDIS_URL=redis://redis:6379 -e OWNER_PASSWORD=change-me gramps-web-railway
```
