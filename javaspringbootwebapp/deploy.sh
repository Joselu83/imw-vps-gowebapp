#!/bin/bash

### -----------------------------
### CONFIGURACIÓN
### -----------------------------
APP_USER="isard"
APP_NAME="webapp"
BASE_DIR="/home/$APP_USER/imw-vps-gowebapp/javaspringbootwebapp"
APP_ROOT="$BASE_DIR/$APP_NAME"
ZIP_FILE="webapp.zip"
APP_PORT="9090"

echo "📦 Instalando dependencias..."
sudo apt update -y
sudo apt install -y openjdk-17-jdk unzip

### -----------------------------
echo "📁 Preparando proyecto..."
### -----------------------------
rm -rf "$APP_ROOT"
unzip "$BASE_DIR/$ZIP_FILE" -d "$BASE_DIR"
mv "$BASE_DIR/webapp" "$APP_ROOT" 2>/dev/null || true

### -----------------------------
echo "📂 Copiando archivos ya creados..."
### -----------------------------
# crear carpetas si no existen
mkdir -p "$APP_ROOT/src/main/resources/templates"
mkdir -p "$APP_ROOT/src/main/java/com/example/webapp"

# copiar archivos proporcionados por el usuario
cp "$BASE_DIR/application.properties" "$APP_ROOT/src/main/resources/application.properties"
cp "$BASE_DIR/index.html" "$APP_ROOT/src/main/resources/templates/index.html"
cp "$BASE_DIR/contacto.html" "$APP_ROOT/src/main/resources/templates/contacto.html"
cp "$BASE_DIR/HomeController.java" "$APP_ROOT/src/main/java/com/example/webapp/HomeController.java"

### -----------------------------
echo "🔨 Compilando proyecto..."
### -----------------------------
cd "$APP_ROOT"
./gradlew build

### -----------------------------
echo "🛠 Creando servicio systemd..."
### -----------------------------
SERVICE_FILE="/etc/systemd/system/$APP_NAME.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Aplicación Spring Boot $APP_NAME
After=network.target

[Service]
User=$APP_USER
WorkingDirectory=$APP_ROOT
ExecStart=/usr/bin/java -jar $APP_ROOT/build/libs/$APP_NAME-0.0.1-SNAPSHOT.jar
Restart=always

[Install]
WantedBy=multi-user.target
EOF

### -----------------------------
echo "🚀 Activando servicio..."
### -----------------------------
sudo systemctl daemon-reload
sudo systemctl enable "$APP_NAME"
sudo systemctl restart "$APP_NAME"

echo ""
echo "✔ DEPLOY COMPLETADO"
echo "🌐 Accede a:"
echo "➡ http://<IP_DEL_SERVIDOR>:$APP_PORT/"
echo ""
