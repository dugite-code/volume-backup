FROM alpine

RUN apk update
RUN apk add --no-cache dumb-init xz tar
RUN apk add rdiff-backup

COPY volume-backup.sh /

ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/volume-backup.sh" ]
