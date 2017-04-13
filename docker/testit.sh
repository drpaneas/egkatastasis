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
TIMEOUT=240s

# Spawn then container and run the installation of the pkg uzing zypper
# Then pass the exit code from the container back to the host operating system
cont=$(docker run -d --env PKG="$PACKAGE" --net=host opensuse:tumbleweed /bin/bash -c '/usr/bin/zypper -n in -y -l $PKG')
code=$(timeout $TIMEOUT docker wait "$cont")

# Interpret the result of the installation by controlling the exit code
if [ -z "$code" ]; then
    echo -e "TIMEOUT on $PACKAGE"
    docker kill "$cont" &> /dev/null
    docker logs "$cont" 2>&1
else
    if [ "$code" != "0" ]; then
        echo -e "${RED}FAILURE${NC} on ${YELLOW}$PACKAGE${NC} ${BLUE}[${NC}see logs at ${RED}$PACKAGE.log${NC}${BLUE}]${NC}"
        docker logs "$cont" &> "$PACKAGE.log"
    else
        echo -e "${GREEN}SUCCESS${NC} on ${YELLOW}$PACKAGE${NC} ${BLUE}[${NC}see logs at ${GREEN}$PACKAGE.log${NC}${BLUE}]${NC}"
        docker logs "$cont" &> "$PACKAGE.log"
    fi
fi

# Remove the container from the system
docker rm "$cont" &> /dev/null 
