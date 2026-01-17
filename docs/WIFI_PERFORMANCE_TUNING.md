# Optimización de Rendimiento WiFi - BCM4312

## Problema

Speedtest muestra ~0.15 Mbps de descarga cuando el plan es 200 Mbps.

## Diagnóstico

| Parámetro | Valor | Estado |
|-----------|-------|--------|
| Señal | -29 dBm | Excelente |
| Link Quality | 70/70 | Perfecto |
| Bit Rate | 36 Mb/s | Subóptimo (max 54) |
| Errores TX/RX | 0 | OK |
| Power Management | off | OK |
| Canal | 6 | Congestionado |

## Parámetros del módulo wl

```
parm: passivemode:int      - Modo pasivo
parm: wl_txq_thresh:int    - Umbral cola TX (default: bajo)
parm: oneonly:int          - Solo una instancia
parm: piomode:int          - PIO vs DMA
parm: instance_base:int    - Base de instancia
parm: nompc:int            - No Minimum Power Consumption
parm: intf_name:string     - Nombre de interfaz
```

## Optimizaciones Aplicadas

### 1. Parámetros del módulo
```bash
modprobe wl wl_txq_thresh=512 nompc=1
```
- `wl_txq_thresh=512`: Mayor cola de transmisión
- `nompc=1`: Desactiva control de potencia mínima

### 2. Tasa de bits forzada
```bash
iwconfig wlp12s0 rate 54M
```

### 3. Cola de transmisión de red
```bash
ip link set wlp12s0 txqueuelen 2000
```

### 4. TCP/IP optimizado
```bash
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216
sysctl -w net.ipv4.tcp_fastopen=3
```

## Hacer permanente

### Parámetros del módulo
```bash
# /etc/modprobe.d/wl-performance.conf
options wl wl_txq_thresh=512 nompc=1
```

### Configuración de red
```bash
# /etc/udev/rules.d/70-wifi-performance.rules
ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlp12s0", RUN+="/sbin/ip link set %k txqueuelen 2000"
```

### Sysctl
```bash
# /etc/sysctl.d/99-wifi-performance.conf
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1
```

## Limitaciones del hardware

- **Chip:** BCM4312 LP-PHY (Low Power PHY)
- **Año:** 2008
- **Estándar:** 802.11b/g (sin 802.11n)
- **Máximo teórico:** 54 Mbps
- **Máximo práctico:** 20-25 Mbps
- **Driver:** Propietario (wl), sin alternativa open-source funcional

## Recomendación

Si se necesita mayor velocidad WiFi, considerar un adaptador USB WiFi moderno con soporte 802.11ac/ax y drivers open-source.
