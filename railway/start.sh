#!/bin/sh
# Railway wrapper for the official Gramps Web image.
set -e

DATA=/data
mkdir -p "$DATA/users" "$DATA/media" "$DATA/indexdir" "$DATA/thumbnail_cache" \
  "$DATA/cache/reports" "$DATA/cache/export" "$DATA/cache/request_cache" \
  "$DATA/cache/persistent_cache" "$DATA/grampsdb" "$DATA/backups" "$DATA/secret"

# Flask secret: use the template's GRAMPSWEB_SECRET_KEY, else keep a generated one on the volume.
if [ -z "$GRAMPSWEB_SECRET_KEY" ]; then
  if [ ! -s "$DATA/secret/secret" ]; then
    python3 -c "import secrets;print(secrets.token_urlsafe(32))" | tr -d "\n" > "$DATA/secret/secret"
  fi
  GRAMPSWEB_SECRET_KEY=$(cat "$DATA/secret/secret")
  export GRAMPSWEB_SECRET_KEY
fi

# Public URL (used in e-mail links). Set GRAMPSWEB_BASE_URL yourself for a custom domain.
if [ -z "$GRAMPSWEB_BASE_URL" ] && [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  export GRAMPSWEB_BASE_URL="https://$RAILWAY_PUBLIC_DOMAIN"
fi

# Redis: Celery broker and results on db 0, rate limits on db 1.
if [ -n "$REDIS_URL" ]; then
  R=${REDIS_URL%/}
  export GRAMPSWEB_CELERY_CONFIG__broker_url="${GRAMPSWEB_CELERY_CONFIG__broker_url:-$R/0}"
  export GRAMPSWEB_CELERY_CONFIG__result_backend="${GRAMPSWEB_CELERY_CONFIG__result_backend:-$R/0}"
  export GRAMPSWEB_RATELIMIT_STORAGE_URI="${GRAMPSWEB_RATELIMIT_STORAGE_URI:-$R/1}"
else
  echo "WARNING: REDIS_URL is not set; background jobs (imports, exports, reports) will not run." >&2
fi

# The upstream entrypoint migrates the user database, then runs our run.sh.
exec /docker-entrypoint.sh /railway/run.sh
