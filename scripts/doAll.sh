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

# Run exp.py
echo "Experiment has been started"
python3 /usr/src/scripts/exp.py
echo "Experiment is done!"

# First, clear existing CSVs in /usr/src/report/data
rm -f /usr/src/report/data/*.csv

# Now, copy all CSVs from /usr/src/results to /usr/src/report/data
cp /usr/src/results/*.csv /usr/src/report/data/

# Navigate to /usr/src/report directory
cd /usr/src/report

# Run make report and then make clean
make report
make clean

# Clear the console
clear

echo "The report has been re-generated with new results."
echo "You can find the main.pdf in /usr/src/report "

