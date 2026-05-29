#!/bin/bash
set -e

echo "=== APT reparieren ==="
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*
sudo apt update
sudo apt --fix-broken install -y

echo "=== MariaDB installieren ==="
sudo apt install mariadb-server mariadb-client -y

echo "=== MariaDB starten & aktivieren ==="
sudo systemctl enable mariadb
sudo systemctl start mariadb

# ==========================
# bind-address automatisch auf 0.0.0.0 setzen
# ==========================
CONF_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"
echo "=== bind-address auf 0.0.0.0 setzen (für externe Zugriffe) ==="

# Backup erstellen
sudo cp "$CONF_FILE" "$CONF_FILE.bak"

# bind-address setzen (wenn Zeile existiert, ersetzen; sonst hinzufügen)
if grep -q "^bind-address" "$CONF_FILE"; then
    sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' "$CONF_FILE"
else
    echo "bind-address = 0.0.0.0" | sudo tee -a "$CONF_FILE"
fi

# MariaDB neu starten
sudo systemctl restart mariadb
echo "=== MariaDB neu gestartet ==="

echo "=== MariaDB absichern ==="
sudo mysql <<'EOF'
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
EOF

echo "=== Nextcloud Datenbank & Benutzer erstellen ==="
sudo mysql <<'EOF'
CREATE DATABASE IF NOT EXISTS nextcloud
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

CREATE USER IF NOT EXISTS 'admin'@'%'
  IDENTIFIED BY 'AdM123!';

GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';
FLUSH PRIVILEGES;
EOF

echo "=== MariaDB Status ==="
systemctl status mariadb --no-pager

echo "=== Fertig ==="
