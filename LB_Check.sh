#!/bin/bash

# Variáveis
FORTIGATE_IP="IP_DO_FORTIGATE"  # Endereço IP do Fortigate
FORTIGATE_USER="USUARIO_FORTIGATE"  # Usuário para conectar ao Fortigate
FORTIGATE_PASSWORD="SENHA_FORTIGATE"  # Senha do Fortigate
APP_DNS="app.organization.com"  # URL da aplicação no Route53
LOG_FILE="./fortigate_address_log.txt"  # Arquivo de log dos "addresses" no Fortigate
DNS_LOG_FILE="./dns_log.txt"  # Arquivo de log dos resultados do nslookup

# Função para registrar data e hora
log_date_time() {
  echo "$(date '+%Y-%m-%d %H:%M:%S')" >> "$1"
}

# Função para obter IPs configurados no Fortigate e salvar no log
get_fortigate_addresses() {
  log_date_time "$LOG_FILE"
  sshpass -p "$FORTIGATE_PASSWORD" ssh "$FORTIGATE_USER@$FORTIGATE_IP" \
    'get firewall address ABARIS_AWS_IP; get firewall address ABARIS_AWS_IP2' \
    >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"
}

# Função para consultar o DNS e salvar no log
get_dns_ips() {
  log_date_time "$DNS_LOG_FILE"
  nslookup "$APP_DNS" | grep -A2 "Name:" >> "$DNS_LOG_FILE"
  echo "" >> "$DNS_LOG_FILE"
}

# Função para extrair IPs do nslookup
extract_dns_ips() {
  nslookup "$APP_DNS" | grep -A2 "Name:" | grep "Address" | awk '{print $2}'
}

# Função para extrair IPs configurados no Fortigate
extract_fortigate_ips() {
  sshpass -p "$FORTIGATE_PASSWORD" ssh "$FORTIGATE_USER@$FORTIGATE_IP" \
    'get firewall address ABARIS_AWS_IP; get firewall address ABARIS_AWS_IP2' | \
    grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'
}

# Função para atualizar os "addresses" no Fortigate
update_fortigate_address() {
  local address_name="$1"
  local new_ip="$2"
  
  sshpass -p "$FORTIGATE_PASSWORD" ssh "$FORTIGATE_USER@$FORTIGATE_IP" \
    "config firewall address
     edit $address_name
     set subnet $new_ip 255.255.255.255
     next
     end"
}

# 1. Registrar os endereços IP configurados no Fortigate
get_fortigate_addresses

# 2. Registrar o resultado do DNS da aplicação
get_dns_ips

# 3. Comparar os IPs e atualizar, se necessário
dns_ips=($(extract_dns_ips))
fortigate_ips=($(extract_fortigate_ips))

# Verificar se os IPs são diferentes
for i in ${!dns_ips[@]}; do
  if [[ "${dns_ips[$i]}" != "${fortigate_ips[$i]}" ]]; then
    if [[ $i -eq 0 ]]; then
      update_fortigate_address "ABARIS_AWS_IP" "${dns_ips[$i]}"
    elif [[ $i -eq 1 ]]; then
      update_fortigate_address "ABARIS_AWS_IP2" "${dns_ips[$i]}"
    fi
    echo "Atualizado ${dns_ips[$i]} em ABARIS_AWS_IP$i no Fortigate."
  fi
done
