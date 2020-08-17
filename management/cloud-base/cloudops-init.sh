#!/usr/bin/env bash
set -e

THIS=`basename $0`
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/../.."
EXIT_STATUS=0

## load project common
. $BASEDIR/common/scripts/terraform_common.sh

ARGS="$@"

command_filename="$THIS"
commands=("$THISDIR/security/$command_filename $ARGS" "$THISDIR/network/$command_filename $ARGS" "$THISDIR/nat_ha/$command_filename $ARGS" "$THISDIR/bastion/$command_filename $ARGS")

command_looping "${commands[@]}" || EXIT_STATUS=$?

exit $EXIT_STATUS