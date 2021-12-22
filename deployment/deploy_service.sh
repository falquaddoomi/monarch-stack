#!/usr/bin/env bash

DATADIR=/srv/monarch docker stack deploy -c ../docker-compose.yml monarch
