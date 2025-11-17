📘 README.md
Despliegue automático de aplicación Spring Boot en servidor Linux

Este proyecto incluye un script (deploy.sh) que permite desplegar automáticamente una aplicación Java Spring Boot en un servidor Linux.
El despliegue incluye:

Descompresión del proyecto

Configuración de application.properties

Creación de un controlador funcional

Generación automática de las plantillas index.html y contacto.html

Compilación con Gradle

Creación y activación del servicio systemd

Ejecución en HTTP (sin HTTPS) en el puerto 9090 (o el que configures)

🚀 Requisitos

Antes de ejecutar el script asegúrate de:

Tener un sistema operativo Ubuntu 22.04

Contar con un usuario con permisos sudo (en este script: isard)

Haber subido el archivo webapp.zip al directorio: /home/isard/imw-vps-gowebapp/

El webapp.zip debe contener un proyecto Spring Boot generado desde "https://start.spring.io/" con la siguiente configuracion:

Configuración:

● Project: Maven
● Language: Java
● Spring Boot: 3.4.11
● Group: com.example
● Artifact: webapp
● Dependencies:
○ Spring Web
○ Thymeleaf (para vistas HTML dinámicas)

<img width="1133" height="595" alt="image" src="https://github.com/user-attachments/assets/cda1e7c0-9038-45e4-8bd9-3fc1758e0f5e" />


▶️ Cómo ejecutar el script
1️⃣ Dar permisos de ejecución

Desde la terminal, en la carpeta donde está el script:

chmod +x deploy.sh

2️⃣ Ejecutar el script
./deploy.sh

📝 ¿Qué hace el script exactamente?

El script realiza las siguientes acciones:

✔ Instalación de dependencias

Java OpenJDK 17

unzip

✔ Preparación del proyecto

Elimina despliegues anteriores

Descomprime webapp.zip

Crea la estructura necesaria

✔ Configura el puerto HTTP en application.properties
✔ Genera dos plantillas Thymeleaf:

index.html

contacto.html

✔ Crea un controlador:

/ → página inicial con datos dinámicos

/contacto → formulario con Bootstrap

✔ Compila con Gradle (./gradlew build)
✔ Crea servicio systemd:

Ruta:

/etc/systemd/system/webapp.service

✔ Activa el servicio
sudo systemctl enable webapp
sudo systemctl restart webapp

🌐 Acceder a la aplicación

Una vez desplegada, abre en tu navegador:

http://<IP_DEL_SERVIDOR>:9090/


Ejemplo:

http://10.2.136.230:9090/

🛠 Comandos útiles

Ver estado del servicio:

sudo systemctl status webapp


Ver logs:

sudo journalctl -u webapp -f


Reiniciar aplicación:

sudo systemctl restart webapp
