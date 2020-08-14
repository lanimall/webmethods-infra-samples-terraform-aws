#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/stacks/cloudops-apply.sh $ARGS