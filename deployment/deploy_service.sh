#!/usr/bin/env bash

docker stack rm monarch
DATADIR=/srv/monarch docker stack deploy -c ../docker-compose.yml monarch
