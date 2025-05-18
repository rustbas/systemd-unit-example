#!/bin/bash

PROCESS_NAME="$1"
PROCESS_PID=`pgrep --newest ${PROCESS_NAME}`
PID_FILE="$1.pid"

DATE=`date +%Y-%m-%dT%H:%M:%S`

LOG_FILE="monitoring.log"

ENDPOINT="https://test.com/monitoring/test/api"
ENDPOINT="https://putsreq.com/kKddZBA0faGk0Lan61uy"

CURL="curl"
CURL_OPTS="-i -o /dev/null -X POST --max-time 2 -s -w %{http_code}"
CURL_MSG="name=$PROCESS_NAME&pid=$PROCESS_PID&date=$DATE"

while getopts ":p:e:" opt; do
    case $opt in
	p)
	    echo "Using PROCESS_NAME=$opt"
	    ;;
	e)
	    echo "Using ENDPOINT=$opt"
	    ;;
	\?)
	    echo "Invalid option: $opt"
    esac
done

if [ -n "${PROCESS_NAME}" ]; then
    if [ -f $PID_FILE ]; then
	PREVIOUS_PID=`cat $PID_FILE`
	if [ $PROCESS_PID != $PREVIOUS_PID ]; then
	    echo "Процесс $PROCESS_NAME был перезапущен с PID=$PROCESS_PID. Date: $DATE" | tee -a $LOG_FILE
	fi
    fi
    echo ${PROCESS_PID} > $PID_FILE
    
    response=`$CURL $CURL_OPTS -d "$CURL_MSG" $ENDPOINT`
    if [ $? -ne 0 ] || [ "$response" != "200" ]; then
	MSG="Сервер $ENDPOINT не доступен. HTTP_CODE=$response"
	echo $MSG | tee -a $LOG_FILE
    fi
fi

