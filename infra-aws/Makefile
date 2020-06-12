#!/usr/bin/env make

.PHONY: create-iam deploy-iam terminate-iam wait-iam create-vpc deploy-vpc terminate-vpc wait-vpc

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
