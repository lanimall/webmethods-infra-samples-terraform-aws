#!/usr/bin/env bash

ARGS="$@"

./shared/cloudops-apply.sh $ARGS
./workload1a/cloudops-apply.sh $ARGS
./workload1b/cloudops-apply.sh $ARGS