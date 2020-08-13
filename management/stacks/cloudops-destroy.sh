#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/cicd/cloudops-destroy.sh $ARGS

$THISDIR/command_central/cloudops-destroy.sh $ARGS

$THISDIR/management/cloudops-destroy.sh $ARGS