#!/usr/bin/env make

.PHONY: create origindb-psql customdb-psql

# Change to your Docker Hub username.
export DOCKER_HUB_USERNAME=yingw7871

up:
	docker-compose up -d --build

down:
	docker-compose down -v

origindb-psql:
	PGPASSWORD=somepassword docker-compose exec origindb psql --username=someuser --db=somedb

customdb-psql:
	PGPASSWORD=mypassword docker-compose exec customdb psql --username=myuser --db=mydb

publish-customdb:
	# Make sure the Docker Hub repository exists before pushing.
	docker build -t $(DOCKER_HUB_USERNAME)/postgresasapp-customdb:latest -f customdb.Dockerfile .
	docker push $(DOCKER_HUB_USERNAME)/postgresasapp-customdb:latest

publish-postgrest:
	# Make sure the Docker Hub repository exists before pushing.
	docker build -t $(DOCKER_HUB_USERNAME)/postgresasapp-postgrest:latest -f postgrest.Dockerfile .
	docker push $(DOCKER_HUB_USERNAME)/postgresasapp-postgrest:latest
