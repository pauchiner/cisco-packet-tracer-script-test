#!/bin/bash

set -e

echo "=========================================="
echo "   INSTALACIÓN CISCO PACKET TRACER 9.0.0"
echo "=========================================="

# --------------------------------------------------
# Comprobar sudo
# --------------------------------------------------

if ! command -v sudo >/dev/null 2>&1; then
    echo "ERROR: sudo no está instalado."
    exit 1
fi

# --------------------------------------------------
# Actualizar sistema
# --------------------------------------------------

echo
echo "----------------------------------"
echo "  Actualizando el sistema..."
echo "----------------------------------"

sudo dpkg --configure -a || true
sudo apt --fix-broken install -y

# --------------------------------------------------
# Activar repositorios Ubuntu Jammy
# --------------------------------------------------

echo
echo "----------------------------------"
echo "  Activando repositorios Jammy..."
echo "----------------------------------"

# Copia de seguridad de sources.list
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup-packettracer

# Descomentar repositorios deb existentes
sudo sed -i 's/^# *deb /deb /' /etc/apt/sources.list

sudo apt update

# --------------------------------------------------
# Instalar dependencias de Packet Tracer
# --------------------------------------------------

echo
echo "----------------------------------"
echo "  Instalando dependencias..."
echo "----------------------------------"

sudo apt install -y \
    libgl1-mesa-glx \
    libxcb-xinerama0-dev

# --------------------------------------------------
# Descargar Cisco Packet Tracer 9.0
# --------------------------------------------------

echo
echo "----------------------------------"
echo "  Descargando Packet Tracer 9.0..."
echo "----------------------------------"

DOWNLOAD_URL="https://archive.org/download/packettracer900/CiscoPacketTracer_900_Ubuntu_64bit.deb"

DOWNLOAD_DIR="$HOME/packettracer-install"

mkdir -p "$DOWNLOAD_DIR"

DEB_FILE="$DOWNLOAD_DIR/CiscoPacketTracer_900_Ubuntu_64bit.deb"

echo
echo "URL:"
echo "$DOWNLOAD_URL"
echo
echo "Destino:"
echo "$DEB_FILE"
echo

if [ -f "$DEB_FILE" ]; then
    echo "El archivo ya existe."
    echo "No es necesario volver a descargarlo."
else
    wget --show-progress -O "$DEB_FILE" "$DOWNLOAD_URL"
fi

# --------------------------------------------------
# Comprobar descarga
# --------------------------------------------------

if [ ! -s "$DEB_FILE" ]; then
    echo
    echo "ERROR: La descarga de Packet Tracer ha fallado."
    exit 1
fi

echo
echo "Descarga completada correctamente."

# --------------------------------------------------
# Instalar Packet Tracer
# --------------------------------------------------

echo
echo "----------------------------------"
echo "  Instalando Packet Tracer..."
echo "----------------------------------"

sudo dpkg -i "$DEB_FILE" || true

# Resolver dependencias
echo
echo "----------------------------------"
echo "  Resolviendo dependencias..."
echo "----------------------------------"

sudo apt --fix-broken install -y

# Configurar paquetes pendientes
sudo dpkg --configure -a

# --------------------------------------------------
# Crear acceso directo
# --------------------------------------------------

echo
echo "----------------------------------"
echo "  Creando acceso directo..."
echo "----------------------------------"

sudo tee /usr/share/applications/packettracer.desktop > /dev/null <<'EOF'
[Desktop Entry]
Version=9.0
Name=Cisco Packet Tracer
Comment=Network Simulation Tool
Exec=/usr/local/bin/packettracer
Icon=/opt/pt/art/app.png
Terminal=false
Type=Application
Categories=Education;Network;
StartupNotify=true
EOF

sudo chmod 644 /usr/share/applications/packettracer.desktop

# --------------------------------------------------
# Actualizar menú de aplicaciones
# --------------------------------------------------

echo
echo "----------------------------------"
echo "  Actualizando menú..."
echo "----------------------------------"

if command -v update-desktop-database >/dev/null 2>&1; then
    sudo update-desktop-database /usr/share/applications
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true
fi

# --------------------------------------------------
# Desactivar/restaurar repositorios
# --------------------------------------------------

echo
echo "----------------------------------"
echo "  Restaurando repositorios..."
echo "----------------------------------"

if [ -f /etc/apt/sources.list.backup-packettracer ]; then
    sudo cp /etc/apt/sources.list.backup-packettracer /etc/apt/sources.list
    sudo rm /etc/apt/sources.list.backup-packettracer
fi

sudo apt update

# --------------------------------------------------
# Final
# --------------------------------------------------

echo
echo "=========================================="
echo "   INSTALACIÓN FINALIZADA"
echo "=========================================="
echo
echo "Cisco Packet Tracer 9.0 ha sido instalado."
echo
echo "Puedes abrirlo desde:"
echo "  Aplicaciones → Educación → Cisco Packet Tracer"
echo
echo "O ejecutando:"
echo "  packettracer"
echo
echo "El instalador se ha guardado en:"
echo "  $DEB_FILE"
echo
