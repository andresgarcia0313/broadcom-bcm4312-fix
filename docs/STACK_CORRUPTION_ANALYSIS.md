# Análisis de Stack Corruption en wl_cfg80211_connect

## Error Observado

```
Kernel panic - not syncing: stack-protector: Kernel stack is corrupted in wl_cfg80211_connect+0x979 [wl]
```

## Información del Call Stack

```
nl80211_connect [cfg80211]
genl_rcv_msg
netlink_rcv_skb
genl_rcv
netlink_unicast
netlink_sendmsg
___sys_sendmsg
__sys_sendmsg
__x64_sys_sendmsg
do_syscall_64
```

## Análisis

### Offset del Error
- **Offset:** `+0x979` = 2425 bytes desde el inicio de la función
- La función `wl_cfg80211_connect` tiene aproximadamente 100 líneas (líneas 999-1090)
- El offset sugiere que el error está cerca del final de la función

### Función wl_cfg80211_connect (líneas 999-1090)

Variables locales sospechosas:
```c
struct wl_join_params join_params;  // Estructura grande en stack
size_t join_params_size;
char valc;
s32 err = 0;
```

### Posibles Causas

1. **join_params overflow**: La estructura `wl_join_params` puede ser muy grande y algún memcpy la desborda

2. **SSID overflow**:
   ```c
   join_params.ssid.SSID_len = min(sizeof(join_params.ssid.SSID), sme->ssid_len);
   memcpy(&join_params.ssid.SSID, sme->ssid, join_params.ssid.SSID_len);
   ```
   Si `sme->ssid_len` es mayor que el buffer, podría desbordar

3. **wl_ch_to_chanspec**: Esta función modifica `join_params` y podría escribir fuera de límites

4. **profile->ssid overflow**:
   ```c
   memcpy(wl->profile->ssid.SSID, &join_params.ssid.SSID, join_params.ssid.SSID_len);
   ```

## Tareas de Investigación

1. [ ] Ver tamaño de `struct wl_join_params`
2. [ ] Ver tamaño de `SSID` buffer (debería ser 32 bytes máximo según IEEE 802.11)
3. [ ] Revisar `wl_ch_to_chanspec()` para ver si escribe más allá del buffer
4. [ ] Agregar validación de límites antes de cada memcpy

## Posible Fix

Agregar validación estricta de tamaños:
```c
// Antes de memcpy de SSID
if (sme->ssid_len > IEEE80211_MAX_SSID_LEN) {
    WL_ERR(("SSID too long: %zu\n", sme->ssid_len));
    return -EINVAL;
}
join_params.ssid.SSID_len = min_t(size_t, sizeof(join_params.ssid.SSID), sme->ssid_len);
```

## Referencias

- Bug Launchpad #2030978: UBSAN errors en wl driver
- Kernel 6.x FORTIFY_SOURCE cambios
- Stack protector en kernel: CONFIG_STACKPROTECTOR_STRONG
