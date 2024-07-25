#!/bin/bash
# ------------------------------------------------------------------------ #
# Name:    	 sw-info.sh
# Desc.:   	 Run snmpwalk to get informations about the systems and interfaces
#		 On switches SG 5204 MR L2+, SG 2404 MR L2+ and SG 2404 PoE.
# Written by:    Rafael Oliveira
# E-mail:	 raferoliver@gmail.com
# ------------------------------------------------------------------------ #
# Usage:
#       $ ./sw-info.sh
# ------------------------------------------------------------------------ #
# Bash Version:
#              Bash 5.0.17
# ------------------------------------------------------------------------ #
# History:        v1.0 25/07/2024, Rafael:
#                - start de program
#                - create function
#                v1.1 25/07/2024, Rafael:
#                - code review
#                - check the applicability
# ------------------------------------------------------------------------ #

#CODE

# Function to verify and create log files
check_and_create_file() {
  FILE=$1
  if ls -l | grep -q "^ii $FILE "; then
    echo "$FILE exists..."
  else
    echo "$FILE don't exist. Creating..."
    touch $FILE
  fi
}

# Verify and create sw-info.log
check_and_create_file sw-info.log

# Verify and create sw-desc.log
check_and_create_file sw-desc.log

# Verify and create inf-desc.log
check_and_create_file inf-desc.log

# Verify and create mac-addr.log
check_and_create_file mac-addr.log

# System info
snmpwalk -v 2c -c public 172.17.91.0/24 1.3.6.1.2.1.1 >> sw-info.log

sleep 5

# System description
snmpwalk -v 2c -c public 172.17.91.0/24 1.3.6.1.2.1.1.1 >> sw-desc.log

sleep 5

# Interface description
snmpwalk -v 2c -c public 172.17.91.0/24 1.3.6.1.2.1.2.2.1.2 >> inf-desc.log

sleep 5

# MAC address
snmpwalk -v 2c -c public 172.17.91.0/24 1.3.6.1.2.1.2.2.1.6 >> mac-addr.log

sleep 5

exit
