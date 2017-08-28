#!/bin/bash
set -e

CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-w' .
docker build -t ecs-demo/bill .
