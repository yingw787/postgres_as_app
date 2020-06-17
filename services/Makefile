#!/usr/bin/env make

.PHONY: create origindb-psql customdb-psql

create:
	docker-compose up -d --build

origindb-psql:
	PGPASSWORD=somepsasword docker-compose exec origindb psql --username=someuser --db=somedb

customdb-psql:
	PGPASSWORD=mypsasword docker-compose exec customdb psql --username=myuser --db=mydb
