#!/bin/bash
# Script para aplicar parches al driver broadcom-sta
# Ejecutar en el Dell 1545 como root

set -e

DRIVER_SRC="/usr/src/broadcom-sta-6.30.223.271"
PATCHES_DIR="$(dirname $0)/../patches"

echo "=== Aplicando parches al driver Broadcom STA ==="

# Backup
if [ ! -f "$DRIVER_SRC/src/wl/sys/wl_cfg80211_hybrid.c.original" ]; then
    cp "$DRIVER_SRC/src/wl/sys/wl_cfg80211_hybrid.c" \
       "$DRIVER_SRC/src/wl/sys/wl_cfg80211_hybrid.c.original"
    echo "Backup creado"
fi

# Aplicar fix de memcpy/FORTIFY
echo "Aplicando fix de memcpy..."
sed -i '3080s/.*/\tif (ie->offset > 0 \&\& ie->offset <= WL_TLV_INFO_MAX) { __builtin_memcpy(dst, \&ie->buf[0], ie->offset); }/' \
    "$DRIVER_SRC/src/wl/sys/wl_cfg80211_hybrid.c"

# Verificar
if grep -q '__builtin_memcpy' "$DRIVER_SRC/src/wl/sys/wl_cfg80211_hybrid.c"; then
    echo "Fix de memcpy aplicado correctamente"
else
    echo "ERROR: Fix no aplicado"
    exit 1
fi

# Recompilar
echo "Recompilando driver..."
dkms remove broadcom-sta/6.30.223.271 --all 2>/dev/null || true
dkms install broadcom-sta/6.30.223.271

echo "=== Completado ==="
echo "Reinicia el sistema o ejecuta: modprobe -r wl && modprobe wl"
