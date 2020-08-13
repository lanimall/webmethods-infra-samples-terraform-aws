#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/security/cloudops-destroy.sh $ARGS

$THISDIR/network/cloudops-destroy.sh $ARGS
