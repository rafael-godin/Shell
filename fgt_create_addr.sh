#!/bin/bash
# ---------------------------------------------------------------- #
# Name:             fgt_create_addr.sh
# Desc.:            Connect to Fortigate and create address object from list.
# Written by:       -Rafael Oliveira
# E-mail:           raferoliver@gmail.com
# ---------------------------------------------------------------- #
# Usage:
#       $ ./fgt_create_addr.sh
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


#!/bin/bash

# Configurações
FORTIGATE_HOST="s10.20.52.1 -p 2222"
SSH_USER="rafael.oliveira"
SSH_PASS="4c3ss0@fgt"
ADDRESS_GROUP="AG_STQ_ZSCALER"
LOG_FILE="fgt_create_addr.log"

# Listas de IPs
LISTA1=("136.226.62.0/23" "136.226.138.0/23") # Adicione aqui os IPs da primeira lista
#LISTA2=("IP2_1" "IP2_2" "IP2_3") # Adicione aqui os IPs da segunda lista

# Função para enviar comandos via SSH
ssh_command() {
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$FORTIGATE_HOST" "$1"
}

# Função para criar um address
create_address() {
    local address_name=$1
    local ip=$2
    echo "Criando address $address_name com IP $ip..." | tee -a "$LOG_FILE"
    ssh_command "config firewall address
    edit $address_name
    set subnet $ip 255.255.254.0
    next
    end" | tee -a "$LOG_FILE"
}

# Função para adicionar o address ao address group
add_to_address_group() {
    local address_name=$1
    echo "Adicionando address $address_name ao address group $ADDRESS_GROUP..." | tee -a "$LOG_FILE"
    ssh_command "config firewall addrgrp
    edit $ADDRESS_GROUP
    append member $address_name
    next
    end" | tee -a "$LOG_FILE"
}

# Processar lista 1
echo "Processando Lista 1..." | tee -a "$LOG_FILE"
for ip in "${LISTA1[@]}"; do
    address_name="address_lista1_${ip//./_}"
    create_address "$address_name" "$ip"
    add_to_address_group "$address_name"
done

# Processar lista 2
#echo "Processando Lista 2..." | tee -a "$LOG_FILE"
#for ip in "${LISTA2[@]}"; do
#    address_name="address_lista2_${ip//./_}"
#    create_address "$address_name" "$ip"
#    add_to_address_group "$address_name"
#done

echo "Tarefas concluídas." | tee -a "$LOG_FILE"