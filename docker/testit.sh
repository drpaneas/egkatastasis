#!/bin/bash
# Usage: ./testit.sh $PACKAGE
# Example: ./testit.sh converseen-lang-0.9.6.1-1.2
# The script runs this command: docker run -i -t --rm --env PKG="converseen-lang-0.9.6.1-1.2" opensuse:tumbleweed /bin/bash -c '/usr/bin/zypper -n in -y -l $PKG'

# Colors for the output
RED='\033[0;31m'
GREEN='\033[1;32m'
BLUE='\033[0;34m'
YELLOW=$(tput setaf 3)
NC='\033[0m' # No Color

# Variables
PACKAGE="$1"
TIMEOUT=900s # 15 minutes
LIST_PASS="pass.list"
LIST_FAIL="fail.list"
LIST_SKIP="skip.list"

# Spawn then container and run the installation of the pkg uzing zypper
# Then pass the exit code from the container back to the host operating system
cont=$(docker run -d --env PKG="$PACKAGE" --net=host opensuse:tumbleweed /bin/bash -c '/usr/bin/zypper -n in -y -l $PKG')
code=$(timeout $TIMEOUT docker wait "$cont")

# Interpret the result of the installation by controlling the exit code
if [ -z "$code" ]; then
    docker logs "$cont" &> "$PACKAGE.log"
    echo -e "${RED}TIMEOUT${NC} on ${YELLOW}$PACKAGE${NC} ${BLUE}[${NC}see logs at ${RED}$PACKAGE.log${NC}${BLUE}]${NC}"
    echo "TIMEOUT on $PACKAGE"  >> "$PACKAGE.log"
    echo "$PACKAGE" >> "$LIST_SKIP"
    # Kill the container forcefully
    docker kill "$cont" &> /dev/null
else
    if [ "$code" != "0" ]; then
        docker logs "$cont" &> "$PACKAGE.log"
        echo -e "${RED}FAILURE${NC} on ${YELLOW}$PACKAGE${NC} ${BLUE}[${NC}see logs at ${RED}$PACKAGE.log${NC}${BLUE}]${NC}"
        echo "FAILURE on $PACKAGE" >> "$PACKAGE.log"
        echo "$PACKAGE" >> "$LIST_FAIL"
    else
        docker logs "$cont" &> "$PACKAGE.log"
        echo -e "${GREEN}SUCCESS${NC} on ${YELLOW}$PACKAGE${NC} ${BLUE}[${NC}see logs at ${GREEN}$PACKAGE.log${NC}${BLUE}]${NC}"
        echo "SUCCESS on $PACKAGE" >> "$PACKAGE.log"
        echo "$PACKAGE" >> "$LIST_PASS"
    fi
fi

# Write at the beginning of the file the '$PKG' keyword as requirement
# for parsing the logs using filebeat's multiline plugin
sed -i '1i$PKG' "$PACKAGE.log" 

# Remove the container from the system
docker rm "$cont" &> /dev/null 
