#!/bin/bash

###################################
#   CONFIGURACIÓN DEL SCRIPT
###################################

APP_USER="isard"
BASE_DIR="/home/$APP_USER/imw-vps-gowebapp/javaspringbootwebapp"
PROJECT_DIR="$BASE_DIR/webapp"
SERVICE_NAME="webapp"   # Cambia si tu servicio systemd se llama diferente

###################################
echo "🔄 Actualizando archivos de la aplicación…"
###################################

# Comprobación de existencia del proyecto
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ ERROR: No existe el directorio del proyecto: $PROJECT_DIR"
    exit 1
fi

# Crear directorios necesarios por si no existen
mkdir -p "$PROJECT_DIR/src/main/resources/templates"
mkdir -p "$PROJECT_DIR/src/main/java/com/example/webapp"

###################################
# COPIA DE ARCHIVOS
###################################

# 1. application.properties
if [ -f "$BASE_DIR/application.properties" ]; then
    cp "$BASE_DIR/application.properties" \
       "$PROJECT_DIR/src/main/resources/application.properties"
    echo "✔️ application.properties actualizado"
else
    echo "❌ No existe application.properties en $BASE_DIR"
fi

# 2. index.html
if [ -f "$BASE_DIR/index.html" ]; then
    cp "$BASE_DIR/index.html" \
       "$PROJECT_DIR/src/main/resources/templates/index.html"
    echo "✔️ index.html actualizado"
else
    echo "❌ No existe index.html en $BASE_DIR"
fi

# 3. contacto.html
if [ -f "$BASE_DIR/contacto.html" ]; then
    cp "$BASE_DIR/contacto.html" \
       "$PROJECT_DIR/src/main/resources/templates/contacto.html"
    echo "✔️ contacto.html actualizado"
else
    echo "❌ No existe contacto.html en $BASE_DIR"
fi

# 4. HomeController.java
if [ -f "$BASE_DIR/HomeController.java" ]; then
    cp "$BASE_DIR/HomeController.java" \
       "$PROJECT_DIR/src/main/java/com/example/webapp/HomeController.java"
    echo "✔️ HomeController.java actualizado"
else
    echo "❌ No existe HomeController.java en $BASE_DIR"
fi

###################################
echo "🔨 Compilando el proyecto…"
###################################

cd "$PROJECT_DIR"
./gradlew build --quiet

if [ $? -ne 0 ]; then
    echo "❌ Error al compilar el proyecto."
    exit 1
fi

###################################
echo "🔁 Reiniciando el servicio systemd…"
###################################

sudo systemctl restart $SERVICE_NAME

if [ $? -ne 0 ]; then
    echo "❌ Error al reiniciar el servicio $SERVICE_NAME"
    exit 1
fi

###################################
echo "✔️ Actualización completada correctamente."
echo "🌐 Puedes acceder ahora a la aplicación en: http://<IP-SERVIDOR>:<PUERTO>/"
###################################
