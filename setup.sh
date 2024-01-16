#!/usr/bin/env bash

docker-compose up -d  meta1 meta2 meta3
sleep 1
docker exec meta1.cnosdb.com curl -s http://meta1.cnosdb.com:8901/init -d '{}'
docker exec meta1.cnosdb.com curl -s http://meta1.cnosdb.com:8901/add-learner -H "Content-Type: application/json" -d '[2, "meta2.cnosdb.com:8901"]'
docker exec meta1.cnosdb.com curl -s http://meta1.cnosdb.com:8901/add-learner -H "Content-Type: application/json" -d '[3, "meta3.cnosdb.com:8901"]'
docker exec meta1.cnosdb.com curl -s http://meta1.cnosdb.com:8901/change-membership -H "Content-Type: application/json" -d '[1,2,3]'
sleep 2
docker-compose up -d query_tskv1 query_tskv2
sleep 2
docker-compose up -d nginx
