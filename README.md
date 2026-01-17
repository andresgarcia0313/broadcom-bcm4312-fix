# Dell Inspiron 1545 - Broadcom BCM4312 WiFi Driver Fix

## Resumen

Driver `wl` (broadcom-sta) reparado para funcionar sin kernel panic en kernel 6.x.

### Hardware
- **Equipo:** Dell Inspiron 1545
- **Chip WiFi:** Broadcom BCM4312 802.11b/g LP-PHY (PCI ID: 14e4:4315)
- **SO:** Kubuntu 24.04 LTS
- **Kernel:** 6.14.0-37-generic
- **Driver:** broadcom-sta-dkms 6.30.223.271

---

## Problemas Resueltos

### 1. Error FORTIFY_SOURCE (memcpy) ✅

**Síntoma:**
```
memcpy: detected field-spanning write (size 207) of single field "dst" (size 0)
WARNING: CPU: 1 PID: 515 at wl_cfg80211_hybrid.c:3080
```

**Causa:** Kernel 6.x FORTIFY_SOURCE detecta memcpy a flexible array members.

**Fix:** Usar `__builtin_memcpy` que bypasea FORTIFY:
```c
// Línea 3090 en wl_cfg80211_hybrid.c
if (ie->offset > 0 && ie->offset <= WL_TLV_INFO_MAX) {
    __builtin_memcpy(dst, &ie->buf[0], ie->offset);
}
```

### 2. Stack Corruption (Kernel Panic) ✅

**Síntoma:**
```
Kernel panic - not syncing: stack-protector: Kernel stack is corrupted in wl_cfg80211_connect+0x979 [wl]
```

**Causa:** `struct wl_join_params` contiene `wl_assoc_params_t` con flexible array `chanspec_list[]`. Al declarar en la pila, el compilador asigna 0 bytes para el array. `wl_ch_to_chanspec()` escribe en `chanspec_list[0]` → corrupción de pila.

**Fix:** Usar union con buffer extra:
```c
// En wl_cfg80211_connect() y wl_cfg80211_join_ibss()
union {
    struct wl_join_params p;
    u8 buf[sizeof(struct wl_join_params) + sizeof(chanspec_t) * 2];
} join_params_u;
struct wl_join_params *join_params = &join_params_u.p;
```

Cambiar todas las referencias: `join_params.` → `join_params->`

### 3. UBSAN Array Bounds Warnings (Performance) ✅

**Síntoma:**
- WiFi conectado con señal excelente (-36 dBm, Link Quality 70/70)
- Bit Rate reportado: 48 Mb/s
- Throughput real: **0.21 Mbps** (100x menor al esperado)

**Causa:** Linux 6.5+ tightened UBSAN bounds checking (commit 2d47c6956ab3). Arrays declarados como `[0]` o `[1]` al final de structs disparan warnings que degradan el rendimiento.

**Fix:** Convertir a sintaxis C99 flexible array `[]`:
```c
// bcmutils.h - struct bcm_tlv
uint8   data[];    // Era: data[1]

// wl_cfg80211_hybrid.h - struct beacon_proberesp
u8 variable[];     // Era: variable[0]

// wl_cfg80211_hybrid.h - struct wl_cfg80211_event_q
u8 frame_buf[];    // Era: frame_buf[1]

// wl_cfg80211_hybrid.h - struct wl_cfg80211_connect_info
u8 ci[] __attribute__ ((__aligned__(NETDEV_ALIGN)));  // Era: ci[0]
```

**Resultado:** Throughput mejoró de **0.21 Mbps → 8.30 Mbps** (40x mejora)

---

## Archivos Modificados

**Ubicación:** `/usr/src/broadcom-sta-6.30.223.271/`

### wl_cfg80211_hybrid.c
| Línea | Cambio |
|-------|--------|
| ~703 | Union con buffer en `wl_cfg80211_join_ibss()` |
| ~1003 | Union con buffer en `wl_cfg80211_connect()` |
| 3090 | `__builtin_memcpy` en `wl_cp_ie()` |

### wl_cfg80211_hybrid.h (UBSAN fix)
| Línea | Cambio |
|-------|--------|
| 106 | `u8 variable[]` en struct beacon_proberesp |
| 129 | `u8 frame_buf[]` en struct wl_cfg80211_event_q |
| 201 | `u8 ci[]` en struct wl_cfg80211_connect_info |

### bcmutils.h (UBSAN fix)
| Línea | Cambio |
|-------|--------|
| 562 | `uint8 data[]` en struct bcm_tlv |

---

## Comandos Útiles

### Recompilar driver
```bash
sudo dkms remove broadcom-sta/6.30.223.271 --all
sudo dkms install broadcom-sta/6.30.223.271
```

### Recargar módulo
```bash
sudo modprobe -r wl && sudo modprobe wl
```

### Ver errores
```bash
sudo dmesg | grep -iE '(wl|memcpy|panic|error)'
```

### Blacklist (emergencia)
```bash
echo "blacklist wl" | sudo tee /etc/modprobe.d/blacklist-wl.conf
```

---

## Recovery Mode

Si el sistema no arranca:

1. Reiniciar → **ESC/Shift** para GRUB
2. Advanced options → Recovery mode → root
3. Ejecutar:
```bash
echo "blacklist wl" > /etc/modprobe.d/blacklist-wl.conf
reboot
```

---

## Wake-on-LAN Configurado

### Estado
- **Habilitado en Linux:** Sí (servicio systemd)
- **MAC:** `00:25:64:41:5e:24`

### Servicio systemd
```bash
# /etc/systemd/system/wol.service
[Unit]
Description=Enable Wake-on-LAN
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/ethtool -s enp9s0 wol g
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

### Usar WoL (desde otro equipo)
```bash
# Instalar
sudo apt install wakeonlan

# Encender Dell (cuando está apagado)
wakeonlan 00:25:64:41:5e:24
```

### Requisito BIOS
- F2 → Power Management → Wake on LAN → **Enabled**

---

## Limitaciones Conocidas

- **Velocidad máxima teórica:** 54 Mbps (802.11g) - limitación del hardware BCM4312 LP-PHY
- **Velocidad real obtenida:** ~8-10 Mbps (después de aplicar todos los fixes)
- **Driver propietario:** No hay alternativa open-source funcional (b43 no soporta LP-PHY)

---

## Notas Técnicas

### Por qué ocurre el stack overflow

```c
// Estructura problemática:
typedef struct wl_assoc_params {
    struct ether_addr bssid;    // 6 bytes
    int32 chanspec_num;         // 4 bytes
    chanspec_t chanspec_list[]; // 0 bytes (flexible array)
} wl_assoc_params_t;

typedef struct wl_join_params {
    wlc_ssid_t ssid;            // 36 bytes
    wl_assoc_params_t params;   // 10 bytes (sin espacio para chanspec_list)
} wl_join_params_t;

// Cuando se declara en la pila:
struct wl_join_params join_params;  // Solo 46 bytes asignados

// Luego el código escribe fuera del buffer:
join_params->params.chanspec_list[0] = ...;  // OVERFLOW!
```

### Switch físico WiFi
El Dell 1545 tiene un switch físico de WiFi. Si `rfkill` muestra "Hard blocked: yes", buscar el switch en el lateral del laptop o usar Fn+F2.
