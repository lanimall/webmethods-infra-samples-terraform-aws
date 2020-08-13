#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/management/cloudops-init.sh $ARGS

$THISDIR/command_central/cloudops-init.sh $ARGS

$THISDIR/cicd/cloudops-init.sh $ARGS