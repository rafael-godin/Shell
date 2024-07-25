#!/bin/bash
# ---------------------------------------------------------------- #
# Name:   	 check-shmp.sh
# Desc.:   	 Check if pkg is installed and install it if it's not.
# Written by:    Rafael Oliveira
# E-mail:	 raferoliver@gmail.com
# ---------------------------------------------------------------- #
# Usage:
#       $ ./check-snmp.sh
# ---------------------------------------------------------------- #
# Bash Version:
#              Bash 5.0.17
# -----------------------------------------------------------------#
# History:       v1.0 24/07/2024, Rafael:
#                - Start the program
#                - Created function to verify and install packages
#                v1.1 25/07/2024, Rafael:
#                - Tested the execution and added the check for snmptrapd
#                v1.2 25/07/2024, Rafael:
# -----------------------------------------------------------------#
# Tick-tickaah:
#
# -----------------------------------------------------------------#

# Function to verify and install packages.
check_and_install_package() {
  PACKAGE=$1
  if dpkg -l | grep -q "^ii  $PACKAGE "; then
    echo "$PACKAGE already installed."
  else
    echo "$PACKAGE isn't installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y $PACKAGE
  fi
}
# Verify and install snmp
check_and_install_package snmp

# Verify and install snmpd
check_and_install_package snmpd

# Verify and install snmp-mibs-downloader
check_and_install_package snmp-mibs-downloader

# Verify and install shmptrapd
check_and_install_package snmptrapd

# Enable and start snmpd
echo "Enabling and starting snmpd service..."
systemctl enable snmpd
systemctl start snmpd

exit

# Enable and start snmptrapd
echo "Enabling and starting snmptrapd service..."
systemctl enable snmptrapd
systemctl start snmptrapd

exit

# Check service's status
systemctl status snmpd
systemctl status snmptrapd

exit
