#!/bin/bash

# Define the importance of the problem, based on the first solution that zypper
# recommends the user to do ('Solution 1')

# Critical Installation Problems
MESSAGE_CRITICAL_1="Solution 1: Following actions will be done"
MESSAGE_CRITICAL_2="Solution 1: do not install"
MESSAGE_CRITICAL_3="Solution 1: ignore the warning of a broken system"

# Normal Messages
MESSAGE_NORMAL_1="Solution 1: deinstallation of"

# Tumbleweed is too fast
MESSAGE_STUPID="not found in package names"

echo "PASSED : $(grep -o "SUCCESS" ./*.log | wc -l)"
echo "FAILED : $(grep -o "FAILURE" ./*.log | wc -l)"
echo "TIMEOUT: $(grep -o "TIMEOUT" ./*.log | wc -l)"
echo
echo "Grouping the failed results"
echo "---------------------------"
echo "$MESSAGE_CRITICAL_1: $(grep -o "$MESSAGE_CRITICAL_1" ./*.log | wc -l)"
echo "$MESSAGE_CRITICAL_2: $(grep -o "$MESSAGE_CRITICAL_2" ./*.log | wc -l)"
echo "$MESSAGE_CRITICAL_3: $(grep -o "$MESSAGE_CRITICAL_3" ./*.log | wc -l)"
echo "$MESSAGE_NORMAL_1: $(grep -o "$MESSAGE_NORMAL_1" ./*.log | wc -l)"
echo "$MESSAGE_STUPID: $(grep -o "$MESSAGE_STUPID" ./*.log | wc -l)"

