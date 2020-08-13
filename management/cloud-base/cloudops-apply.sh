#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/network/cloudops-apply.sh $ARGS

$THISDIR/security/cloudops-apply.sh $ARGS

$THISDIR/bastion/cloudops-apply.sh $ARGS