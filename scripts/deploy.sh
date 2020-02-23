#!/bin/bash

packer build -machine-readable ./ami.json | tee build.log
AMIID="$(grep 'artifact,0,id' build.log | cut -d, -f6 | cut -d: -f2)"

echo "Generated AMI ID is $AMIID"

aws cloudformation deploy \
    --stack-name ap-vpc \
    --template-file ./../templates/vpc.yml \
    --no-fail-on-empty-changeset

aws cloudformation deploy \
    --stack-name ap-ecs-cluster \
    --template-file ./../templates/ecs-cluster.yml \
    --parameter-overrides ECSAMI=$AMIID \
    --capabilities CAPABILITY_IAM \
    --no-fail-on-empty-changeset

aws cloudformation deploy \
    --stack-name ap-ecs-service-alb \
    --template-file ./../templates/ecs-service-alb.yml \
    --no-fail-on-empty-changeset

aws cloudformation deploy \
    --stack-name ap-ecs-service \
    --template-file ./../templates/ecs-service.yml \
    --no-fail-on-empty-changeset
