# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Descripción del Proyecto

Macro de cambio automático de herramienta (ATC - Automatic Tool Changer) para un centro de maquinado CNC. El archivo principal es `T_FUNC (1).NC`, programa O0123, escrito en Macro B (Fanuc-compatible).

## Lenguaje y Formato

- **Lenguaje**: Macro B de CNC (compatible con controladores tipo Fanuc/Syntec)
- **Extensión**: `.NC` — archivos de código G con macros
- **Sin build system**: Los archivos `.NC` se transfieren directamente al controlador CNC (vía USB, red, o DNC)

## Arquitectura de la Macro O0123

La macro gestiona el ciclo completo de cambio de herramienta con esta secuencia:

1. **Validación** (líneas 8-24): Verifica que el número de herramienta solicitada (`#200`) y actual (`#201`) sean válidos y no excedan el máximo del magazín (`#400`)
2. **Retracción y preparación** (líneas 26-29): Sube eje Z a altura segura, apaga refrigerante, orienta husillo
3. **Liberación de herramienta actual** (líneas 31-40): Acerca ATC, libera cono, retrae Z
4. **Cálculo de rotación óptima** (líneas 42-63): Algoritmo de ruta más corta para girar el magazín (adelante/atrás) minimizando posiciones recorridas
5. **Conteo de posiciones** (líneas 65-79): Loop WHILE que cuenta pulsos del sensor hasta llegar a la herramienta destino
6. **Inserción de herramienta nueva** (líneas 81-103): Detiene rotación, baja Z, cierra cono, retrae ATC, aplica compensación de longitud

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
| `M89 P17` | P17 | Orientación del husillo |
| `M89 P21` | P21 | Acercar/señal de salida ATC |
| `M89 P20` | P20 | Regresar ATC |
| `M89 P6` | P6 | Liberar/cerrar cono (L1=abrir, L0=cerrar) |
| `M89 P8` | P8 | Rotación magazín adelante |
| `M89 P9` | P9 | Rotación magazín atrás |
| `M88 P23` | P23 | Sensor de conteo de herramientas |
| `M88 P25` | P25 | Sensor de regreso ATC |
| `M88 P26` | P26 | Sensor de posición (salida en lugar) |

## Notas para Modificación

- Los comentarios en español (orienta, acerca atc, libera cono, cierra cono, etc.) documentan las acciones mecánicas del ATC
- `M89` = escribir salida digital (P=pin, L=nivel 0/1)
- `M88` = esperar entrada digital (P=pin, L=nivel esperado)
- Los tiempos de retardo (`G04 P...`) están en milisegundos y son críticos para la sincronización mecánica — modificar con precaución
- La compensación de longitud se almacena en `#[409+#200]` y se escribe al sistema de coordenadas G54 vía `#5223`
