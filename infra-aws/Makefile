#!/usr/bin/env make

.PHONY: create-iam deploy-iam terminate-iam

create-iam:
	aws cloudformation create-stack --stack-name postgresasapp-iam --template-body file://iam.yaml --parameters file://iam.json --capabilities CAPABILITY_NAMED_IAM

deploy-iam:
	aws cloudformation deploy --stack-name postgresasapp-iam --template-file iam.yaml --capabilities CAPABILITY_NAMED_IAM

terminate-iam:
	aws cloudformation delete-stack --stack-name postgresasapp-iam
