# Guía de Recuperación - Dell 1545 WiFi Driver

## Cuando el Sistema No Arranca (Kernel Panic)

### Método 1: Recovery Mode via GRUB

1. **Apagar completamente** el equipo (mantener botón 5+ segundos)

2. **Encender** y presionar **ESC** o **Shift** inmediatamente (antes del logo)

3. En el menú GRUB, seleccionar:
   - "Advanced options for Ubuntu"
   - Línea con "recovery mode"

4. En el menú de Recovery:
   - Seleccionar "network" (activa la red)
   - Seleccionar "root" (consola root)

5. Ejecutar:
   ```bash
   # Desactivar driver WiFi
   echo "blacklist wl" > /etc/modprobe.d/blacklist-wl.conf

   # Reiniciar
   reboot
   ```

### Método 2: Editar GRUB al Vuelo

1. En el menú GRUB, presionar **'e'** para editar

2. Buscar la línea que empieza con `linux` y agregar al final:
   ```
   modprobe.blacklist=wl
   ```

3. Presionar **Ctrl+X** o **F10** para arrancar

### Método 3: USB de Rescate

Si no puedes acceder a GRUB:

1. Crear USB booteable con Ubuntu/Kubuntu

2. Arrancar desde USB (F12 en Dell para menú de boot)

3. Seleccionar "Try Ubuntu"

4. Montar el disco del sistema:
   ```bash
   sudo mount /dev/sda3 /mnt  # Ajustar partición
   echo "blacklist wl" | sudo tee /mnt/etc/modprobe.d/blacklist-wl.conf
   sudo umount /mnt
   ```

5. Reiniciar sin USB

## Habilitar SSH en Recovery Mode

```bash
rm /run/nologin
systemctl start ssh
```

## Magic SysRq (Reinicio Limpio cuando está Congelado)

Secuencia de teclas cuando el sistema está congelado:

**Alt + SysRq + R, E, I, S, U, B**

(Una tecla cada segundo, SysRq suele ser Fn+PrintScreen en laptops)

- R = Raw (quita control del teclado a X11)
- E = tErminate (termina todos los procesos)
- I = kIll (mata procesos que no terminaron)
- S = Sync (guarda datos a disco)
- U = Unmount (desmonta sistemas de archivos)
- B = reBoot (reinicia)

## Configurar Arranque sin Interfaz Gráfica

Para arranques más rápidos durante debugging:

```bash
# Cambiar a modo texto
sudo systemctl set-default multi-user.target

# Volver a modo gráfico
sudo systemctl set-default graphical.target
```

## Logs Útiles después de un Crash

```bash
# Ver arranques anteriores
journalctl --list-boots

# Ver logs del arranque anterior (crash)
journalctl -b -1 | grep -iE '(wl|panic|error|warning)'

# Ver dmesg actual
sudo dmesg | grep -iE '(wl|brcm|broadcom)'
```
