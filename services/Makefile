#!/usr/bin/env make

.PHONY: create origindb-psql customdb-psql

up:
	docker-compose up -d --build

down:
	docker-compose down -v

origindb-psql:
	PGPASSWORD=somepassword docker-compose exec origindb psql --username=someuser --db=somedb

customdb-psql:
	PGPASSWORD=mypassword docker-compose exec customdb psql --username=myuser --db=mydb

publish-customdb:
	docker build -t yingw7871/postgresasapp-customdb:latest -f customdb.Dockerfile .
	docker push yingw7871/postgresasapp-customdb:latest

publish-postgrest:
	docker build -t yingw7871/postgresasapp-postgrest:latest -f postgrest.Dockerfile .
	docker push yingw7871/postgresasapp-postgrest:latest
