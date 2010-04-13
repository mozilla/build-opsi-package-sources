#!/bin/bash

LOG="/c/tmp/buildbot-startup.log"
echo "`date` - start of start-buildbot.sh" >> $LOG
MAX_START_TIME=1800 # 30 minutes
RETRY_TIME=30
slave_dir=/e/builds/slave
if [ -d /e/builds/moz2_slave ]; then
    slave_dir=/e/builds/moz2_slave
fi
start_cmd="/d/mozilla-build/python25/scripts/buildbot start $slave_dir"
start_time=`date +%s`
elapsed=0
run=1

while [[ $elasped -lt $MAX_START_TIME ]]; do
    echo "$run: Running $start_cmd" | tee -a $LOG
    $start_cmd
    echo "$run: Ran $start_cmd" >> $LOG
    elapsed=$(( `date +%s` - $start_time ))
    sleep $RETRY_TIME
    run=$(( $run + 1 ))
done

echo "`date` - End of start-buildbot.sh" >> $LOG
