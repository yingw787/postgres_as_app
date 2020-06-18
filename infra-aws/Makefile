#!/usr/bin/env make

.PHONY: create-iam deploy-iam terminate-iam wait-iam create-vpc deploy-vpc terminate-vpc wait-vpc create-rds deploy-rds terminate-rds wait-rds create-persist deploy-persist terminate-persist wait-persist

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
