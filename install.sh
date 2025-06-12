USAGE_MSG="""\
Usage: $0 -p [PROCESS NAME] -e [ENDPOINT]\
"""

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

SERVICE_DIRECTORY="/etc/systemd/system"
SCRIPT_DIRECTORY="/usr/bin"

# Checking write abilities
if [ ! -w "$SERVICE_DIRECTORY" ]; then
    echo "Need privileges to write into $SERVICE_DIRECTORY. Are you root?" 1>&2
    exit 1
fi

if [ ! -w "$SCRIPT_DIRECTORY" ]; then
    echo "Need privileges to write into $SERVICE_DIRECTORY. Are you root?" 1>&2
    exit 1
fi

set -xe

cp monitoring.timer.template monitoring.timer
cp monitoring.service.template monitoring.service
sed -i -e "s|ENDPOINT|$ENDPOINT|g" -e "s|PROCESS_NAME|$PROCESS_NAME|g" monitoring.service

cp monitoring.service monitoring.timer "$SERVICE_DIRECTORY"
cp monitoring "$SCRIPT_DIRECTORY"
rm monitoring.service monitoring.timer

systemctl daemon-reload
systemctl enable --now monitoring.timer
