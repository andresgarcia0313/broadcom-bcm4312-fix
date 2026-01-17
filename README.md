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

---

## Archivos Modificados

**Ubicación:** `/usr/src/broadcom-sta-6.30.223.271/src/wl/sys/wl_cfg80211_hybrid.c`

| Línea | Cambio |
|-------|--------|
| ~703 | Union con buffer en `wl_cfg80211_join_ibss()` |
| ~1003 | Union con buffer en `wl_cfg80211_connect()` |
| 3090 | `__builtin_memcpy` en `wl_cp_ie()` |

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

- **Velocidad máxima:** 54 Mbps (802.11g) - limitación del hardware BCM4312 LP-PHY
- **Driver propietario:** No hay alternativa open-source funcional (b43 no soporta LP-PHY)
- **Rendimiento observado:** ~0.15-1 Mbps en speedtest (subóptimo)

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
