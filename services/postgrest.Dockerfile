FROM debian:buster-20200514

# Set build arguments.
ARG DEBIAN_FRONTEND=noninteractive

# Get package lists, important for getting 'curl' and such.
RUN apt-get -y update

# Install build dependencies.
RUN apt-get install -y curl
RUN apt-get install -y xz-utils

# Install PostgREST.
RUN curl -L https://github.com/PostgREST/postgrest/releases/download/v7.0.1/postgrest-v7.0.1-linux-x64-static.tar.xz -o /tmp/postgrest-v7.0.1-linux-x64-static.tar.xz
RUN tar xfJ /tmp/postgrest-v7.0.1-linux-x64-static.tar.xz -C /usr/local/bin

# Configure PostgREST.
COPY postgrest.conf /usr/local/postgrest.conf

# Run PostgREST.
CMD [ "/usr/local/bin/postgrest", "/usr/local/postgrest.conf" ]
