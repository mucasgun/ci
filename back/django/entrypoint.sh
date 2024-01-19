#!/bin/sh

#echo "Waiting for postgres..."
#echo "Waiting 2sec..."
#sleep 2
#python manage.py flush

python manage.py migrate

#python manage.py createcachetable
#python manage.py collectstatic  --noinput
echo "run gunicor, port 8004"
gunicorn Users.wsgi --bind 0.0.0.0:8004
#python manage.py runapscheduler &

#python manage.py runserver 0.0.0.0:8004
exec "$@"
