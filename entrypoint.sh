#!/bin/sh

echo "Waiting for postgres master..."

while ! getent hosts postgresql-master ; do
  sleep 1
done

while ! nc -z "${DB_HOST}" "${DB_PORT}"; do
  sleep 1
done

echo "PostgreSQL master started"


echo "Waiting for postgres slave..."

while ! getent hosts postgresql-slave ; do
  sleep 1
done

while ! nc -z "${DB_REPLICA_NAME}" "${DB_PORT}"; do
  sleep 1
done

echo "PostgreSQL slave started"


exec "$@"