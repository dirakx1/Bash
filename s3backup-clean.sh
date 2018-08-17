#!/bin/bash
#
# Description: This script will upload the locally stored postgres backup to
#       a given S3
#
# Dependencies:
#       s3cmd ($> apt-get install python-pip && pip install s3cmd)
#

BACKUP_PATH=/ephemeral/backups/database/
BACKUP_NAME="$(date +%Y.%m.%d)_test_database.tgz"
BACKUP_FILENAME=$(find ${BACKUP_PATH} -type f -name "${BACKUP_NAME}")
KEEPDAYS="30"
PATH=$PATH:/usr/local/bin

function send_backup_to_s3()
{
        s3cmd -c /root/backup-scripts/s3cfg put -P ${BACKUP_FILENAME} s3://bucket/
        
}

function remove_old_backups_locally()
{
        echo -n "[INFO] Deleting backups older than ${KEEPDAYS} days..."
        find ${BACKUP_PATH} -mtime +${KEEPDAYS} -type f -name "*.tgz" -exec rm "{}" \;
        echo "[OK]"

}

function remove_old_backups_s3()
{
s3cmd -c /root/backup-scripts/s3cfg ls s3://$1 | while read -r line;
  do
    createDate=`echo $line|awk {'print $1" "$2'}`
    realcreated=`date -d"$createDate" +%s`
    olderThan=`date --date "30 days ago" +%s`
    if [[ $realcreated -lt $olderThan ]]
      then
        fileName=`echo $line|awk {'print $4'}`
            if [[ $fileName != "" ]]
               then
                  echo "REMOVING s3 older then 30 days backup files"
                  s3cmd -c /root/backup-scripts/s3cfg del "$fileName"
                  echo "OK"
            fi
     fi
done;
}

echo "[$(date +%Y.%m.%d\ %Hh%M:%S)] Starting sending file backup to  S3 "

## Check if backup file is found locally under $BACKUP_PATH
if [[ ! -f ${BACKUP_FILENAME} ]]; then
        echo "[ERROR] Daily  database not found! Quitting."
        exit
fi

## If the previous tests are OK, we proceed with the upload to S3
send_backup_to_s3
remove_old_backups_locally
remove_old_backups_s3 bucketname 30
echo "[$(date +%Y.%m.%d\ %Hh%M:%S)] Backup correctly sent to S3!"

