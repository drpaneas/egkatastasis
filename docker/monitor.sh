#!/bin/bash

# VARIABLES
LIST_FAIL="./fail.list"
LIST_PASS="./pass.list"
LIST_SKIP="./skip.list"
PACKAGES="packages.txt"
TOTAL=$(wc -l < "$PACKAGES")

# Initiliaze
COUNT_PASSED=0
COUNT_FAILED=0
COUNT_TIMEOUT=0
COUNT_TEMP=0

while :
do
    clear
    if [ ! -f $LIST_FAIL ]; then COUNT_FAILED=0;  else COUNT_FAILED=$(wc -l < $LIST_FAIL); fi
    if [ ! -f $LIST_SKIP ]; then COUNT_TIMEOUT=0; else COUNT_TIMEOUT=$(wc -l < "$LIST_SKIP"); fi
    if [ ! -f $LIST_PASS ]; then COUNT_PASSED=0;  else COUNT_PASSED=$(wc -l < "$LIST_PASS"); fi
    COUNT_TEMP=$(echo "$COUNT_PASSED + $COUNT_FAILED + $COUNT_TIMEOUT" | bc)
    echo "Progress: So far we have tested $COUNT_TEMP packages, out of $TOTAL"
    echo "PASSED : $COUNT_PASSED"
    echo "FAILED : $COUNT_FAILED"
    echo "TIMEOUT: $COUNT_TIMEOUT"
    sleep 1
done
