#!/bin/bash
mongod --fork --config /etc/mongod.conf --logpath /var/log/mongod.log
mongo --eval "db.runCommand({ping: 1})"
for file in /usr/src/json-data/students/*.json; do
    collection_name=$(basename "$file" .json)
    mongoimport --db jsonschemadiscovery --collection "$collection_name" --file "$file"
done