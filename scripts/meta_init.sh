#!/usr/bin/env bash

set -e

current_term=$(curl -s http://meta1.cnosdb.com:8901/metrics | jq '.Ok.current_term')

if [ "$current_term" -ne 0 ]; then
    echo "The meta cluster service has been initialized!"
else
  curl -s http://meta1.cnosdb.com:8901/init -d '{}' | jq

  sleep 1

  curl -s http://meta1.cnosdb.com:8901/add-learner -H "Content-Type: application/json" -d '[2, "meta2.cnosdb.com:8901"]' | jq
  curl -s http://meta1.cnosdb.com:8901/add-learner -H "Content-Type: application/json" -d '[3, "meta3.cnosdb.com:8901"]' | jq

  sleep 1
  curl -s http://meta1.cnosdb.com:8901/change-membership -H "Content-Type: application/json" -d '[1,2,3]' | jq
fi

for meta_node in "meta1.cnosdb.com" "meta2.cnosdb.com" "meta3.cnosdb.com"; do
    echo "$meta_node state: $(curl -s http://"$meta_node":8901/metrics | jq -r '.Ok.state')"
done

PORT=8080
RESPONSE="OK"

while true; do
  echo -e "HTTP/1.1 200 OK\r\nContent-Length: ${#RESPONSE}\r\n\r\n$RESPONSE" | nc -l -p $PORT >/dev/null 2>&1
done