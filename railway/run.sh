#!/bin/sh
set -e
cd /app

# Create the first account (Admin) from OWNER_USERNAME / OWNER_PASSWORD when the user database is empty,
# so the public first-run wizard never opens to strangers.
python3 /railway/create_owner.py

# Background worker (imports, exports, reports, media thumbnails). It must share the /data volume,
# so it runs in this container; the loop restarts it if it exits.
(
  while true; do
    celery -A gramps_webapi.celery worker --loglevel=INFO --concurrency="${CELERY_CONCURRENCY:-1}" || true
    echo "Celery worker exited; restarting in 5 s" >&2
    sleep 5
  done
) &

exec gunicorn -w "${GUNICORN_NUM_WORKERS:-2}" -b "[::]:${PORT:-5000}" gramps_webapi.wsgi:app \
  --timeout "${GUNICORN_TIMEOUT:-120}" --limit-request-line 8190 --preload
