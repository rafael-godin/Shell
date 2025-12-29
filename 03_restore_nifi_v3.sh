#!/bin/bash

### Shell script to restore Apache NiFi and NiFi Registry on Ubuntu 20.04 with Java 8
set -e

### Variables
DATE=$(date +%Y%m%d_%H%M)
BACKUP_DIR="/opt/migration_backup"
LOG="$BACKUP_DIR/backup_$DATE.log"
NIFI_TAR="nifi-1.14.0-bin.tar.gz"
REGISTRY_TAR="nifi-registry-0.8.0-bin.tar.gz"

### Stop services 
exec > >(tee -a "$LOG") 2>&1
echo "[INFO] Stopping services..."

sudo systemctl stop nifi nifi-registry || true
sleep 10

if pgrep -u nifi -f nifi > /dev/null; then
  echo "[WARN] Apache NiFi still running. Killing process..."
  pkill -u nifi -f nifi
fi

sleep 5

### Remove previous installations
echo "[INFO] Removing previous installations..."

sudo rm -rf /home/nifi/*
sudo rm -rf /opt/nifi*
sudo rm -rf /var/lib/nifi*

### Check installed Java version
echo "[INFO] Checking installed Java version..."

java -version || true
javac -version || true

if pgrep -f java > /dev/null; then
  echo "[WARN] Nifi user running Java process. Terminating process..."
  sudo pkill -9 java
fi

### Remove old Java versions
echo "[INFO] Removing old Java versions..."

sudo apt purge -y \
  openjdk-* \
  default-jdk* \
  default-jre* \
  oracle-java* \
  java-common \
  icedtea-* \
  ca-certificates-java

sleep 5

sudo apt autoremove -y
sleep 5

sudo apt autoclean
sleep 3

### Update system repositories
echo "[INFO] Updating system repositories..."

sudo apt update && sudo apt upgrade -y

### Install OpenJDK 8
echo "[INFO] Installing OpenJDK 8..."

sudo apt install -y openjdk-8-jdk

### Check Java installation
echo "[INFO] Checking Java installation..."

java -version

### Set JAVA_HOME
echo "[INFO] Setting JAVA_HOME..."

echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' | sudo tee /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo "JAVA_HOME set to $JAVA_HOME"

sudo mkdir -p /home/nifi/nifi-prod
sleep 3

### Install Apache NiFi 1.14.0
echo "[INFO] Obtaining Apache NiFi 1.14.0..."

cd /opt

if [[ ! -f "$NIFI_TAR" ]]; then
	echo "[INFO] Downloading Apache NiFi..."
	sudo wget -q https://archive.apache.org/dist/nifi/1.14.0/$NIFI_TAR
fi

if [[ ! -f "$NIFI_TAR" ]]; then
  echo "[ERRO] Arquivo $NIFI_TAR not found"
  exit 1
fi

sleep 3

sudo tar -xzf $NIFI_TAR
sudo chown -R nifi:nifi nifi-1.14.0
sudo mv nifi-1.14.0 /home/nifi/nifi-prod/

### Installing NiFi Registry 0.8.0
echo "[INFO] Installing NiFi Registry 0.8.0..."

cd /opt

if [[ ! -f "$REGISTRY_TAR" ]]; then
  echo "[INFO] Downloading NiFi Registry..."
  sudo wget -q https://archive.apache.org/dist/nifi/nifi-registry/nifi-registry-0.8.0/$REGISTRY_TAR
fi

if [[ ! -f "$REGISTRY_TAR" ]]; then
  echo "[ERRO] Arquivo $REGISTRY_TAR not found"
  exit 1
fi

sudo tar -xzf $REGISTRY_TAR
sudo chown -R nifi:nifi nifi-registry-0.8.0
sudo mv nifi-registry-0.8.0 /home/nifi/

### Restore Apache NiFi
echo "[INFO] Restoring backups..."

cd /backup_dir

sudo tar -xvf nifi_conf_*.tar.gz -C /
sudo tar -xvf nifi_repos_*.tar.gz -C /

### Restore NiFi Registry
echo "[INFO] Restoring NiFi Registry..."

sudo tar -xvf nifi_registry_*.tar.gz -C /

### Permission update
echo "[INFO] Updating permissions..."

sudo chown -R nifi:nifi /home/nifi/

echo "[WARNING] update java.home on bootstrap"
echo "....... ......... ......... .. ........."
echo "[WARNING] update java.home on bootstrap"
echo "....... ......... ......... .. ........."
echo "[WARNING] update java.home on bootstrap"
echo "....... ......... ......... .. ........."

echo "== Restore finished $DATE ==="

