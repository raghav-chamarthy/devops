#!/bin/bash

aws cloudformation deploy \
    --stack-name ap-vpc \
    --template-file ./../templates/vpc.yml \
    --no-fail-on-empty-changeset

aws cloudformation deploy \
    --stack-name ap-ecs-cluster \
    --template-file ./../templates/ecs-cluster.yml \
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
