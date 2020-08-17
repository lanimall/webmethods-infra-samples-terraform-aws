#!/usr/bin/env bash

ARGS="$@"

./shared/cloudops-init.sh $ARGS
./workload1a/cloudops-init.sh $ARGS
./workload1b/cloudops-init.sh $ARGS