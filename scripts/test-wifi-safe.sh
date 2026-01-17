#!/bin/bash
# Script de prueba WiFi segura con timeouts
# Ejecutar como root en el Dell 1545

set -e

SSID="${1:-Internet2GPiso4}"
PASSWORD="${2:-asde7104}"
INTERFACE="wlp12s0"
TIMEOUT=30

log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

cleanup() {
    log "Limpiando..."
    nmcli device disconnect $INTERFACE 2>/dev/null || true
}

trap cleanup EXIT

log "=== Prueba WiFi Segura ==="
log "SSID: $SSID"
log "Interfaz: $INTERFACE"

# 1. Verificar que el driver está cargado
if ! lsmod | grep -q "^wl "; then
    log "ERROR: Driver wl no está cargado"
    exit 1
fi
log "Driver wl cargado OK"

# 2. Verificar interfaz
if ! ip link show $INTERFACE > /dev/null 2>&1; then
    log "ERROR: Interfaz $INTERFACE no existe"
    exit 1
fi
log "Interfaz $INTERFACE OK"

# 3. Escanear redes (prueba básica)
log "Escaneando redes..."
if ! timeout $TIMEOUT iwlist $INTERFACE scan > /tmp/wifi_scan.txt 2>&1; then
    log "ERROR: Timeout o error en escaneo"
    cat /tmp/wifi_scan.txt
    exit 1
fi
REDES=$(grep -c ESSID /tmp/wifi_scan.txt || echo "0")
log "Redes encontradas: $REDES"

# 4. Verificar que la red objetivo existe
if ! grep -q "ESSID:\"$SSID\"" /tmp/wifi_scan.txt; then
    log "ADVERTENCIA: Red '$SSID' no encontrada en escaneo"
    log "Redes disponibles:"
    grep ESSID /tmp/wifi_scan.txt | head -10
fi

# 5. Intentar conexión con timeout
log "Intentando conexión a '$SSID'..."
log "ADVERTENCIA: Si el sistema se congela, usar Alt+SysRq+REISUB"

if timeout $TIMEOUT nmcli device wifi connect "$SSID" password "$PASSWORD" ifname $INTERFACE 2>&1; then
    log "CONEXIÓN EXITOSA"
    ip a show $INTERFACE | grep inet

    # Test de conectividad
    if ping -c 3 -W 5 8.8.8.8 > /dev/null 2>&1; then
        log "Conectividad a Internet: OK"
    else
        log "Conectividad a Internet: FALLO"
    fi
else
    RESULT=$?
    if [ $RESULT -eq 124 ]; then
        log "ERROR: Timeout en conexión"
    else
        log "ERROR: Fallo en conexión (código $RESULT)"
    fi
    exit 1
fi

log "=== Prueba completada ==="
