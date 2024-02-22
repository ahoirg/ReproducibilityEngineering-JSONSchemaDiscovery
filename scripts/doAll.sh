#!/bin/bash

# Call smoke.sh
./smoke.sh

# Wait for 3 seconds
sleep 3

# Clear the console
clear

# Check if /usr/src/results exists and remove it
if [ -d "/usr/src/results" ]; then
    rm -rf /usr/src/results
fi

# Create the /usr/src/results directory
mkdir -p /usr/src/results

# Run exp1.py and exp2.py
echo "Experiment has been started"
python3 /usr/src/results/exp.py
echo "Experiment is done!"

# Navigate to /usr/src/report directory
cd /usr/src/report

# Run make report and then make clean
make report
make clean

echo "The report has been re-generated with new results."