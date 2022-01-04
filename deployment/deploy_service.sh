#!/usr/bin/env bash

DATADIR=/srv/monarch docker stack deploy -c ../stack/docker-compose.yml monarch
