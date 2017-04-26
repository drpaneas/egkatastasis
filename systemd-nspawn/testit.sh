#!/bin/bash
# Usage: ./testit.sh $PACKAGE
# Example: ./testit.sh 389-ds-1.3.4.14-1.4.x86_64

# Colors for the output
RED='\033[0;31m'
GREEN='\033[1;32m'
BLUE='\033[0;34m'
YELLOW=$(tput setaf 3)
NC='\033[0m' # No Color

# Variables
PACKAGE="$1"
LIST_PASS="pass.list"
LIST_FAIL="fail.list"
LIST_SKIP="skip.list"

# Spawn the container as systemd service
container_name=$(echo "$PACKAGE" |  sed -r 's/[-]+/_/g')
systemctl start tw@$container_name

# Wait for the container to establish Internet connection
until [[ "`machinectl status $container_name | grep 'wickedd.service'`" == *"wickedd.service"* ]]; do sleep 0.1; done

# Run the test
cont=$( { systemd-run --wait --machine $container_name --setenv PKG="$PACKAGE" /bin/sh -c '/usr/bin/zypper -n in -y -l $PKG' | echo > outfile; } 2>&1 )

# Wait until the test is finished
until [ "`grep -o Finished <<< $cont`" == "Finished" ]; do echo $cont && sleep 0.1; done

# Parse the result
unit_file=$(echo $cont | grep -o -P '(?<=unit: ).*(?=Finished)' | sed 's/[[:blank:]]*$//')
exit_code=$(echo $cont | grep -o -P '(?<=status=).*(?=Service)' |  sed 's/[[:blank:]]*$//')

# Interpret the result of the installation by controlling the exit code from journald
if [ "$exit_code" != "0" ]; then
    journalctl --machine $container_name -u $unit_file -b -q &> "$PACKAGE.log"
    echo -e "${RED}FAILURE${NC} on ${YELLOW}$PACKAGE${NC} ${BLUE}[${NC}see logs at ${RED}$PACKAGE.log${NC}${BLUE}]${NC}"
    echo "FAILURE on $PACKAGE" >> "$PACKAGE.log"
    echo "$PACKAGE" >> "$LIST_FAIL"
else
    journalctl --machine $container_name -u $unit_file -b -q &> "$PACKAGE.log"
    echo -e "${GREEN}SUCCESS${NC} on ${YELLOW}$PACKAGE${NC} ${BLUE}[${NC}see logs at ${GREEN}$PACKAGE.log${NC}${BLUE}]${NC}"
    echo "SUCCESS on $PACKAGE" >> "$PACKAGE.log"
    echo "$PACKAGE" >> "$LIST_PASS"
fi

# Remove the container from the system
systemctl stop tw@$container_name

# Service obliteration
systemctl disable tw@$container_name.service
systemctl daemon-reload
systemctl reset-failed
