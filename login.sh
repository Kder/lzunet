#!/bin/bash
SCRIPT=`readlink -f $0`
SCRIPTPATH=`dirname $SCRIPT`
pushd $SCRIPTPATH > /dev/null
python startup.py
popd > /dev/null

