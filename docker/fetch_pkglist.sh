#!/bin/bash

# Save the output of zypper into a file
PACKAGES="packages.txt"
PACKAGES_TMP="packages.tmp"
PKG_NAME="package.name"
PKG_VERSION="package.version"
zypper se -st package "*" > $PACKAGES

# Assuming that the packges start after the line '--+-', remove the previous
awk '/--+-/{i++}i' packages.txt  > $PACKAGES_TMP
mv $PACKAGES_TMP > $PACKAGES

# Remove the '--+-' line (which is the first one)
tail -n +2 "$PACKAGES" > $PACKAGES_TMP

# packagenames
(awk -F '  | ' '{ print $3 }' < $PACKAGES_TMP) > $PKG_NAME
(awk -F '|' '{ print $4 }' < $PACKAGES_TMP) | sed 's/^.//' > $PKG_VERSION

TOTAL=$(wc -l < $PACKAGES_TMP)

rm $PACKAGES
COUNTER=1
while [ "$COUNTER" -le "$TOTAL" ]
do
    NAME=$(sed "${COUNTER}q;d" $PKG_NAME)
    VER=$(sed "${COUNTER}q;d" $PKG_VERSION)
    echo "$NAME-$VER" >> $PACKAGES
    COUNTER=$(( "$COUNTER" + 1 ))
done
