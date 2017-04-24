#!/bin/bash

# VARIABLES
LIST_FAIL="./fail.list"
LIST_PASS="./pass.list"
LIST_SKIP="./skip.list"

# Accepted options: x86_64, i586, i686, noarch
ARCH=$1

if [ -z "$ARCH" ]; then
    PACKAGES="packages.txt"
else
    if [ "$ARCH" = "x86_64" ]; then
        PACKAGES="packages.txt.x86_64"
    elif [ "$ARCH" = "i586" ]; then
        PACKAGES="packages.txt.i586"
    elif [ "$ARCH" = "i686" ]; then
        PACKAGES="packages.txt.i686"
    elif [ "$ARCH" = "noarch" ]; then
        PACKAGES="packages.txt.noarch"
    else
        echo "Error: $ARCH is not a valid argument."
        echo "Valid arguments are: x86_64, i586, i686, noarch"
        exit 1
    fi
fi

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
