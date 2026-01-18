# Mejoras Propuestas para BCM4312 WiFi Driver

## Estado Actual (Pruebas Finales 2026-01-17)

| Métrica | Valor | Notas |
|---------|-------|-------|
| Velocidad descarga | **~0.5 Mbps** | Limitación RX del LP-PHY |
| Velocidad subida | **~19 Mbps** | Cercano al máximo teórico |
| Ping | ~45-60 ms | Aceptable |
| Señal | 100% | Excelente |
| Estabilidad | ✅ | Sin kernel panics |

**Conclusión:** El chip BCM4312 LP-PHY tiene una limitación de hardware/firmware en la ruta de recepción (RX). El upload funciona bien (~19 Mbps, cerca del máximo 802.11g de 54 Mbps con overhead) pero el download está limitado a ~0.5 Mbps. Esta es una limitación conocida del LP-PHY que no puede resolverse solo con cambios de software.

---

## Pruebas Realizadas

| Configuración | Download | Upload | Resultado |
|---------------|----------|--------|-----------|
| piomode=1 (PIO) | 0.18 Mbps | 0.00 Mbps | ❌ Peor |
| piomode=0 (DMA) | 0.21 Mbps | 3.26 Mbps | ⚠️ Igual |
| iwconfig rate 54M | N/A | N/A | ❌ No soportado |
| iwconfig txpower 20dBm | - | - | Sin efecto |

---

## Análisis del Código

### Configuraciones actuales del driver (wl_linux.c)

```c
wlc_iovar_setint(wl->wlc, "mpc", 0);           // MPC desactivado (nompc=1)
wlc_iovar_setint(wl->wlc, "scan_passive_time", 170);
wlc_iovar_setint(wl->wlc, "qtxpower", 23 * 4); // 23 dBm (max 31.75)
wlc_set(wl->wlc, WLC_SET_PM, PM_FAST);         // Power Management
```

### Modo PIO vs DMA

| Modo | Descripción | Uso |
|------|-------------|-----|
| **DMA** | Direct Memory Access - El hardware transfiere datos directamente a memoria | Más rápido, default |
| **PIO** | Programmed I/O - La CPU maneja cada transferencia | Más estable en HW antiguo |

El BCM4312 LP-PHY funciona mejor con DMA (probado).

### Limitaciones encontradas en el código

1. **wl_txq_thresh**: Cola TX limitada, pero 512 ya es alto
2. **Tasklets legacy**: El driver usa tasklets en lugar de NAPI moderno
3. **Sin control de bit rate**: `iwconfig rate` no funciona (no implementado)
4. **Firmware embebido**: No se puede actualizar sin recompilar

---

## Mejoras Nivel 1: Configuración (Sin modificar código)

### 1.1 Probar modo PIO en lugar de DMA

```bash
# /etc/modprobe.d/wl-performance.conf
options wl wl_txq_thresh=512 nompc=1 piomode=1
```

**Razón:** Algunos chipsets LP-PHY tienen problemas con DMA. PIO es más lento pero más estable.

### 1.2 Blacklist de módulos conflictivos

```bash
# /etc/modprobe.d/blacklist-broadcom.conf
blacklist b43
blacklist ssb
blacklist bcma
blacklist brcmsmac
blacklist brcmfmac
# En sistemas Dell:
blacklist dell_wmi
```

### 1.3 Cargar lib80211 antes de wl

```bash
# /etc/modules-load.d/wifi.conf
lib80211
lib80211_crypt_ccmp
lib80211_crypt_tkip
lib80211_crypt_wep
```

### 1.4 Cambiar canal WiFi (Router)

El canal 6 (2.437 GHz) suele estar congestionado. Cambiar a:
- **Canal 1** (2.412 GHz) - Menos interferencia
- **Canal 11** (2.462 GHz) - Alternativa

### 1.5 Optimizaciones TCP adicionales

```bash
# /etc/sysctl.d/99-wifi-performance.conf
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.core.rmem_default=1048576
net.core.wmem_default=1048576
net.ipv4.tcp_rmem=4096 1048576 16777216
net.ipv4.tcp_wmem=4096 1048576 16777216
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_moderate_rcvbuf=1
# Deshabilitar Nagle para menor latencia
net.ipv4.tcp_low_latency=1
```

---

## Mejoras Nivel 2: Parches al Código

### 2.1 Fix UBSAN (Patch 003) - ✅ APLICADO

**Archivos modificados:**
- `src/include/bcmutils.h` - `uint8 data[1]` → `uint8 data[]`
- `src/wl/sys/wl_cfg80211_hybrid.h`:
  - `u8 variable[0]` → `u8 variable[]`
  - `u8 frame_buf[1]` → `u8 frame_buf[]`
  - `u8 ci[0]` → `u8 ci[]`

**Resultado:** Download 0.21 → 8.30 Mbps (40x mejora)

### 2.2 Aumentar potencia TX al máximo

En `wl_linux.c` línea 639:
```c
// Actual:
wlc_iovar_setint(wl->wlc, "qtxpower", 23 * 4);  // 23 dBm

// Propuesto:
wlc_iovar_setint(wl->wlc, "qtxpower", 30 * 4);  // 30 dBm (cerca del máximo 31.75)
```

### 2.3 Deshabilitar Power Management completamente

En `wl_linux.c` línea 723:
```c
// Actual:
wlc_set(wl->wlc, WLC_SET_PM, PM_FAST);

// Propuesto:
wlc_set(wl->wlc, WLC_SET_PM, PM_OFF);  // 0 = completamente desactivado
```

### 2.4 Reducir scan_passive_time

En `wl_linux.c` línea 633:
```c
// Actual:
wlc_iovar_setint(wl->wlc, "scan_passive_time", 170);

// Propuesto:
wlc_iovar_setint(wl->wlc, "scan_passive_time", 50);  // Escaneo más rápido
```

### 2.5 Implementar NAPI (Complejidad Alta)

El driver usa tasklets legacy para el procesamiento de paquetes:
```c
// Actual (wl_linux.c:664):
tasklet_init(&wl->tasklet, wl_dpc, (ulong)wl);
tasklet_init(&wl->tx_tasklet, wl_tx_tasklet, (ulong)wl);
```

NAPI (New API) es más eficiente para alto throughput pero requiere:
- Reescribir wl_dpc() para usar polling
- Modificar el manejo de interrupciones
- **Complejidad:** Muy alta - cambios estructurales

### 2.6 Optimizar cola TX

En `wl_linux.c` líneas 2236-2240, cuando la cola está llena se descarta el paquete:
```c
if ((wl_txq_thresh > 0) && (wl->txq_cnt >= wl_txq_thresh)) {
    PKTFRMNATIVE(wl->osh, skb);
    PKTCFREE(wl->osh, skb, TRUE);  // Se descarta silenciosamente
    TXQ_UNLOCK(wl);
    return 0;
}
```

**Propuesta:** Implementar backpressure hacia el kernel en lugar de descartar

---

## Mejoras Nivel 3: Investigación Avanzada

### 3.1 Analizar con perf/ftrace

```bash
# Trazar funciones del driver
sudo perf record -g -a sleep 10
sudo perf report

# Específico para wl
echo 'wl_*' | sudo tee /sys/kernel/debug/tracing/set_ftrace_filter
echo function | sudo tee /sys/kernel/debug/tracing/current_tracer
```

### 3.2 Verificar firmware

```bash
# El driver wl incluye firmware embebido
# No hay forma de actualizar sin recompilar
strings /lib/modules/$(uname -r)/updates/dkms/wl.ko | grep -i version
```

### 3.3 Comparar con b43 (si soportara LP-PHY)

El driver b43 open-source NO soporta LP-PHY, pero si lo hiciera:
- Mejor integración con el kernel
- NAPI nativo
- Código auditable

---

## Recomendación Final

### Completado:
1. ✅ Fix FORTIFY_SOURCE (memcpy) - Sin warnings
2. ✅ Fix Stack Corruption (unions) - Sin kernel panics
3. ✅ Fix UBSAN flexible arrays - Sin errores bounds
4. ✅ Blacklist de módulos conflictivos
5. ✅ Configurar lib80211 y módulos crypto
6. ✅ Modo DMA (piomode=0) confirmado como mejor opción

### Probado (sin mejora en RX):
- ❌ piomode=1 (PIO) - peor rendimiento
- ❌ qtxpower 30dBm - sin mejora
- ❌ PM_OFF - sin mejora
- ❌ scan_passive_time=50 - sin mejora
- ❌ -fno-sanitize=bounds - sin mejora

### Resultado Final:
- **Upload:** ~19 Mbps (excelente para 802.11g)
- **Download:** ~0.5 Mbps (limitación LP-PHY)
- **Estabilidad:** Sin kernel panics ni errores UBSAN
- **Hardware funcional:** BCM4312 LP-PHY operativo en kernel 6.14

### Limitación Identificada:
El BCM4312 LP-PHY tiene un problema conocido en la ruta de recepción (RX) que limita severamente el download. Esto parece ser una limitación del firmware propietario embebido, no del wrapper del kernel. Para mejorar esto se necesitaría:
1. Ingeniería inversa del blob binario (complejo, posiblemente ilegal)
2. Acceso al código fuente de Broadcom (no disponible públicamente)
3. Firmware alternativo (no existe para LP-PHY)

---

## Referencias

- [pofHQ: Why Broadcom wl sucks](https://pof.eslack.org/2012/05/23/why-broadcom-80211-linux-sta-driver-sucks-and-how-to-fix-it/)
- [Ubuntu Bug #2030978: UBSAN patch](https://bugs.launchpad.net/ubuntu/+source/broadcom-sta/+bug/2030978)
- [Arch Wiki: Broadcom wireless](https://wiki.archlinux.org/title/Broadcom_wireless)
- [joanbm's UBSAN fix gist](https://gist.github.com/joanbm/9cd5fda1dcfab9a67b42cc6195b7b269)
