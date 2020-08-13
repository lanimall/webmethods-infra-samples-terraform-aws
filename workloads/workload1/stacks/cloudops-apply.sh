#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/apimgt/cloudops-apply.sh $ARGS

$THISDIR/integrations/cloudops-apply.sh $ARGS