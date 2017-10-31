# Check  if a file has changed for a given time and then do something if the time is gretar than X 
#!/usr/bin/env bash
#
#
# Contact:
#
# Changelog:
#

FILE=/.log
echo "$FILE"
OLDTIME=1800 # 30 minutes
CURTIME=$(date +%s)
echo "$CURTIME ACTUAL TIME"
FILETIME=$(stat $FILE -c %Y)
echo "$FILETIME LAST TIME FILE HAS BEEN WRITTEN"
TIMEDIFF=$(expr $CURTIME - $FILETIME)
echo "$TIMEDIFF TIEMPO DESDE ULTIMO WRITE"

if [ $TIMEDIFF -gt $OLDTIME ]; then
   echo '[INFO] do something'

else
   echo "do other thing"
fi
