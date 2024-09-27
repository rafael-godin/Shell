#!/bin/bash
# ---------------------------------------------------------------- #
# Name:   	 disable_policy.sh
# Desc.:   	 Connect to Fortigate and disable firewall policies.
# Written by:    Rafael Oliveira
# E-mail:	 raferoliver@gmail.com
# ---------------------------------------------------------------- #
# Usage:
#       $ ./disable_policy.sh
# ---------------------------------------------------------------- #
# Bash Version:
#              Bash 5.0.17
# -----------------------------------------------------------------#
# History:       v1.0 27/09/2024, Rafael:
#                - Start the program
#                - Connect to Fortigate via ssh.
#                - Disable firewall policies identified by ID on a list.
# -----------------------------------------------------------------#
# Tick-tickaah:
#
# -----------------------------------------------------------------#


# List of firewall policy IDs (one per row).
ID_FILE="policy_ids.txt"

# SSH connection and while loop to read list.
ssh user@<fgt-ip> << EOF
  config firewall policy
  $(while read -r ID; do
    echo "edit $ID"
    echo "set status disable"
    echo "next"
  done < "$ID_FILE")
  end
EOF
