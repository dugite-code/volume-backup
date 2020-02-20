#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

usage() {
  >&2 echo 'Usage: vbackup <backup|restore|remote>'
  >&2 echo ''
  >&2 echo 'Options:'
  >&2 echo '  -o "rdiff-backup options in quotes"'
  >&2 echo '  -v verbose'
}

backup() {
    >&1 echo -n "Checking /volume "
    if [ -z "$(ls -A /volume)" ]; then
       >&2 echo -e "${RED}[ERROR]${NC} Volume is empty or missing, check if you specified a correct name"
       exit 1
    else
      >&1 echo -e "${GREEN}[OK]${NC}"
    fi

    >&1 echo -n "Checking /backup "
    if [ ! -d "/backup" ]; then
       >&1 echo -e "${RED}[ERROR]${NC}"
       >&2 echo -e "Backup is missing, check if you specified a correct name"
       exit 1
    else
      >&1 echo -e "${GREEN}[OK]${NC}"
    fi

    >&1 echo "Running Backup"

    rdiff-backup $RDIFFOPTS /volume /backup

    >&1 echo -e "${GREEN}[DONE]${NC}"
}

restore() {
    >&1 echo -n "Checking /volume "
    if [ -z "$(ls -A /volume)" ]; then
       >&1 echo -e "${RED}[ERROR]${NC}"
       >&2 echo -e "Volume is empty or missing, check if you specified a correct name"
       exit 1
    else
      >&1 echo -e "${GREEN}[OK]${NC}"
    fi

    >&1 echo -n "Checking /backup "
    if [ -z "$(ls -A /backup)" ]; then
       >&1 echo -e "${RED}[ERROR]${NC}"
       >&2 echo -e "Backup is empty or missing, check if you specified a correct name"
       exit 1
    else
      >&1 echo -e "${GREEN}[OK]${NC}"
    fi

    >&1 echo "Running Restore"

    rdiff-backup $RDIFFOPTS /backup /volume

    >&1 echo -e "${GREEN}[DONE]${NC}"
}

remote() {
    >&1 echo -n "Checking /backup "
    if [ -z "$(ls -A /backup)" ]; then
       >&1 echo -e "${RED}[ERROR]${NC}"
       >&2 echo -e "Backup is empty or missing, check if you specified a correct name"
       exit 1
    else
      >&1 echo -e "${GREEN}[OK]${NC} Backup folder detected"
    fi

    >&1 echo "Working on Remote"

    rdiff-backup $RDIFFOPTS /backup

    >&1 echo -e "${GREEN}[DONE]${NC}"
}

# Needed because sometimes pty is not ready when executing docker-compose run
# See https://github.com/docker/compose/pull/4738 for more details
# TODO: remove after above pull request or equivalent is merged
sleep 1

OPERATION=$1

RDIFFOPTS=""

OPTIND=2

while getopts "h?vo:" OPTION; do
    case "$OPTION" in
    h|\?)
        usage
        exit 0
        ;;
    o)
        if [ -z "$OPTARG" ]; then
          usage
          exit 1
        fi
        RDIFFOPTS="$RDIFFOPTS $OPTARG"
        ;;
    v)
        RDIFFOPTS="$RDIFFOPTS -v5"
        EOLN=1
        ;;
    esac
done

case "$OPERATION" in
"backup" )
backup
;;
"restore" )
if [[ -z $RDIFFOPTS ]]; then
        >&2 echo -e "${RED}[ERROR]${NC} rdiff-backup options missing"
	usage
        exit 0
fi
restore
;;
"remote" )
if [[ -z $RDIFFOPTS ]]; then
	>&2 echo -e "${RED}[ERROR]${NC} rdiff-backup options missing"
        usage
        exit 0
fi
remote
;;
* )
usage
;;
esac

if ! [ -z "$EOLN" ]; then
    >&2 echo
fi
