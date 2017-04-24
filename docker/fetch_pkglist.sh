#!/bin/bash

# Save the output of zypper into a file
PACKAGES="packages.txt"
PACKAGES_TMP="packages.tmp"
PKG_NAME="package.name"
PKG_VERSION="package.version"
PKG_ARCH="package.arch"
TIMEOUT=240s

cont=$(docker run -d --net=host opensuse:tumbleweed /bin/bash -c '/usr/bin/zypper se -st package "*"')
code=$(timeout $TIMEOUT docker wait "$cont")
if [ -z "$code" ]; then
    echo -e "TIMEOUT: Zypper takes too long!"
    docker kill "$cont" &> /dev/null
    docker logs "$cont" 2>&1
    docker rm "$cont" &> /dev/null
    exit 1
else
    if [ "$code" != "0" ]; then
        echo "ERROR: Failed to fetch the packages"
        docker logs "$cont" &> "$PACKAGES"
        docker rm "$cont" &> /dev/null
    else
        echo "INFO: The list of packages has been fetched: packages.txt"
        docker logs "$cont" &> "$PACKAGES"
        docker rm "$cont" &> /dev/null
    fi
fi

# Assuming that the packges start after the line '--+-', remove the previous
awk '/--+-/{i++}i' $PACKAGES > $PACKAGES_TMP
mv $PACKAGES_TMP $PACKAGES

# Remove the '--+-' line (which is the first one)
tail -n +2 "$PACKAGES" > $PACKAGES_TMP

# packagenames (remove the whitespace in the end)
(awk -F '  | ' '{ print $3 }' < $PACKAGES_TMP) | sed 's/[[:blank:]]*$//' > $PKG_NAME
(awk -F '|' '{ print $4 }' < $PACKAGES_TMP) | sed 's/^.//' | sed 's/[[:blank:]]*$//' > $PKG_VERSION
(awk -F '|' '{ print $5 }' < $PACKAGES_TMP) | sed 's/^.//' | sed 's/[[:blank:]]*$//' > $PKG_ARCH

TOTAL=$(wc -l < $PACKAGES_TMP)

rm $PACKAGES
COUNTER=1
while [ "$COUNTER" -le "$TOTAL" ]
do
    NAME=$(sed "${COUNTER}q;d" $PKG_NAME)
    VER=$(sed "${COUNTER}q;d" $PKG_VERSION)
    ARCH=$(sed "${COUNTER}q;d" $PKG_ARCH)
    echo "$NAME-$VER.$ARCH" >> $PACKAGES
    COUNTER=$(echo "$COUNTER + 1" | bc)
done

# Double-Remove the whitespace at the end of the file
sed 's/[[:blank:]]*$//' $PACKAGES > $PACKAGES_TMP
mv $PACKAGES_TMP $PACKAGES
