#!/usr/bin/env make

.PHONY: create-iam deploy-iam terminate-iam wait-iam create-vpc deploy-vpc terminate-vpc wait-vpc create-rds deploy-rds terminate-rds wait-rds create-persist deploy-persist terminate-persist wait-persist create-compute deploy-compute terminate-compute wait-compute recreate-compute rds-psql compute-psql compute-http

# Uncommon the line below if you're using the IAM user created here. Otherwise,
# replace with your preferred AWS profile, inline '--profile $AWS_PROFILE' into
# the relevant commands, or separately export within your shell.
# export AWS_PROFILE=postgresasapp

create-iam:
	aws cloudformation create-stack --stack-name postgresasapp-iam --template-body file://iam.yaml --parameters file://iam.json --capabilities CAPABILITY_NAMED_IAM

deploy-iam:
	aws cloudformation deploy --stack-name postgresasapp-iam --template-file iam.yaml --capabilities CAPABILITY_NAMED_IAM

terminate-iam:
	aws cloudformation delete-stack --stack-name postgresasapp-iam

wait-iam:
	aws cloudformation wait stack-create-complete --stack-name postgresasapp-iam

create-vpc:
	aws cloudformation create-stack --stack-name postgresasapp-vpc --template-body file://vpc.yaml --capabilities CAPABILITY_NAMED_IAM

deploy-vpc:
	aws cloudformation deploy --stack-name postgresasapp-vpc --template-file vpc.yaml --capabilities CAPABILITY_NAMED_IAM

terminate-vpc:
	aws cloudformation delete-stack --stack-name postgresasapp-vpc

wait-vpc:
	aws cloudformation wait stack-create-complete --stack-name postgresasapp-vpc

create-rds:
	aws cloudformation create-stack --stack-name postgresasapp-rds --template-body file://rds.yaml --parameters file://rds.json --capabilities CAPABILITY_NAMED_IAM

deploy-rds:
	aws cloudformation deploy --stack-name postgresasapp-rds --template-file rds.yaml --capabilities CAPABILITY_NAMED_IAM

terminate-rds:
	aws cloudformation delete-stack --stack-name postgresasapp-rds

wait-rds:
	aws cloudformation wait stack-create-complete --stack-name postgresasapp-rds

create-persist:
	aws cloudformation create-stack --stack-name postgresasapp-persist --template-body file://persist.yaml --capabilities CAPABILITY_NAMED_IAM

deploy-persist:
	aws cloudformation deploy --stack-name postgresasapp-persist --template-file persist.yaml --capabilities CAPABILITY_NAMED_IAM

terminate-persist:
	aws cloudformation delete-stack --stack-name postgresasapp-persist

wait-persist:
	aws cloudformation wait stack-create-complete --stack-name postgresasapp-persist

create-compute:
	aws cloudformation create-stack --stack-name postgresasapp-compute --template-body file://compute.yaml --parameters file://compute.json --capabilities CAPABILITY_NAMED_IAM

deploy-compute:
	aws cloudformation deploy --stack-name postgresasapp-compute --template-file compute.yaml --capabilities CAPABILITY_NAMED_IAM

terminate-compute:
	aws cloudformation delete-stack --stack-name postgresasapp-compute

wait-compute:
	aws cloudformation wait stack-create-complete --stack-name postgresasapp-compute

recreate-compute:
	$(MAKE) terminate-compute && aws cloudformation wait stack-delete-complete --stack-name postgresasapp-compute && $(MAKE) create-compute





rds-psql: RDS_PSQL_CONN_URI=$(shell aws cloudformation describe-stacks --stack-name postgresasapp-rds --query "Stacks[0].Outputs[?OutputKey=='PostgresConnectionString'].OutputValue" --output text)
rds-psql:
	@psql $(RDS_PSQL_CONN_URI)

compute-psql: ECS_PSQL_CONN_URI=$(shell aws cloudformation describe-stacks --stack-name postgresasapp-compute --query "Stacks[0].Outputs[?OutputKey=='PostgresConnectionString'].OutputValue" --output text)
compute-psql:
	@psql $(ECS_PSQL_CONN_URI)

compute-http: POSTGREST_URL=$(shell aws cloudformation describe-stacks --stack-name postgresasapp-compute --query "Stacks[0].Outputs[?OutputKey=='PostgRESTURL'].OutputValue" --output text)
compute-http:
	xdg-open http://$(POSTGREST_URL)
