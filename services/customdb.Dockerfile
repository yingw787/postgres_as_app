# This Dockerfile builds 'pg_cron', the data-driven job scheduler, colocated
# with PostgreSQL. Using 'pg_cron' is important for this project to sync state
# between job scheduling and database views with minimal memory and complexity
# footprint.
#
# This Dockerfile also builds `parquet_fdw`, which enables PostgreSQL to
# leverage imported Parquet files to create foreign tables.
#
# TODO: Use a non-root user in order to run PostgreSQL.

FROM postgres:12.3
LABEL application="tinydevcrm-db"

# Update.
RUN apt-get -y update
RUN apt-get -y upgrade

########## START 'pg_cron' ##########

# Install dependencies.
RUN apt-get install -y build-essential
RUN apt-get install -y git
RUN apt-get install -y postgresql-server-dev-12

# Clone the repository and checkout a specific commit.
RUN git clone https://github.com/tinydevcrm/pg_cron.git /home/pg_cron
# Set work directory.
WORKDIR /home/pg_cron
RUN git checkout 2262d9fadedc9fe0ff16b7690b1d4d95772318cb
# Build and install 'pg_cron'.
RUN make
RUN make install

# Remove source deps.
WORKDIR /home
RUN rm -rf /home/pg_cron

# Remove all previous build dependencies.
RUN apt-get remove -y build-essential
RUN apt-get remove -y git
RUN apt-get remove -y postgresql-server-dev-12

########## END 'pg_cron' ##########

# Copy the script which will initialize the replication permissions
COPY /docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
