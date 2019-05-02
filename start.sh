#!/bin/bash
docker build -t webodm_image .
docker run -tid -p 8085:8000 --name webodm webodm_image
docker exec webodm docker-entrypoint.sh
