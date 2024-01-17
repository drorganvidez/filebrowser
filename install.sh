#!/bin/bash

read -p "Ingrese el nombre del subdominio X para '/filebrowser/X': " server
read -p "Ingrese el nombre de usuario del sistema donde se está instalando File Browser: " user
read -p "Ingrese un usuario administrador de File Browser: " filebrowser_user
read -p "Ingrese la contraseña del usuario administrador de File Browser: " filebrowser_pass

# Actualiza los paquetes del sistema
sudo apt update
sudo apt upgrade -y

# Instala File Browser
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# Crea la configuración de File Browser
sudo mkdir -p /etc/filebrowser
sudo tee /etc/filebrowser/default.json > /dev/null <<EOL
{
  "port": 4201,
  "baseURL": "/filebrowser/$server",
  "address": "",
  "log": "stdout",
  "database": "/etc/filebrowser/filebrowser.db",
  "root": "/",
  "auth": true
}
EOL

# Crea el archivo filebrowser.db
sudo /usr/local/bin/filebrowser -d /etc/filebrowser/filebrowser.db config init

# Agrega el usuario proporcionado con la contraseña proporcionada
cd /etc/filebrowser
sudo /usr/local/bin/filebrowser users add $filebrowser_user "$filebrowser_pass" --perm.admin

# Crea el archivo de configuración systemd
sudo tee /etc/systemd/system/filebrowser.service > /dev/null <<EOL
[Unit]
Description=File browser: %I
After=network.target

[Service]
User=$user
Group=$user
ExecStart=/usr/local/bin/filebrowser -c /etc/filebrowser/default.json

[Install]
WantedBy=multi-user.target
EOL

# Configura los permisos correctos para el usuario en la base de datos
sudo chown -R $user:$user /etc/filebrowser/filebrowser.db

# Habilita File Browser para que inicie en el arranque del sistema
sudo systemctl enable filebrowser

# Inicia File Browser
sudo service filebrowser start

# Verifica el estado de File Browser
sudo service filebrowser status

echo "File Browser ha sido instalado y configurado en el puerto 4201."
echo "Puedes acceder a File Browser en http://tu-direccion-ip:4201/filebrowser/$server"
echo "Usuario: $filebrowser_user"
echo "Contraseña: $filebrowser_pass"
