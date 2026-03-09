#!/bin/bash
cd /home/ubuntu/scripts
docker compose -f docker-compose.yml down || true
