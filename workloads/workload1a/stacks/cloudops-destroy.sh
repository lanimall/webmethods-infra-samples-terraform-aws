#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/apimgt/cloudops-destroy.sh $ARGS

$THISDIR/integrations/cloudops-destroy.sh $ARGS