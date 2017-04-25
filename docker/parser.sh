#!/bin/bash

# Define the importance of the problem, based on the first solution that zypper
# recommends the user to do ('Solution 1')

# Critical Installation Problems
MESSAGE_CRITICAL_1="Solution 1: Following actions will be done"
MESSAGE_CRITICAL_2="Solution 1: do not install"
MESSAGE_CRITICAL_3="Solution 1: ignore the warning of a broken system"
MESSAGE_CRITICAL_4="Command exited with status 126"
MESSAGE_CRITICAL_5="File conflicts happen when two packages"
MESSAGE_CRITICAL_6="inferior architecture"
MESSAGE_CRITICAL_7="scriptlet failed"

# Normal Messages
MESSAGE_NORMAL_1="Solution 1: deinstallation of"
MESSAGE_NORMAL_2="error: no alternatives for"
MESSAGE_NORMAL_3="wrong missing capabilities"
MESSAGE_NORMAL_4="cannot verify"
MESSAGE_NORMAL_5="wrong permissions"
MESSAGE_NORMAL_6="is not a correct module"

# Tumbleweed is too fast
MESSAGE_STUPID_1="not found in package names"
MESSAGE_STUPID_2="not found"
MESSAGE_STUPID_3="Error code: HTTP response: 500"

# Docker bug
MESSAGE_DOCKER_1="starting container process caused"

echo "PASSED : $(grep -o "SUCCESS" ./*.log | wc -l)"
echo "FAILED : $(grep -o "FAILURE" ./*.log | wc -l)"
echo "TIMEOUT: $(grep -o "TIMEOUT" ./*.log | wc -l)"
echo
echo "Grouping the failed results"
echo "---------------------------"
echo "$MESSAGE_CRITICAL_1: $(grep -o "$MESSAGE_CRITICAL_1" ./*.log | wc -l)"
echo "$MESSAGE_CRITICAL_2: $(grep -o "$MESSAGE_CRITICAL_2" ./*.log | wc -l)"
echo "$MESSAGE_CRITICAL_3: $(grep -o "$MESSAGE_CRITICAL_3" ./*.log | wc -l)"
echo "$MESSAGE_CRITICAL_4: $(grep -o "$MESSAGE_CRITICAL_4" ./*.log | wc -l)"
echo "$MESSAGE_CRITICAL_5: $(grep -o "$MESSAGE_CRITICAL_5" ./*.log | wc -l)"
echo "$MESSAGE_CRITICAL_6: $(grep "Solution 1:" ./*.log | grep "$MESSAGE_CRITICAL_6" | wc -l)"
echo "$MESSAGE_CRITICAL_7: $(grep "error:" ./*.log | grep "$MESSAGE_CRITICAL_7" | wc -l)"
echo "$MESSAGE_NORMAL_1: $(grep -o "$MESSAGE_NORMAL_1" ./*.log | wc -l)"
echo "$MESSAGE_STUPID_1: $(grep -o "$MESSAGE_STUPID_1" ./*.log | wc -l)"
echo "$MESSAGE_STUPID_3: $(grep -o "$MESSAGE_STUPID_3" ./*.log | wc -l)"
echo "$MESSAGE_STUPID_2: $(grep "Package" ./*.log | grep "$MESSAGE_STUPID_2" | wc -l)"
echo "$MESSAGE_DOCKER_1: $(grep -o "$MESSAGE_DOCKER_1" ./*.log | wc -l)"

echo -e "\nGrouping passed results"
echo "-----------------------"
echo "$MESSAGE_NORMAL_2: $(grep -A1 "Additional rpm output" ./*.log | grep "$MESSAGE_NORMAL_2" | wc -l)"
echo "$MESSAGE_NORMAL_3: $(grep -A1 "Additional rpm output" ./*.log | grep "$MESSAGE_NORMAL_3" | wc -l)"
echo "$MESSAGE_NORMAL_4: $(grep -A1 "Additional rpm output" ./*.log | grep "$MESSAGE_NORMAL_4" | wc -l)"
echo "$MESSAGE_NORMAL_5: $(grep -A1 "Additional rpm output" ./*.log | grep "$MESSAGE_NORMAL_5" | wc -l)"
echo "$MESSAGE_NORMAL_6: $(grep -A1 "Additional rpm output" ./*.log | grep "$MESSAGE_NORMAL_6" | wc -l)"

