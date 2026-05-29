#!/bin/bash

# ==========================
# Variablen (anpassen)
# ==========================
DB_HOST="Private IP Adresse des DB-Servers"
DB_NAME="nextcloud"
DB_USER="admin"
DB_PASS="AdM123!"

# ==========================
# APT reparieren & Pakete installieren
# ==========================
echo "==> APT reparieren"
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*
sudo apt update
sudo apt --fix-broken install -y

echo "==> Apache, PHP und Abhängigkeiten installieren"
sudo apt install -y apache2 \
php libapache2-mod-php php-mysql unzip wget \
php-gd php-json php-curl php-mbstring php-intl \
php-xml php-zip php-bcmath php-gmp php-imagick

# ==========================
# Nextcloud herunterladen & entpacken
# ==========================
echo "==> Nextcloud herunterladen (Archiv)"
cd /var/www
sudo wget https://download.nextcloud.com/server/releases/latest.zip
sudo unzip -o latest.zip
sudo rm latest.zip
sudo chown -R www-data:www-data nextcloud

# ==========================
# Apache konfigurieren
# ==========================
echo "==> Apache VirtualHost konfigurieren"
sudo bash -c 'cat <<EOF > /etc/apache2/sites-available/nextcloud.conf
<VirtualHost *:80>
    DocumentRoot /var/www/nextcloud/

    <Directory /var/www/nextcloud/>
        AllowOverride All
        Require all granted
    </Directory>

</VirtualHost>
EOF'

sudo a2dissite 000-default.conf
sudo a2ensite nextcloud.conf
sudo a2enmod rewrite
sudo systemctl reload apache2

# ==========================
# Öffentliche IP ermitteln
# ==========================
PUBLIC_IP=$(curl -s ifconfig.me || hostname -I | awk "{print \$1}")

# ==========================
# WICHTIG: KEINE OCC-INSTALLATION!
# ==========================
echo ""
echo "================================================="
echo "Nextcloud wurde vorbereitet."
echo "Beim Aufruf der URL erscheint der Installationsassistent."
echo ""
echo "URL:"
echo "http://${PUBLIC_IP}/"
echo ""
echo "Datenbankdaten für den Installationsassistenten:"
echo "-----------------------------------------------"
echo "Datenbanktyp : MySQL / MariaDB"
echo "Datenbankhost: ${DB_HOST}"
echo "Datenbankname: ${DB_NAME}"
echo "Benutzername : ${DB_USER}"
echo "Passwort     : ${DB_PASS}"
echo "================================================="
echo ""
echo "➡ Öffnen Sie die URL im Browser und schließen Sie die Installation ab."
