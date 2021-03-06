# volume-backup

An utility to backup and restore docker volumes using rdiff-backup

**Note**: Make sure no container is using the volume before backup or restore, otherwise your data might be damaged. See [Miscellaneous](#miscellaneous) for instructions.

## Build with tag

`docker image build -t vbackup:1.0 .`

## Backup

```bash
docker run -v [volume-name]:/volume -v [backup-dir]:/backup --rm vbackup:1.0 backup
```

## Restore

`-r rdiff-backup restore-as-of variable. Must be used with restore`

```bash
docker run -v [volume-name]:/volume -v [backup-dir]:/backup --rm vbackup:1.0 restore -r 10D
```

## Remote (For removing old files in your backups)

`-t rdiff-backup remove-older-than variable. Must be used with remote`

```bash
docker run -v [volume-name]:/volume -v [backup-dir]:/backup --rm vbackup:1.0 remote -t 20B
```

## Miscellaneous

1. Find and pause all containers using a volume (to stop them before backing-up)

```bash
docker ps -a --filter volume=[volume-name] -q | while read x ; do docker pause $x ; done
```

1. Find and unpause all containers using a volume

```bash
docker ps -a --filter volume=[volume-name] -q | while read x ; do docker unpause $x ; done
```
