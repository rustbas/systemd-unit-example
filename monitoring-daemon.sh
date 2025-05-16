#!/bin/bash

set -e

PROCESS_NAME="$1"
PROCESS_PID=`pgrep --newest ${PROCESS_NAME}`
PID_FILE="$1.pid"

LOG_FILE="monitoring.log"

ENDPOINT="https://test.com/monitoring/test/api"
ENDPOINT="https://putsreq.com/kKddZBA0faGk0Lan61uy"

CURL="curl"
CURL_OPTS="-i -o /dev/null -X POST --max-time 2 -s -w %{http_code}"

if [ -n "${PROCESS_NAME}" ]; then
    if [ -f $PID_FILE ]; then
	PREVIOUS_PID=`cat $PID_FILE`
	if [ $PROCESS_PID != $PREVIOUS_PID ]; then
	    echo "Процесс $PROCESS_NAME был перезапущен с PID=$PROCESS_PID" | tee -a $LOG_FILE
	fi
    fi
    echo ${PROCESS_PID} > $PID_FILE
    
    # There will be request
    echo "Процесс $PROCESS_NAME с PID=$PROCESS_PID работает" | tee -a $LOG_FILE
    # exec "$CURL_COMMAND"
    response=`$CURL $CURL_OPTS -d "name=Pablo" $ENDPOINT`
    echo $response
    # echo $CURL_COMMAND
fi

