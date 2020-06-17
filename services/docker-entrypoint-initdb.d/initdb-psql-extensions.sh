#!/bin/sh
#
# Docker entrypoint script for custom extension, loaded as per the Docker Alpine
# Linux entrypoint instructions (all custom entrypoint scripts in directory
# /docker-entrypoint-initdb.d).

set -ex

# Perform all actions as $POSTGRES_USER
export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"
export PGDATABASE="${POSTGRES_DB}"

echo "shared_preload_libraries = 'pg_cron'" >> /var/lib/postgresql/data/postgresql.conf
echo "cron.database_name = '${POSTGRES_DB}'" >> /var/lib/postgresql/data/postgresql.conf

# Need to restart the database in order to reload the updated configuration
# file. This does not terminate the Docker container or cause an infinite loop.
# No timeout needs to be specified, this script should be synchronous.
/usr/lib/postgresql/12/bin/pg_ctl restart -D /var/lib/postgresql/data

# Create the 'pg_cron' PostgreSQL extension.
PGPASSWORD=$POSTGRES_PASSWORD psql -U $POSTGRES_USER -d $POSTGRES_DB <<- EOSQL
CREATE EXTENSION IF NOT EXISTS pg_cron;
EOSQL
