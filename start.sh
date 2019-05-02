#!/bin/bash
docker build -t webodm_power_image .
docker run -tid -P --name webodm_power webodm_power_image
docker exec webodm_power docker-entrypoint.sh
