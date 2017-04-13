#!/bin/bash
# Usage: ./test_all.sh
# Example: ./test_all.sh

# Colors
bold=$(tput bold)
normal=$(tput sgr0)
yellow=$(tput setaf 3)
NC='\033[0m' # No Color

# Define variables
PACKAGES="packages.txt"
COUNTER=$(wc -l < $PACKAGES)

echo -e "${bold}\nScenario${normal}"
echo "--------"
echo "We will spawn $COUNTER contrainers (one container per package). For each container we will add the maintenance"
echo -e "testing repository ${yellow}hehehe${NC}"
echo "and then we will do a zypper refresh. Finally, we will use zypper to install ONLY ONE package"
echo "PER container. This is because each one of those should be able to be installed without any"
echo "problems."
#    echo -e "\nTest: zypper ar -f $REPO incident_repo && \ "
#    echo "      zypper ref && \ "
#    echo "      zypper -n in --from incident_repo -y -l $PKG"

echo -e "\n${bold}RESULTS${normal}"
echo "-------"

time parallel --no-notice -j30 "./testit.sh \"{}\"" < $PACKAGES
