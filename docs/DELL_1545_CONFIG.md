# Dell Inspiron 1545 - Configuración Completa

> **Sistema:** Kubuntu 24.04 LTS  
> **Fecha configuración:** 2026-01-17  
> **Propósito:** Estación de trabajo optimizada para hardware limitado

---

## 1. Hardware General

| Componente | Especificación |
|------------|----------------|
| **CPU** | Intel Pentium Dual-Core T4200 @ 2.00GHz |
| **RAM** | 2.9 GB DDR2 |
| **Almacenamiento** | HDD SATA (lento) |
| **WiFi** | Broadcom BCM4312 802.11b/g |
| **Gráficos** | Intel GMA 4500M |
| **Touchpad** | AlpsPS/2 ALPS GlidePoint |
| **BIOS** | Legacy (no UEFI), compatible GPT |

---

## 2. Adaptador WiFi - Especificaciones Completas

### Identificación Hardware

| Propiedad | Valor |
|-----------|-------|
| **Fabricante** | Broadcom Inc. |
| **Modelo** | BCM4312 802.11b/g LP-PHY |
| **Nombre Comercial** | Dell Wireless 1397 WLAN Mini-Card |
| **PCI ID** | 14e4:4315 |
| **Subsystem** | Dell 1028:000c |
| **Revisión** | 01 |
| **Bus** | PCI Express Mini Card |
| **Interfaz Sistema** | wlp12s0 |
| **Dirección MAC** | 00:26:5e:17:35:8b |

### Especificaciones Técnicas

| Característica | Valor |
|----------------|-------|
| **Estándares** | IEEE 802.11b, IEEE 802.11g |
| **Banda de Frecuencia** | 2.4 GHz (Single Band) |
| **Canales Disponibles** | 1-13 (2.412 - 2.472 GHz) |
| **Velocidad Máxima** | 54 Mbps |
| **Potencia TX** | 23 dBm (200 mW) |
| **Modulación** | OFDM (802.11g), DSSS/CCK (802.11b) |
| **Antenas** | 1x1 SISO |

### Seguridad Soportada

| Protocolo | Soportado |
|-----------|-----------|
| **WPA** | ✅ Sí |
| **WPA2** | ✅ Sí |
| **WPA3** | ❌ No |
| **TKIP** | ✅ Sí |
| **AES/CCMP** | ✅ Sí |
| **WEP** | ✅ Sí (obsoleto) |

### Canales 2.4 GHz

| Canal | Frecuencia | Notas |
|-------|------------|-------|
| 1 | 2.412 GHz | Recomendado |
| 2 | 2.417 GHz | |
| 3 | 2.422 GHz | |
| 4 | 2.427 GHz | |
| 5 | 2.432 GHz | |
| 6 | 2.437 GHz | Recomendado |
| 7 | 2.442 GHz | |
| 8 | 2.447 GHz | |
| 9 | 2.452 GHz | |
| 10 | 2.457 GHz | |
| 11 | 2.462 GHz | Recomendado |
| 12 | 2.467 GHz | |
| 13 | 2.472 GHz | |

### Driver

| Propiedad | Valor |
|-----------|-------|
| **Nombre** | wl (Broadcom STA) |
| **Tipo** | Propietario (MIXED/Proprietary) |
| **Paquete** | bcmwl-kernel-source |
| **Módulo Kernel** | /lib/modules/*/updates/dkms/wl.ko.zst |
| **Dependencias** | cfg80211 |
| **DKMS** | Sí (recompila con cada kernel) |

### Estado Actual Conexión

| Métrica | Valor |
|---------|-------|
| **ESSID** | Internet2GPiso4 |
| **Modo** | Managed |
| **Frecuencia** | 2.437 GHz (Canal 6) |
| **Velocidad Actual** | 54 Mb/s |
| **Calidad Enlace** | 70/70 (100%) |
| **Señal** | -34 dBm (Excelente) |
| **Power Management** | Activado |

### Niveles de Señal (Referencia)

| Señal (dBm) | Calidad | Descripción |
|-------------|---------|-------------|
| -30 a -50 | Excelente | Muy cerca del AP |
| -50 a -60 | Buena | Conexión estable |
| -60 a -70 | Aceptable | Puede haber lentitud |
| -70 a -80 | Débil | Desconexiones posibles |
| < -80 | Muy débil | Conexión inestable |

### Limitaciones

| Limitación | Impacto |
|------------|---------|
| **Solo 2.4 GHz** | No puede usar redes 5 GHz (menos congestionadas) |
| **802.11g máximo** | Sin soporte 802.11n/ac/ax (velocidades modernas) |
| **54 Mbps máximo** | Suficiente para navegación, no para transferencias grandes |
| **1x1 SISO** | Sin MIMO, menor rendimiento que adaptadores modernos |
| **Driver propietario** | Requiere DKMS, puede fallar con kernels muy nuevos |

### Instalación Driver

```bash
# Instalar driver propietario Broadcom
sudo apt update
sudo apt install bcmwl-kernel-source

# Cargar módulo
sudo modprobe wl

# Verificar
lspci -k | grep -A 3 Network
# Debe mostrar: Kernel driver in use: wl
```

**⚠️ NO usar:** `firmware-b43-installer` (URL de descarga muerta desde 2024)

---

## 3. Particiones

```
Dispositivo   Tamaño   Tipo              Etiqueta
/dev/sda1     8 MB     BIOS Boot         -
/dev/sda2     6 GB     Linux swap        Memoria-Virtual
/dev/sda3     ~227 GB  Linux filesystem  Sistema
```

### /etc/fstab
```
UUID=a173dd94-7fe0-47d9-8919-d07c756c53a7 /    ext4  defaults,noatime  0 1
UUID=c423741c-53d0-46cb-810f-d1c5da88ffde none swap  sw                0 0
```

---

## 4. Firefox (Repositorio Oficial Mozilla)

### Instalación
```bash
# Añadir repositorio Mozilla
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
  sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | \
  sudo tee /etc/apt/sources.list.d/mozilla.list

# Priorizar sobre snap
cat << PREF | sudo tee /etc/apt/preferences.d/mozilla
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
PREF

# Instalar
sudo apt update
sudo apt install firefox firefox-l10n-es-es
```

### Optimización Firefox
Archivo: `~/.mozilla/firefox/*.default*/user.js`
```javascript
user_pref("dom.ipc.processCount", 2);
user_pref("dom.ipc.processCount.webIsolated", 1);
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.predictor.enabled", false);
user_pref("browser.cache.memory.capacity", 65536);
user_pref("browser.sessionhistory.max_entries", 10);
user_pref("browser.sessionstore.interval", 60000);
```

---

## 5. Hibernación

### GRUB
Archivo: `/etc/default/grub`
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash resume=UUID=c423741c-53d0-46cb-810f-d1c5da88ffde"
```

```bash
sudo update-grub
```

### Initramfs
Archivo: `/etc/initramfs-tools/conf.d/resume`
```
RESUME=UUID=c423741c-53d0-46cb-810f-d1c5da88ffde
```

```bash
sudo update-initramfs -u -k all
```

### Polkit (permitir hibernar)
Archivo: `/etc/polkit-1/localauthority/50-local.d/hibernate.pkla`
```ini
[Enable hibernate]
Identity=unix-user:*
Action=org.freedesktop.login1.hibernate;org.freedesktop.login1.handle-hibernate-key
ResultActive=yes
ResultInactive=yes
ResultAny=yes
```

### Systemd Sleep
Archivo: `/etc/systemd/sleep.conf`
```ini
[Sleep]
AllowHibernation=yes
HibernateMode=shutdown
```

---

## 6. Touchpad (Botones físicos rotos)

Archivo: `/etc/X11/xorg.conf.d/50-synaptics.conf`
```
Section "InputClass"
    Identifier "ALPS Touchpad Personalizado"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Driver "synaptics"
    
    # Taps
    Option "TapButton1" "1"
    Option "TapButton2" "3"
    Option "TapButton3" "2"
    
    # Zona clic derecho: esquina inferior derecha 25%x25%
    Option "SoftButtonAreas" "75% 0 75% 0 0 0 0 0"
    Option "RTCornerButton" "3"
    Option "RBCornerButton" "3"
    
    # Scroll vertical en borde derecho (15% ancho)
    Option "VertEdgeScroll" "on"
    Option "RightEdge" "85%"
    Option "BottomEdge" "75%"
    
    # Sensibilidad
    Option "FingerLow" "10"
    Option "FingerHigh" "15"
    Option "MaxTapTime" "300"
    Option "PalmDetect" "off"
EndSection
```

Requiere: `sudo apt install xserver-xorg-input-synaptics`

---

## 7. Optimizaciones de Memoria

### Swappiness y Cache
Archivo: `/etc/sysctl.d/99-performance.conf`
```
vm.swappiness=10
vm.vfs_cache_pressure=50
```

### ZRAM (Swap comprimido en RAM)
```bash
sudo apt install zram-tools
```

Archivo: `/etc/default/zramswap`
```
ALGO=zstd
SIZE=2048
PRIORITY=100
```

**Resultado Swap:**
| Dispositivo | Tamaño | Prioridad | Uso |
|-------------|--------|-----------|-----|
| ZRAM | 2 GB | 100 | Primero (comprimido en RAM) |
| HDD | 6 GB | -2 | Respaldo (lento) |

### Earlyoom (Previene congelamiento OOM)
```bash
sudo apt install earlyoom
sudo systemctl enable --now earlyoom
```

**Función:** Mata procesos antes de que el sistema se congele por falta de RAM.

---

## 8. I/O Scheduler: BFQ

**Propósito:** Prioriza I/O de aplicaciones interactivas sobre procesos de fondo.

Archivo: `/etc/udev/rules.d/60-ioscheduler.rules`
```
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
```

Verificar:
```bash
cat /sys/block/sda/queue/scheduler
# Salida esperada: none mq-deadline [bfq]
```

---

## 9. Transparent Hugepages Desactivado

**Propósito:** Evita micro-pausas por desfragmentación de memoria.

Archivo: `/etc/systemd/system/disable-thp.service`
```ini
[Unit]
Description=Disable Transparent Huge Pages
After=sysinit.target local-fs.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled && echo never > /sys/kernel/mm/transparent_hugepage/defrag"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable --now disable-thp.service
```

Verificar:
```bash
cat /sys/kernel/mm/transparent_hugepage/enabled
# Salida esperada: always madvise [never]
```

---

## 10. Journal Limitado

Archivo: `/etc/systemd/journald.conf.d/size.conf`
```ini
[Journal]
SystemMaxUse=30M
SystemKeepFree=100M
MaxFileSec=1week
```

Verificar:
```bash
journalctl --disk-usage
# Debe ser ≤30M
```

---

## 11. Servicios Deshabilitados

### Indexadores (Usuario)
```bash
# Baloo (KDE)
balooctl disable
balooctl purge

# Tracker (GNOME)
systemctl --user mask tracker-extract-3.service tracker-miner-fs-3.service
```

Archivo: `~/.config/baloofilerc`
```ini
[Basic Settings]
Indexing-Enabled=false
```

### Servicios Sistema
| Servicio | Razón | Comando |
|----------|-------|---------|
| apport | Reportes errores Ubuntu | `sudo systemctl disable --now apport.service apport-autoreport.path` |
| whoopsie | Reportes errores Ubuntu | `sudo systemctl disable --now whoopsie.service whoopsie.path` |
| ModemManager | Módems 3G/4G (no usado) | `sudo systemctl disable --now ModemManager.service` |
| accounts-daemon | Cuentas online (no usado) | `sudo systemctl disable --now accounts-daemon.service` |
| kerneloops | Reportes kernel | `sudo systemctl disable --now kerneloops.service` |

---

## 12. KDE Plasma Optimizado

Archivo: `~/.config/kwinrc`
```ini
[Compositing]
Enabled=false
Backend=XRender
AnimationSpeed=0

[Plugins]
blurEnabled=false
contrastEnabled=false
slidingpopupsEnabled=false
fadeEnabled=false
loginEnabled=false
logoutEnabled=false
translucencyEnabled=false
```

Archivo: `~/.config/kdeglobals`
```ini
[KDE]
AnimationDurationFactor=0
```

Aplicar sin reiniciar:
```bash
kwriteconfig5 --file kwinrc --group Compositing --key Enabled false
kwriteconfig5 --file kdeglobals --group KDE --key AnimationDurationFactor 0
qdbus org.kde.KWin /Compositor suspend
```

---

## 13. Verificación Rápida

```bash
# Estado general
echo "=== RAM ===" && free -h
echo "=== Swap ===" && swapon --show
echo "=== BFQ ===" && cat /sys/block/sda/queue/scheduler
echo "=== THP ===" && cat /sys/kernel/mm/transparent_hugepage/enabled
echo "=== Journal ===" && journalctl --disk-usage
echo "=== WiFi ===" && iwconfig 2>/dev/null | grep -E "ESSID|Signal"
echo "=== Arranque ===" && systemd-analyze

# Servicios deshabilitados
systemctl is-enabled apport ModemManager accounts-daemon earlyoom
```

---

## 14. Resumen de Optimizaciones

| Área | Antes | Después |
|------|-------|---------|
| RAM en reposo | ~1.5 GB | ~850 MB |
| I/O Scheduler | mq-deadline | BFQ |
| THP | madvise | never |
| Journal | Ilimitado | 30 MB máx |
| Compositor | OpenGL + efectos | Desactivado |
| Swap primario | HDD 6GB | ZRAM 2GB |
| Servicios innecesarios | Activos | Deshabilitados |

---

## 15. Notas Importantes

1. **WiFi:** Usar `bcmwl-kernel-source`, NO `firmware-b43-installer`
2. **WiFi Limitación:** Solo 2.4 GHz, máximo 54 Mbps (802.11g)
3. **Touchpad:** Los botones físicos no funcionan, usar zonas táctiles
4. **Hibernación:** Requiere swap ≥ tamaño RAM (6GB > 2.9GB ✓)
5. **Firefox:** Instalado desde repositorio Mozilla, NO snap
6. **Reinicio requerido** después de cambios en GRUB/initramfs

---

*Documento generado: 2026-01-17*

---

## 16. Optimizaciones WiFi (Velocidad y Latencia)

> **Aplicadas:** 2026-01-17  
> **Problema inicial:** 1 Mbps en speedtest  
> **Objetivo:** Alcanzar máximo del adaptador (~20 Mbps)

### Power Management Desactivado

**Problema:** El ahorro de energía WiFi causa latencia alta y pérdida de paquetes.

Archivo: `/etc/NetworkManager/conf.d/wifi-powersave-off.conf`
```ini
[connection]
wifi.powersave = 2
```

**Valores wifi.powersave:**
| Valor | Significado |
|-------|-------------|
| 0 | Usar default |
| 1 | Ignorar |
| 2 | **Desactivar** (recomendado) |
| 3 | Activar |

Verificar:
```bash
iwconfig wlp12s0 | grep Power
# Debe mostrar: Power Management:off
```

### Parámetros de Red Optimizados

Archivo: `/etc/sysctl.d/99-wifi-performance.conf`
```ini
# Reducir tiempo de espera TCP
net.ipv4.tcp_fin_timeout = 15

# TCP Fast Open (reduce latencia conexiones nuevas)
net.ipv4.tcp_fastopen = 3

# Buffers de red aumentados
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# Baja latencia
net.ipv4.tcp_low_latency = 1

# Control de congestión y cola
net.ipv4.tcp_congestion_control = cubic
net.core.netdev_max_backlog = 5000
```

Aplicar sin reiniciar:
```bash
sudo sysctl -p /etc/sysctl.d/99-wifi-performance.conf
```

### Cola de Transmisión Aumentada

Archivo: `/etc/udev/rules.d/70-wifi-txqueue.rules`
```
ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", RUN+="/sbin/ip link set %k txqueuelen 2000"
```

**Efecto:** Reduce pérdida de paquetes en ráfagas de tráfico.

Verificar:
```bash
ip link show wlp12s0 | grep qlen
# Debe mostrar: qlen 2000
```

### Región Regulatoria

Archivo: `/etc/default/crda`
```
REGDOMAIN=BO
```

**Nota:** El driver Broadcom `wl` no usa el sistema estándar de regulación Linux (iw reg), pero esta configuración aplica para otros adaptadores.

### Resumen de Optimizaciones WiFi

| Optimización | Antes | Después | Impacto |
|--------------|-------|---------|---------|
| Power Management | ON | OFF | ⭐⭐⭐⭐⭐ |
| TCP Fast Open | OFF | ON | ⭐⭐⭐ |
| TCP Low Latency | OFF | ON | ⭐⭐⭐ |
| txqueuelen | 1000 | 2000 | ⭐⭐ |
| Buffers TCP | Default | 16MB | ⭐⭐ |

### Verificación Rápida WiFi

```bash
# Estado completo
iwconfig wlp12s0

# Solo métricas importantes
echo "=== WiFi Status ===" && \
iwconfig wlp12s0 2>/dev/null | grep -E "ESSID|Bit Rate|Power|Quality|Signal"

# Test de velocidad desde terminal
curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3
```

### Velocidades Esperadas

| Escenario | Velocidad |
|-----------|-----------|
| Máximo teórico adaptador | 54 Mbps |
| Máximo real adaptador | 20-25 Mbps |
| **Con optimizaciones** | 15-22 Mbps |
| Sin optimizaciones (problema) | 1 Mbps |

### Limitación Hardware

```
╔═══════════════════════════════════════════════════════════════╗
║  El adaptador BCM4312 (802.11g) tiene un límite físico de     ║
║  ~20 Mbps de throughput real.                                  ║
║                                                                 ║
║  Para velocidades mayores, se requiere:                        ║
║  • Cable Ethernet (aprovecha 200 Mbps completos), o            ║
║  • Adaptador USB WiFi 802.11ac/ax                              ║
╚═══════════════════════════════════════════════════════════════╝
```
