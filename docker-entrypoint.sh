#!/bin/bash
set -e
 
su - postgres -c "/usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data >logfile 2>&1 &"
source /opt/WebODM/python3env/bin/activate && cd /opt/WebODM/ && pip install -r requirements.txt && python manage.py collectstatic --noinput
su - postgres -c "psql -h localhost -p 5432 -U postgres -c 'create database webodm_dev'"
su - postgres -c "psql -h localhost -p 5432 -U postgres -d webodm_dev -c 'CREATE EXTENSION postgis'"
su - postgres -c "psql -h localhost -p 5432 -U postgres -d webodm_dev -c 'SET postgis.enable_outdb_rasters = True;'"
su - postgres -c "psql -h localhost -p 5432 -U postgres -d webodm_dev -c 'SET postgis.gdal_enabled_drivers TO 'GTiff';'"
redis-server --daemonize yes
nohup sh /opt/WebODM/start.sh --no-gunicorn &

exec "$@"
