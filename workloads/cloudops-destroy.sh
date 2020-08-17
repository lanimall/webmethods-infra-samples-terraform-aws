#!/usr/bin/env bash

ARGS="$@"

./workload1b/cloudops-destroy.sh $ARGS
./workload1a/cloudops-destroy.sh $ARGS
./shared/cloudops-destroy.sh $ARGS