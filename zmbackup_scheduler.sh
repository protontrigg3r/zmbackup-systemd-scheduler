#!/bin/bash

# Set Zimbra user
ZIMBRA="zimbra"
# Get day of the week
TODAY=$(date +%u)
# Remote partition mounting command
MOUNT_COMMAND=""
# Umount command
UMOUNT_COMMAND=""
# Full backup command
FULL_COMMAND="zmbackup -f"
# Incremental backup command
INCREMENTAL_COMMAND="zmbackup -i"
# Backup Rotation command
BACKUP_ROTATION="zmbackup -hp"
# Distribution list backup command
DISTRIBUTION_LIST_BACKUP="zmbackup -f -dl"
# Alias Backup command
ALIAS_BACKUP="zmbackup -f -al"


RET=0

function runAsRoot() {
  $@ || RET=1
}

function runAsZimbra() {
  /sbin/runuser -u zimbra -- "$@" || RET=1
}


echo "$(date +%D) - Starting Backup"

echo "Unmounting remote partition"
runAsRoot ${UMOUNT_COMMAND}
echo "Mounting remote partition"
runAsRoot "${MOUNT_COMMAND}"

echo "Rotating old backups"
runAsZimbra "${BACKUP_ROTATION}"

echo "Backup Aliases"
runAsZimbra "${ALIAS_BACKUP}"

echo "Backup Distribution lists"
runAsZimbra ${DISTRIBUTION_LIST_BACKUP}


case ${TODAY} in
  [1-6])
    echo "Performing incremental backup"
    runAsZimbra ${INCREMENTAL_COMMAND}
  ;;
  "7")
    echo "Performing full backup"
    runAsZimbra ${FULL_COMMAND}
  ;;
esac

echo "Unmounting remote partition"
runAsRoot ${UMOUNT_COMMAND}

if [ ${RET} == 1 ]; then
  echo "The backup process entered an exception. Please refer to the log"
  exit 255
else
  echo "Done"
  exit 0
fi
