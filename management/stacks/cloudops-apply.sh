#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/management/cloudops-apply.sh $ARGS

$THISDIR/command_central/cloudops-apply.sh $ARGS

$THISDIR/cicd/cloudops-apply.sh $ARGS