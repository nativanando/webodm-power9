#!/bin/bash
docker build -t webodm_power_image .
docker run -tid -p 8085:8000 --name webodm_power webodm_power_image
docker exec webodm_power docker-entrypoint.sh
