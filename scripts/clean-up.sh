#!/bin/bash

aws cloudformation delete-stack --stack-name ap-ecs-service

aws cloudformation delete-stack --stack-name ap-ecs-service-alb

aws cloudformation delete-stack --stack-name ap-ecs-cluster

aws cloudformation delete-stack --stack-name ap-vpc