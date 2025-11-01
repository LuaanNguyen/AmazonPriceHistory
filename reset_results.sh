#!/bin/bash 

RESULTS_DIR="results"

echo "Cleaning previous experiment results..."

if [ -d "$RESULTS_DIR" ]; then 
    echo "Found '$RESULTS_DIR' directory"
    echo "Removing contents..."
    rm -rf ${RESULTS_DIR:?}/*
    echo "All results deleted"
else 
    echo "No 'results' directiory found. Nothing to clean"
fi

