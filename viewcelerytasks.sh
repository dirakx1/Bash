#!/usr/bin/env bash

if env | grep -q VIRTUAL_ENV; then
        true
else
        source /usr/local/bin/virtualenvwrapper.sh
        workon zina
fi

cd /www/
/example/.env/example/bin/python /example/www/example/manage.py celery inspect active 2>/dev/null
