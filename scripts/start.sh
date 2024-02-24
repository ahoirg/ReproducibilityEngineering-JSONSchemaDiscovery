#!/bin/bash

#start MongoDB
mongod --fork --config /etc/mongod.conf --logpath /var/log/mongod.log
mongo --eval "db.runCommand({ping: 1})"

#import data
mongoimport --db jsonschemadiscovery --collection docs --file /usr/src/app/examples/alltypes.json
for file in /usr/src/json-data/*.json; do
    collection_name=$(basename "$file" .json)
    echo "Importing $file into collection: $collection_name"
    mongoimport --db jsonschemadiscovery --collection "$collection_name" --file "$file"
done

# Remove the json-data directory and its contents
rm -rf /usr/src/json-data/

#start app
cd /usr/src/app
npm run dev