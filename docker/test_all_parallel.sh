#!/bin/bash
# Usage: ./test_all_parallel.sh

# Colors
bold=$(tput bold)
normal=$(tput sgr0)
yellow=$(tput setaf 3)
NC='\033[0m' # No Color

# Test based on architecture:
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
time parallel --no-notice -j30 "./testit.sh \"{}\"" < $PACKAGES
