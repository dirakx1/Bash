Fetching from git deploying and killinpg ps. 

#!/bin/bash
cd /file
git fetch origin
git reset --hard origin/master
find . -name '*.pyc' -delete

# supervisorctl restart celeryd:
supervisorctl stop all
ps auxww | grep 'celery' | awk '{print $2}' | xargs kill -9
ps auxww | grep 'celery' | awk '{print $2}' | xargs kill -9
