#!/usr/bin/env bash
#
# Description:
#       This script is used to make daily backup of projects' databases
#
# Contact: Zina Infra Team
#
# Changelog:
#       - 09.11.2016: initial version
#

BKPATH="/ephemeral/user/backups/database/"

# This function creates a compressed .tgz dump for a given database
# @arg1 (string) : database user (ex: 'user')
# @arg2 (string) : database password (ex: 'passed')
# @arg3 (string) : database hostname (ex: 'localhost')
# @arg4 (string) : database name (ex: 'databbasename')
#
function dump_and_compress_database()
{
        DBUSER="$1"
        DBPASS="$2"
        DBHOST="$3"
        DBNAME="$4"
        BKNAME=$(echo $DBNAME | tr -cd '[[:alnum:]]')
        TIMESTAMP=$(date +%Y.%m.%d)
        if [[ -f ${BKPATH}/${TIMESTAMP}_${BKNAME}_database.tgz ]]; then
                BKSIZE=$(ls -lh ${BKPATH}/${TIMESTAMP}_${BKNAME}_database.tgz | awk '{print $5}')
                echo "[ERROR] Backup file ${BKPATH}/${TIMESTAMP}_${BKNAME}_database.tgz already exists (size: ${BKSIZE})"
                return
        fi
        EPOCH_START=$(date +%s)
        pg_dump --dbname=postgres://${DBUSER}:${DBPASS}@${DBHOST}:5432/${DBNAME} --no-acl \
           --no-owner -Fc -f ${BKPATH}/${TIMESTAMP}_${BKNAME}_database.sql
        if [[ "$?" -ne 0 ]]; then
                echo "[ERROR] The backup of database ${DBNAME} was not created (see previous error messages)"
                return
        fi
        cd ${BKPATH}
        tar czf ${TIMESTAMP}_${BKNAME}_database.tgz ${TIMESTAMP}_${BKNAME}_database.sql
        rm ${BKPATH}/${TIMESTAMP}_${BKNAME}_database.sql
        EPOCH_END=$(date +%s)
        BKSIZE=$(ls -lh ${BKPATH}/${TIMESTAMP}_${BKNAME}_database.tgz | awk '{print $5}')
        ELAPSEDTIME="`date -d@$(($EPOCH_END - $EPOCH_START)) -u +%H:%M:%S`"
        echo "[INFO] File : ${BKPATH}/${TIMESTAMP}_${BKNAME}_database.tgz (size: ${BKSIZE} - ${ELAPSEDTIME} elapsed)"
}

echo "[INFO] Starting databases backup on `date +%d/%m/%y\" at \"%H:%M:%S`..."

dump_and_compress_database "example" "example" "localhost" "example"
dump_and_compress_database "example" "example" "localhost" "example1"
dump_and_compress_database "test" "test" "localhost" "example2"

echo "[INFO] Backup finished on `date +%d/%m/%y\" at \"%H:%M:%S` !"
