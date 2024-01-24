#!/bin/bash

# Display Node.js version
echo "Node.js Version:"
node --version

# Display MongoDB version
echo "MongoDB Version:"
mongod --version

# Check MongoDB collection
echo "Checking MongoDB collection..."
if mongo jsonschemadiscovery --eval "db.getCollectionNames().includes(\"students_orj\")" | grep true; then
    echo "DB OKAY! Container is ready for use."
else
    echo "DB FAIL"
fi