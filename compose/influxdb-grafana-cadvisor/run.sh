#!/bin/bash

sudo mkdir -p /opt/grafana/data
docker-compose up -d
sudo chown -R 472:472 /opt/grafana/data

echo "Grafana: http://127.0.0.1:3000 - admin/admin"

echo
echo "Current database list"
curl -G http://localhost:8086/query?pretty=true --data-urlencode "db=igc" --data-urlencode "q=SHOW DATABASES"

echo
echo "Create a new database ?"
echo "curl -XPOST 'http://localhost:8086/query' --data-urlencode 'q=CREATE DATABASE "igc" WITH DURATION 52w REPLICATION 1 SHARD DURATION 4w NAME "singleyear"'"