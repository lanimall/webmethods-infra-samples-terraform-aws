#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/apimgt/cloudops-init.sh $ARGS

$THISDIR/integrations/cloudops-init.sh $ARGS