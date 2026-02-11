# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Descripción del Proyecto

Macro de cambio automático de herramienta (ATC - Automatic Tool Changer) para un centro de maquinado CNC. El archivo principal es `T_FUNC.NC`, programa O0123, escrito en Macro B (Fanuc-compatible).

## Lenguaje y Formato

- **Lenguaje**: Macro B de CNC (compatible con controladores tipo Fanuc/Syntec)
- **Extensión**: `.NC` — archivos de código G con macros
- **Sin build system**: Los archivos `.NC` se transfieren directamente al controlador CNC (vía USB, red, o DNC)

## Arquitectura de la Macro O0123

La macro gestiona el ciclo completo de cambio de herramienta con esta secuencia:

1. **Verificación pre-vuelo** (Sec 1b): Confirma cono sujetado vía P22 antes de iniciar
2. **Reset de salidas** (Sec 2): Apaga todas las salidas y verifica cono sujetado post-reset vía P22
3. **Validaciones** (Sec 3-4): Salidas tempranas si T=0 o T=actual; valida rango de herramientas
4. **Retracción y orientación** (Sec 5): Sube Z, orienta husillo, confirma orientación vía polling P20
5. **Liberación de herramienta** (Sec 6): Acerca ATC, verifica sujeción P22, libera cono, verifica liberación P21, retrae Z
6. **Rotación del magazín** (Sec 7-9): Algoritmo de ruta más corta, conteo por pulsos P23, detención
7. **Inserción de herramienta** (Sec 10): Acerca ATC, baja Z, cierra cono, verifica sujeción P22, regresa ATC
8. **Finalización** (Sec 11-12): Cancela orientación, aplica compensación de longitud, verificación final P22

## Variables Macro Clave

| Variable | Función |
|----------|---------|
| `#200` | Número de herramienta a cambiar (entrada) |
| `#201` | Número de herramienta actual (leída de `#4120`) |
| `#400` | Máximo número de herramientas en magazín (21) |
| `#401` | Altura segura eje Z |
| `#402` | Posición Z de retracción completa |
| `#403` | Posición Z 2.5mm arriba del punto de referencia |
| `#404` | Punto de referencia eje Z |
| `#405` | Velocidad de avance (F) para movimientos Z |
| `#408` | Retardo para detener rotación adelante (ms) |
| `#409` | Retardo para detener rotación atrás (ms) |
| `#409+N` | Valores de compensación de longitud por herramienta |

## Señales I/O (M89/M88)

| Comando | Pin | Función |
|---------|-----|---------|
| `M89 P6` | P6 | Liberar/cerrar cono (L1=abrir, L0=cerrar) |
| `M89 P8` | P8 | Rotación magazín adelante |
| `M89 P9` | P9 | Rotación magazín atrás |
| `M89 P17` | P17 | Orientación del husillo |
| `M89 P20` | P20 | Regresar ATC |
| `M89 P21` | P21 | Acercar/señal de salida ATC |
| `#1020` | P20 | Sensor orientación husillo (L1=orientado) |
| `#1021` | P21 | Sensor liberación cono (L1=liberado) |
| `#1022` | P22 | Sensor sujeción cono (L1=sujetado) |
| `M88 P23` | P23 | Sensor de conteo de herramientas |
| `M88 P25` | P25 | Sensor de regreso ATC |
| `M88 P26` | P26 | Sensor de posición (salida en lugar) |

## Notas para Modificación

- Los comentarios en español (orienta, acerca atc, libera cono, cierra cono, etc.) documentan las acciones mecánicas del ATC
- `M89` = escribir salida digital (P=pin, L=nivel 0/1)
- `M88` = esperar entrada digital (P=pin, L=nivel esperado)
- `#1000+N` se usa para leer entradas digitales en polling loops (verificaciones críticas de sensores)
- Patrón de polling: `WHILE[[#10XX != VAL] && [#3 < N]] DO3` con `G04 P100` y alarma `#3000` si timeout
- Sensores críticos: P20=orientación husillo, P21=liberación cono, P22=sujeción cono
- Los tiempos de retardo (`G04 P...`) están en milisegundos y son críticos para la sincronización mecánica — modificar con precaución
- La compensación de longitud se almacena en `#[409+#200]` y se escribe al sistema de coordenadas G54 vía `#5223`
