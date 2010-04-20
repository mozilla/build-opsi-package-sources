#!/bin/bash

LOG="/c/tmp/buildbot-sh-startup.log"
# Debugging
set -x
exec >>$LOG 2>&1
trap "echo caught SIGTERM &&& exit 1" SIGTERM
trap "echo caught SIGKILL && exit 1" SIGKILL
trap "echo caught SIGQUIT && exit 1" SIGQUIT
trap "echo caught SIGINT && exit 1" SIGINT
trap "echo caught SIGSEGV && exit 1" SIGSEGV
trap "echo caught SIGHUP && exit 1" SIGHUP

echo "`date` - start of start-buildbot.sh"
MAX_START_TIME=1800 # 30 minutes
RETRY_TIME=30
slave_dir=/e/builds/slave
if [ -d /e/builds/moz2_slave ]; then
    slave_dir=/e/builds/moz2_slave
fi
if [ -d /e/builds/sendchange_slave ]; then
    slave_dir=/e/builds/sendchange_slave
fi
start_cmd="/d/mozilla-build/python25/scripts/buildbot start $slave_dir"
start_time=`date +%s`
elapsed=0
run=1

while [[ $elasped -lt $MAX_START_TIME ]]; do
    echo "$run: Running $start_cmd"
    $start_cmd
    echo "$run: Ran $start_cmd"
    elapsed=$(( `date +%s` - $start_time ))
    sleep $RETRY_TIME
    run=$(( $run + 1 ))
done

echo "`date` - End of start-buildbot.sh"
