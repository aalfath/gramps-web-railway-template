# Gramps Web (frontend 26.11.2 + Gramps Web API 3.25.3), official image pinned by digest.
FROM ghcr.io/gramps-project/grampsweb:26.11.2@sha256:80a1d75ca0f67f9203aecca60f7639312a2769fe0af45b34608b0add64f7c07f

# Keep every piece of state on one Railway volume mounted at /data.
# (Gramps addons stay in /root/gramps, which is part of the image.)
ENV GRAMPSWEB_TREE="Gramps Web" \
    GRAMPSWEB_USER_DB_URI=sqlite:////data/users/users.sqlite \
    GRAMPSWEB_MEDIA_BASE_DIR=/data/media \
    GRAMPSWEB_SEARCH_INDEX_DB_URI=sqlite:////data/indexdir/search_index.db \
    GRAMPSWEB_THUMBNAIL_CACHE_CONFIG__CACHE_DIR=/data/thumbnail_cache \
    GRAMPSWEB_REQUEST_CACHE_CONFIG__CACHE_DIR=/data/cache/request_cache \
    GRAMPSWEB_PERSISTENT_CACHE_CONFIG__CACHE_DIR=/data/cache/persistent_cache \
    GRAMPSWEB_REPORT_DIR=/data/cache/reports \
    GRAMPSWEB_EXPORT_DIR=/data/cache/export \
    GRAMPSWEB_BACKUP_DIR=/data/backups \
    GRAMPS_DATABASE_PATH=/data/grampsdb \
    GRAMPSWEB_REGISTRATION_DISABLED=true \
    GRAMPSWEB_PROXY_FIX_X_FOR=1 \
    GUNICORN_NUM_WORKERS=2 \
    CELERY_CONCURRENCY=1 \
    PORT=5000

COPY railway/ /railway/
RUN chmod +x /railway/start.sh /railway/run.sh

EXPOSE 5000
ENTRYPOINT ["/railway/start.sh"]
