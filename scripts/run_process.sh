#!/bin/bash
cd /home/ubuntu/scripts
docker pull kwangil1818/petclinic:latest
docker compose -f docker-compose.yml up -d
