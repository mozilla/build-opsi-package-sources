#!/bin/bash

PATIENCE=120 # Amount of time before esclating the kill attempts
MAX_START_TIME=600 # Amount of time waiting for OPSI to start before giving up
PID=`cat /var/run/opsiconfd/opsiconfd.pid`
OPSI_INIT_SCRIPT="/etc/init.d/opsiconfd"

is_running() {
    # Returns 0 when opsi is running, 1 when it is not
    ps auxwww | grep -vE '(grep|restart)' | grep -q opsiconfd
    running=$?
    if [ $running -eq 0 ]; then
        return 1
    else
        return 0
    fi
}

start_opsi() {
    $OPSI_INIT_SCRIPT start
    total_time=0
    is_running
    running=$?
    while [ $running -eq 0 ]; do
        if [ $total_time -gt $MAX_START_TIME ]; then
            echo "Couldn't start opsi in $MAX_START_TIME, giving up..."
            return 1
        fi
        sleep 2
        total_time=$(($total_time + 2))
        is_running
        running=$?
    done
    echo "OPSI started successfully"
    return 0
}

wait_for_process_to_die() {
    total_time=0
    sleep 2
    is_running
    running=$?
    while [ $running -gt 0 ]; do
        if [ $total_time -gt $PATIENCE ]; then
            return 1
        fi
        sleep 2
        total_time=$(($total_time + 2))
        is_running
        running=$?
    done
    return 0
}

# If OPSI is running, kill it.

$OPSI_INIT_SCRIPT stop
wait_for_process_to_die
ret=$?
if [ $ret -gt 0 ]; then
    echo "OPSI didn't shut down from the init script....trying SIGTERM"
    kill -15 $PID
    wait_for_process_to_die
    ret=$?
    if [ $ret -gt 0 ]; then
        echo "OPSI didn't shut down from SIGTERM....trying SIGKILL"
        kill -9 $PID
        wait_for_process_to_die
        ret=$?
        if [ $ret -gt 0 ]; then
            echo "Couldn't kill OPSI, giving up...."
            exit 1
        fi
    fi
fi

start_opsi
ret=$?
exit $ret
