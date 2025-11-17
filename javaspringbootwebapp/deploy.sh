#!/bin/bash

### -----------------------------
### CONFIGURACIÓN
### -----------------------------
APP_USER="isard"
APP_NAME="webapp"
BASE_DIR="/home/$APP_USER/imw-vps-gowebapp"
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
mkdir -p "$BASE_DIR"

unzip "$ZIP_FILE" -d "$BASE_DIR"
mv "$BASE_DIR"/webapp "$APP_ROOT" 2>/dev/null || true

cd "$APP_ROOT"

### -----------------------------
echo "⚙️ Configurando propiedades..."
### -----------------------------
mkdir -p src/main/resources

cat > src/main/resources/application.properties <<EOF
spring.application.name=$APP_NAME
server.port=$APP_PORT
spring.thymeleaf.prefix=classpath:/templates/
spring.thymeleaf.suffix=.html
EOF


### -----------------------------
echo "🧩 Creando controlador..."
### -----------------------------
mkdir -p src/main/java/com/example/webapp

cat > src/main/java/com/example/webapp/HomeController.java <<EOF
package com.example.webapp;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.ui.Model;

import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
public class HomeController {

    @GetMapping("/")
    public String index(HttpServletRequest request, Model model) {

        model.addAttribute("lenguaje", "Spring Boot");
        model.addAttribute("fechaHora", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        model.addAttribute("ip", request.getRemoteAddr());
        model.addAttribute("navegador", request.getHeader("User-Agent"));
        model.addAttribute("versionJava", System.getProperty("java.version"));

        return "index";
    }

    @GetMapping("/contacto")
    public String contacto() {
        return "contacto";
    }
}
EOF


### -----------------------------
echo "🧩 Creando index.html..."
### -----------------------------
mkdir -p src/main/resources/templates

cat > src/main/resources/templates/index.html <<'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="es">
<head>
<meta charset="UTF-8">
<title>Aplicación Java - Spring Boot</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light text-dark">
<div class="container py-5">
<div class="card shadow-lg p-4 border-0 rounded-4">
<h1 class="text-center mb-4 text-primary">☕ Aplicación en <span th:text="${lenguaje}"></span></h1>

<div class="row g-3">
<div class="col-md-6">
<p><strong>📅 Fecha y hora:</strong> <span th:text="${fechaHora}"></span></p>
<p><strong>🌐 IP del cliente:</strong> <span th:text="${ip}"></span></p>
</div>
<div class="col-md-6">
<p><strong>🧭 Navegador:</strong> <span th:text="${navegador}"></span></p>
<p><strong>☕ Versión de Java:</strong> <span th:text="${versionJava}"></span></p>
</div>
</div>

<div class="text-center mt-4">
<a href="/contacto" class="btn btn-outline-primary">📬 Ir a contacto</a>
</div>

</div>
</div>
</body>
</html>
EOF


### -----------------------------
echo "🧩 Creando contacto.html..."
### -----------------------------
cat > src/main/resources/templates/contacto.html <<'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="es">
<head>
<meta charset="UTF-8">
<title>Contacto - Spring Boot</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light text-dark">
<div class="container py-5">
<div class="card shadow-lg p-4 border-0 rounded-4">
<h1 class="text-center text-success mb-4">📬 Formulario de contacto</h1>

<form>
<div class="mb-3">
<label class="form-label">Nombre</label>
<input type="text" class="form-control" placeholder="Tu nombre">
</div>

<div class="mb-3">
<label class="form-label">Email</label>
<input type="email" class="form-control" placeholder="tu@email.com">
</div>

<div class="mb-3">
<label class="form-label">Mensaje</label>
<textarea class="form-control" rows="4" placeholder="Escribe tu mensaje..."></textarea>
</div>

<button type="submit" class="btn btn-primary w-100">Enviar</button>
</form>

<div class="text-center mt-4">
<a href="/" class="btn btn-outline-secondary">🏠 Volver al inicio</a>
</div>

</div>
</div>
</body>
</html>
EOF


### -----------------------------
echo "🔨 Compilando proyecto..."
### -----------------------------
./gradlew build

### -----------------------------
echo "🛠 Creando servicio systemd..."
### -----------------------------
sudo bash -c "cat > /etc/systemd/system/$APP_NAME.service" <<EOF
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