#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/base/cloudops-init.sh $ARGS