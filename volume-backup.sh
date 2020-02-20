#!/bin/sh

usage() {
  >&2 echo "Usage: vbackup <backup|restore|remote>"
  >&2 echo ""
  >&2 echo "Options:"
  >&2 echo "  -o options"
  >&2 echo "  -v verbose"
}

backup() {
    >&1 echo "Running Backup"
    if [ -z "$(ls -A /volume)" ]; then
       >&2 echo "Volume is empty or missing, check if you specified a correct name"
       exit 1
    fi

    if [ ! -d "/backup" ]; then
       >&2 echo "Backup is missing, check if you specified a correct name"
       exit 1
    fi

    rdiff-backup $RDIFFOPTS /volume /backup
}

restore() {
    if [ -z "$(ls -A /volume)" ]; then
       >&2 echo "Volume is empty or missing, check if you specified a correct name"
       exit 1
    fi

    if [ -z "$(ls -A /backup)" ]; then
       >&2 echo "Backup is empty or missing, check if you specified a correct name"
       exit 1
    fi

    rdiff-backup $RDIFFOPTS /backup /volume

}

remote() {
    if [ -z "$(ls -A /backup)" ]; then
       >&2 echo "Backup is empty or missing, check if you specified a correct name"
       exit 1
    fi

    rdiff-backup $RDIFFOPTS /backup

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
restore
;;
"remote" )
remote
;;
* )
usage
;;
esac

if ! [ -z "$EOLN" ]; then
    >&2 echo
fi
