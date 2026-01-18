# Análisis de Ingeniería Inversa - Broadcom wl Driver

## Resumen Ejecutivo

**Módulo:** wl.ko (broadcom-sta 6.30.223.271)
**Firmware embebido:** 6.30.223.0 (2013-12-15)
**Tamaño total:** 7.3 MB (descomprimido)
**Arquitectura:** x86_64 ELF relocatable

---

## Metodología Aplicada

### 1. Análisis Estático
- Extracción de símbolos con `nm`
- Identificación de strings con `strings`
- Desensamblado con `objdump`
- Análisis estructural con `radare2`

### 2. Herramientas Utilizadas
| Herramienta | Propósito |
|-------------|-----------|
| nm | Extracción de símbolos |
| strings | Búsqueda de cadenas |
| objdump | Desensamblado básico |
| radare2 | Análisis avanzado, grafos de llamadas |
| readelf | Información de secciones ELF |

---

## Estructura del Módulo

### Secciones Principales
| Sección | Tamaño | Contenido |
|---------|--------|-----------|
| .text | 1.6 MB | Código ejecutable (blob propietario) |
| .rodata | 3.2 MB | Datos constantes, tablas PHY, firmware |
| .data | 1.4 MB | Datos inicializados |

### Estadísticas de Símbolos
- **267 funciones públicas** (exportadas)
- **204 símbolos relacionados con RX** (recepción)
- **Firmware de 2013** embebido

---

## Funciones Críticas de Recepción (RX)

### Flujo Principal de Recepción
```
wl_isr (ISR)
    └── wl_dpc (DPC)
        └── wlc_dpc
            └── wlc_recv (4757 bytes) ← FUNCIÓN PRINCIPAL
                ├── wlc_recvdata (3475 bytes)
                ├── wlc_recvdata_ordered (2714 bytes)
                └── wlc_recvdata_sendup (544 bytes)
```

### Funciones PHY de Recepción
```c
// Tablas de ganancia RX para LP-PHY (Low Power PHY)
dot11lcnphytbl_2G_rx_gain_info_rev*
dot11lcn40phytbl_2G_rx_gain_info_rev*

// Funciones de configuración
wlc_phy_rx_iq_est_acphy      // Estimación IQ
wlc_phy_rxcore_setstate_acphy // Estado del core RX
wlc_phy_rxgain_set           // Configuración de ganancia
```

### Funciones de Procesamiento de Paquetes
```c
osl_pktdata    // Obtener datos del paquete
osl_pktlen     // Longitud del paquete
osl_pktpull    // Remover bytes del inicio
osl_pktdup     // Duplicar paquete
osl_pkt_tonative // Convertir a sk_buff nativo
```

---

## Análisis de wlc_recv (Función Principal RX)

### Características
- **Dirección:** 0x0804c1de
- **Tamaño:** 4757 bytes (función muy grande)
- **Complejidad:** 306 bloques básicos
- **Llamadas:** ~50 funciones diferentes

### Estructura Observada
1. Obtiene datos del paquete (`osl_pktdata`)
2. Valida longitud (`osl_pktlen`)
3. Procesa headers 802.11
4. Verifica tipo de frame (beacon, data, management)
5. Llama a handlers específicos según tipo
6. Envía datos hacia arriba (`wlc_recvdata_sendup`)

---

## Tablas PHY Identificadas

### Tablas de Ganancia RX (LP-PHY)
```
dot11lcnphytbl_2G_rx_gain_info_rev0
dot11lcnphytbl_2G_rx_gain_info_rev1
dot11lcnphytbl_2G_rx_gain_info_rev2
dot11lcnphytbl_2G_ext_lna_rx_gain_info_*
dot11lcnphytbl_5G_rx_gain_info_*
```

Estas tablas contienen valores de configuración para:
- Ganancia del LNA (Low Noise Amplifier)
- Ganancia del mezclador
- Ganancia del filtro
- Control automático de ganancia (AGC)

---

## Posibles Causas del Problema RX

### 1. Tablas de Ganancia Subóptimas
Las tablas `dot11lcnphytbl_2G_rx_gain_info_*` pueden tener valores incorrectos para el hardware LP-PHY específico.

### 2. Firmware Desactualizado
El firmware embebido es de **2013**, posiblemente sin optimizaciones para kernels modernos.

### 3. Configuración de AGC
El control automático de ganancia podría estar mal calibrado para señales fuertes.

### 4. Procesamiento DMA
Posible bottleneck en la transferencia DMA de RX.

---

## Próximos Pasos Sugeridos

### Análisis Profundo
1. **Decompilación con Ghidra** - Análisis más detallado de wlc_recv
2. **Tracing dinámico** - Usar kprobes para interceptar llamadas
3. **Análisis de tablas PHY** - Comparar con valores conocidos de otros drivers

### Modificaciones Potenciales
1. **Ajustar tablas de ganancia** - Requiere entender formato binario
2. **Bypass de validaciones** - Identificar checks que limitan throughput
3. **Parche de firmware** - Muy complejo, requiere entender formato propietario

---

## Archivos Generados

```
reverse-engineering/
├── wl.ko                    # Módulo descomprimido
├── wl_dpc.asm              # Desensamblado de wl_dpc
├── wl_dpc_rxwork.asm       # Desensamblado de wl_dpc_rxwork
├── wlc_recv_analysis.txt   # Análisis de wlc_recv
└── ANALYSIS_REPORT.md      # Este documento
```

---

## Conclusiones

1. **El driver es analizable** - Tiene símbolos, no está ofuscado
2. **El problema está en el blob** - La lógica de RX está en código propietario
3. **Modificar es posible pero complejo** - Requiere entender el formato del firmware
4. **Alternativa realista** - Ajustar parámetros del kernel wrapper o tablas accesibles

---

## Referencias

- [Broadcom BCM43xx Reverse Engineering](https://bcm-v4.sipsolutions.net/)
- [Linux Wireless b43 Driver](https://wireless.wiki.kernel.org/en/users/Drivers/b43)
- [radare2 Documentation](https://book.rada.re/)
- [Ghidra NSA](https://ghidra-sre.org/)

---

*Generado: 2026-01-17*
*Herramientas: nm, strings, objdump, radare2 5.5.0*
