#!/bin/bash

success=true

echo "Checking Node.js version..."
if node -v; then
    echo "Node.js is OK."
else
    echo "Smoke test failed: There might be an issue with Node.js."
    success=false
fi

echo "Checking MongoDB version..."
if mongod --version; then
    if mongo jsonschemadiscovery --eval "db.getCollectionNames().includes(\"students_orj\")" | grep true; then
        echo "Data is ready to use!"
    else
        echo "Smoke test failed: There might be an issue with MongoDB."
        success=false
    fi
else
    echo "Smoke test failed: There might be an issue with MongoDB."
    success=false
fi

echo "-------------------------------"
if $success ; then
    echo "Smoke test was successful!"
else
    echo "Smoke test completed with errors."
fi
echo "-------------------------------"
