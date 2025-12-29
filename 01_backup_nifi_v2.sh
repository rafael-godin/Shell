#!/bin/bash
set -e

# Backup script used on Apache Nifi migration
# Author: Rafael Feranndes
# Date: 2024-06-10
# Description: This script performs a backup of Apache NiFi configurations and repositories
#              to facilitate migration to a new instance or version.
#

FLOW_FILES_DIR="/path/to/flowfiles"
CONTENT_REPO="/path/to/content_repository"
DB_REPO="/path/to/database_repository"
FLOW_REPO="/path/to/flowfile_repository"
PROVENANCE_REPO="/path/to/provenance_repository"
EXT_LIBS="/path/to/external-libs"
NIFI_HOME="/path/to/nifi-1.14.0"
NIFI_REGISTRY_HOME="/path/to/nifi-registry-0.8.0"
DATE=$(date +%Y%m%d_%H%M)
BACKUP_DIR="/path/to/backup_dir"
LOG="$BACKUP_DIR/backup_$DATE.log"


### Parar serviços
exec > >(tee -a "$LOG") 2>&1
echo "[INFO] Parando serviços..."

$NIFI_HOME/bin/nifi.sh stop
$NIFI_REGISTRY_HOME/bin/nifi-registry.sh stop
sleep 10

sudo systemctl stop nifi || true
sudo systemctl stop nifi-registry || true
sleep 10

if pgrep -u nifi -f nifi > /dev/null; then
  echo "[WARN] O Apache NiFi ainda está em execução. Finalizando processo..."
  pkill -u nifi -f nifi
fi

### To update permissions before backup
echo "[INFO] Ajustando permissões..."
sudo chown nifi:nifi /opt/migration_backup
sudo chmod 755 /opt/migration_backup

### To start backup
echo "=== INICIANDO BACKUP $DATE ==="

tar -czpf $BACKUP_DIR/nifi_conf_$DATE.tar.gz \
  $NIFI_HOME/conf \
  $NIFI_HOME/conf/flow.xml.gz \
  $NIFI_HOME/conf/archive

tar -czpf $BACKUP_DIR/nifi_repos_$DATE.tar.gz \
  $CONTENT_REPO \
  $FLOW_REPO \
  $PROVENANCE_REPO \
  $DB_REPO \
  $FLOW_FILES_DIR \
  $EXT_LIBS

tar -czpf $BACKUP_DIR/nifi_registry_$DATE.tar.gz \
  $NIFI_REGISTRY_HOME/conf \
  $NIFI_REGISTRY_HOME/database \
  $NIFI_REGISTRY_HOME/flow_storage \
  $NIFI_REGISTRY_HOME/extension_bundles

echo "== Backup finalizado $DATE ==="