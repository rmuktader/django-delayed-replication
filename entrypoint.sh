#!/bin/sh

echo "Waiting for postgres..."

while ! getent hosts postgresql-master ; do
  sleep 1
done

while ! nc -z "${DB_HOST}" "${DB_PORT}"; do
  sleep 1
done

echo "PostgreSQL started"

exec "$@"