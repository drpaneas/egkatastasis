#!/bin/bash
# Usage: ./test_all_parallel.sh

# Colors
bold=$(tput bold)
normal=$(tput sgr0)
yellow=$(tput setaf 3)
NC='\033[0m' # No Color

# Define variables
PACKAGES="packages.txt"

# Exit if packages.txt is not generated
if [ ! -f $PACKAGES ]; then
    echo "Error: $PACKAGES not found."
    echo "Run './test_all_parallel.sh' to generate it!"
    exit 1
fi

COUNTER=$(wc -l < $PACKAGES)

echo -e "${bold}\nScenario${normal}"
echo "--------"
echo -e "We are going to test the scenario where ${yellow}every package${NC} that we ship in TW should"
echo -e "be able to be installed in a minimal ${yellow}clean system${NC} without any problems. For"
echo -e "this reason we will spawn ${yellow}$COUNTER contrainers${NC} (one container per package)."
echo -e "\n${bold}RESULTS${normal}"
echo "-------"
exit 0
time parallel --no-notice -j30 "./testit.sh \"{}\"" < $PACKAGES
