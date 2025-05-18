#!/bin/bash

USAGE_MSG="""\
Usage: $0 -p [PROCESS NAME] -e [ENDPOINT]"""

while getopts "hp:e:" OPT; do
    case $OPT in
	p)
	    echo "Using PROCESS_NAME=$OPTARG"
	    PROCESS_NAME="$OPTARG"
	    ;;
	e)
	    echo "Using ENDPOINT=$OPTARG"
	    ENDPOINT="$OPTARG"
	    ;;
	h)
	    echo "$USAGE_MSG"
	    exit 0
	    ;;
	\?)
	    echo "Invalid option: $OPT"
	    echo "$USAGE_MSG"
	    exit 1
    esac
done

if [ -z "$PROCESS_NAME" ]; then
    PROCESS_NAME="test"
    echo "Using default PROCESS_NAME=$PROCESS_NAME"
fi

if [ -z "$ENDPOINT" ]; then
    ENDPOINT="https://test.com/monitoring/test/api"
    echo "Using default ENDPOINT=$ENDPOINT"
fi

# exit 0

PROCESS_PID=`pgrep --newest ${PROCESS_NAME}`
PID_FILE="$PROCESS_NAME.pid"

DATE=`date +%Y-%m-%dT%H:%M:%S`

LOG_FILE="monitoring.log"

ENDPOINT="https://putsreq.com/gGkGyoIaz5GSGjWST1C4"

CURL="curl"
CURL_OPTS="-i -o /dev/null -X POST --max-time 2 -s -w %{http_code}"
CURL_MSG="name=$PROCESS_NAME&pid=$PROCESS_PID&date=$DATE"

if [ -n "${PROCESS_PID}" ]; then
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

