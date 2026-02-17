# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Descripcion del Proyecto

Macro de cambio automatico de herramienta (ATC - Automatic Tool Changer) para un centro de maquinado CNC con controlador **ADTECH CNC4940**. El archivo principal es `T_FUNC.NC`, programa O0123, escrito en Macro B (Fanuc-compatible).

## Lenguaje y Formato

- **Lenguaje**: Macro B de CNC (compatible con controladores tipo Fanuc/Syntec)
- **Extension**: `.NC` — archivos de codigo G con macros
- **Sin build system**: Los archivos `.NC` se transfieren directamente al controlador CNC (via USB, red, o DNC)
- **Encoding**: Los archivos del controlador ADTECH usan encoding chino (GB2312) en comentarios — los caracteres corruptos en `M_FUNC.NC` son normales

## Estructura del Repositorio

| Archivo | Descripcion |
|---------|-------------|
| `T_FUNC.NC` | **Macro principal** — programa O0123, cambio automatico de herramienta |
| `M_FUNC.NC` | Macros auxiliares del controlador (M08/M09 refrigerante, M32/M33 lubricante, F0-F11 seleccion de herramientas T01-T21, control de salidas OUT02-OUT47, husillo O203-O205) |
| `T_FUNC(ORIGINAL).NC` / `M_FUNC(original).NC` | Backups de referencia — NO modificar |
| `T_FUNC_BACKUP.NC` | Backup adicional de T_FUNC |
| `ALARMAS.md` | Documentacion detallada de las 11 alarmas activas con troubleshooting |
| `SENALES_IO.md` | Referencia completa de senales I/O con ubicacion exacta por linea |
| `GUIA.md` | Guia operativa con flujo paso a paso, diagrama, y tabla de tiempos |
| `MACRO TRAINING.pdf` | Tutorial oficial TOMATECH de macros para CNC4 Series — deployment, sintaxis, user-defined M codes |
| `MACRO ADDRESS.xlsx` | Mapa completo de direcciones macro/PLC del ADTECH CNC4940 |

## Restricciones Criticas del ADTECH CNC4940

- `#1000+N` (lectura de entradas digitales) **funciona correctamente**
- `#1100+N` (lectura de estado de salidas) **NO funciona** — la variable no refleja el estado real. Nunca usar para logica de verificacion
- Solo usar `#1000+N` para verificaciones con `#3000`
- La senal de salida P21 (acercar ATC) tiene **logica invertida** en ADTECH
- `#3906` permite leer el modo actual del controlador (0=EDIT, 1=AUTO, 2=MANUAL, 3=STEP/MPG, 4=HOME)

## Deployment al Controlador

- Los archivos de macro se guardan en **Disk D / MACRO** del controlador ADTECH
- El parametro de gestion **023** debe configurarse como "User-define" y reiniciar el controlador para activar las macros
- La carpeta MACRO contiene `T_FUNC.NC` (cambio de herramienta) y `M_FUNC.NC` (M codes auxiliares)
- Discos del controlador: Disk C (128MB, sistema), Disk D (almacenamiento usuario), USB, SD
- La transferencia se puede hacer via USB, tarjeta SD, o DNC (red)

## Mapa de Direcciones Macro del ADTECH CNC4940

Rangos de variables macro relevantes (referencia completa en `MACRO ADDRESS.xlsx`):

| Rango | Funcion |
|-------|---------|
| `#100-#199` | Variables macro volatiles (se pierden al apagar) |
| `#200-#499` | Variables macro de usuario (usadas en O0123) |
| `#500-#999` | Variables macro persistentes (se conservan al apagar) |
| `#1000-#1367` | Entradas digitales IO (READ) — `#1000`=IN0 ... `#1022`=IN22 |
| `#1400-#1767` | Salidas digitales IO (READ/WRITE) — `#1400`=OUT0 ... |
| `#1800-#1975` | LEDs del panel (READ/WRITE) |
| `#3906` | Modo actual: 0=EDIT, 1=AUTO, 2=MANUAL, 3=STEP/MPG, 4=HOME |
| `#3918` | Estado del husillo |
| `#3932` | Estado de ejecucion: 0=stop, 1=running, 3=SBK pause |
| `#4120` | Numero de herramienta T actual (READ) — usado como `#201=#4120` |
| `#5000-#5014` | Coordenadas absolutas (X,Y,Z,A,B,C) |
| `#5040-#5054` | Coordenadas mecanicas |
| `#5223` | Offset Z del sistema de coordenadas G54 (compensacion de longitud) |
| `#32000-#32574` | Offsets de herramienta por eje T1-T74 |

> **Nota:** `#1100+N` aparece en documentacion Fanuc para leer estado de salidas, pero **NO funciona** en ADTECH. Usar `#1400+N` en su lugar para leer/escribir salidas.

## Estructura de M_FUNC.NC

Archivo de fabrica con ~80 O-programs que implementan M codes definidos por usuario. Cada programa controla una salida digital via direccionamiento indirecto (`#2=1400+N` / `##2=valor`), y muchos sincronizan su LED del panel (`#1800+N`). Todos terminan con `M3000`.

> **M88 y M89 NO existen en este archivo** — son comandos nativos I/O del controlador ADTECH. `M98/M99` son subprogram call/return del sistema; en esta configuracion F1-F11 usan `T## + M06`.

### 1. Refrigerante (M08/M09) — Pin dinamico via parametro

| Programa | M Code | Accion | Pin de salida | Notas |
|----------|--------|--------|---------------|-------|
| O0008 | M08 | Refrigerante ON | `#1400+#10044` | Lee parametro `#10044` para obtener pin |
| O0009 | M09 | Refrigerante OFF | `#1400+#10044` | Mismo parametro |

### 2. Salidas del sistema con LEDs (M10-M27) — OUT02 a OUT12

Pares ON/OFF para salidas individuales. Cada programa sincroniza su LED del panel.

| Programa | M Code | Salida | Accion | LED |
|----------|--------|--------|--------|-----|
| O0010/O0011 | M10/M11 | OUT02 | ON/OFF | `#1849` |
| O0012/O0013 | M12/M13 | OUT03 | ON/OFF | `#1852` |
| O0014/O0015 | M14/M15 | OUT06 | ON/OFF | `#1854` |
| O0016/O0017 | M16/M17 | OUT07 | ON/OFF | `#1855` |
| O0018/O0019 | M18/M19 | OUT08 | ON/OFF | `#1856` |
| O0020/O0021 | M20/M21 | OUT09 | ON/OFF | `#1857` |
| O0022/O0023 | M22/M23 | OUT10 | ON/OFF | `#1860` |
| O0024/O0025 | M24/M25 | OUT11 | ON/OFF | `#1862` |
| O0026/O0027 | M26/M27 | OUT12 | ON/OFF | `#1883` |

> OUT04 y OUT05 no tienen M codes asignados en este archivo (salto de OUT03 a OUT06).

### 3. Lubricante (M32/M33) — Pin dinamico via parametro

| Programa | M Code | Accion | Pin de salida | Notas |
|----------|--------|--------|---------------|-------|
| O0032 | M32 | Lubricante ON | `#1400+#10043` | Lee parametro `#10043` para obtener pin |
| O0033 | M33 | Lubricante OFF | `#1400+#10043` | Mismo parametro |

### 4. Seleccion de herramientas F0-F11 + FCNC6D (M34-M67)

Incluye orientacion de husillo (OUT17), selector de pagina F0, seleccion de herramientas F1-F11, y FCNC6D F12-F13.

**F0 (M40/M41)**: Selector de pagina via variable `#150` (volatil). Toggle entre pagina 1 (LED OFF) y pagina 2 (LED ON). Blink 1x=pag1, 2x=pag2.

**F1-F11 (M42-M63)**: Macro ON ejecuta seleccion `T##`, asigna `#200`, marca `#153=1` y dispara `M06` para ejecutar `O0123` desde panel (solo JOG/MANUAL `#3906==2`). Macro OFF solo apaga LED.

| Programa | M Code | Fn | LED | Pag 1 | Pag 2 |
|----------|--------|----|-----|-------|-------|
| O0034/O0035 | M34/M35 | — | `#1886` | FCNC6D OUT15 | — |
| O0036/O0037 | M36/M37 | — | `#1887` | FCNC6D OUT16 | — |
| O0038/O0039 | M38/M39 | — | `#1889` | **Orient. husillo** OUT17 | — |
| O0040/O0041 | M40/M41 | F0 | `#1843` | Selector pagina (#150) | — |
| O0042/O0043 | M42/M43 | F1 | `#1848` | T1 | T11 |
| O0044/O0045 | M44/M45 | F2 | `#1853` | T2 | T12 |
| O0046/O0047 | M46/M47 | F3 | `#1858` | T3 | T13 |
| O0048/O0049 | M48/M49 | F4 | `#1863` | T4 | T14 |
| O0050/O0051 | M50/M51 | F5 | `#1874` | T5 | T15 |
| O0052/O0053 | M52/M53 | F6 | `#1890` | T6 | T16 |
| O0054/O0055 | M54/M55 | F7 | `#1891` | T7 | T17 |
| O0056/O0057 | M56/M57 | F8 | `#1892` | T8 | T18 |
| O0058/O0059 | M58/M59 | F9 | `#1893` | T9 | T19 |
| O0060/O0061 | M60/M61 | F10 | `#1894` | T10 | T20 |
| O0062/O0063 | M62/M63 | F11 | `#1895` | — | T21 |
| O0064/O0065 | M64/M65 | F12 | `#1896` | FCNC6D OUT20 | — |
| O0066/O0067 | M66/M67 | F13 | `#1897` | FCNC6D OUT21 | — |

### 5. Salidas de usuario (M68-M87, M90-M101) — OUT32 a OUT47

Salidas genericas **sin LEDs**. El numero de programa es el M code: O00XX = MXX.

| Programa | M Code | Salida | | Programa | M Code | Salida |
|----------|--------|--------|-|----------|--------|--------|
| O0068/O0069 | M68/M69 | OUT32 | | O0080/O0081 | M80/M81 | OUT38 |
| O0070/O0071 | M70/M71 | OUT33 | | O0082/O0083 | M82/M83 | OUT39 |
| O0072/O0073 | M72/M73 | OUT34 | | O0084/O0085 | M84/M85 | OUT40 |
| O0074/O0075 | M74/M75 | OUT35 | | O0086/O0087 | M86/M87 | OUT41 |
| O0076/O0077 | M76/M77 | OUT36 | | O0090/O0091 | M90/M91 | OUT42 |
| O0078/O0079 | M78/M79 | OUT37 | | O0092/O0093 | M92/M93 | OUT43 |
| | | | | O0094/O0095 | M94/M95 | OUT44 |
| | | | | O0096/O0097 | M96/M97 | OUT45 |
| | | | | O0100/O0101 | M100/M101 | OUT47 |

> **M88/M89 ausentes** — son comandos nativos I/O del ADTECH (escribir/leer entradas digitales). `M98/M99` son subprogram call/return del sistema; en F1-F11 se usa `T## + M06` para cambio fisico.

### 6. Salidas extendidas (M128-M131, M198-M199) — OUT13, OUT14, OUT46

O-numbers fuera del rango secuencial principal, con LEDs.

| Programa | M Code | Salida | Funcion | LED |
|----------|--------|--------|---------|-----|
| O0128/O0129 | M128/M129 | OUT13 | FCNC6D refrigerante 2 | `#1884` |
| O0130/O0131 | M130/M131 | OUT14 | FCNC6D contactor | `#1885` |
| O0198/O0199 | M198/M199 | OUT46 | Salida de usuario | Sin LED |

### 7. Control de husillo (O203-O205)

Programas especiales que leen el estado del husillo (`#3918`) y la velocidad (`#4118`).

| Programa | Accion | Logica |
|----------|--------|--------|
| O203 | Husillo adelante | Si `#3918==0` ejecuta `M03 S#4118`, si no `M05` |
| O204 | Husillo reversa | Si `#3918==0` ejecuta `M04 S#4118`, si no `M05` |
| O205 | Parar husillo | Ejecuta `M05` directamente |

### 8. Refrigerante y Lubricante con LEDs (O208-O213)

Versiones extendidas que sincronizan LEDs del panel. Usan pin dinamico igual que M08/M09 y M32/M33.

| Programa | Funcion | LEDs |
|----------|---------|------|
| O208 | Refrigerante ON | `#1810=1`, `#1861=1` |
| O209 | Refrigerante OFF | `#1810=0`, `#1861=0` |
| O212 | Lubricante ON | `#1811=1`, `#1859=1` |
| O213 | Lubricante OFF | `#1811=0`, `#1859=0` |

### Resumen de conteo

| Seccion | Programas | Cantidad |
|---------|-----------|----------|
| Refrigerante M08/M09 | O0008-O0009 | 2 |
| Sistema con LEDs M10-M27 | O0010-O0027 | 18 |
| Lubricante M32/M33 | O0032-O0033 | 2 |
| Herramientas F0-F11 + FCNC6D M34-M67 | O0034-O0067 | 34 |
| Usuario M68-M87 | O0068-O0087 | 20 |
| Usuario M90-M101 | O0090-O0097, O0100-O0101 | 10 |
| Extendidas M128-M131, M198-M199 | O0128-O0131, O0198-O0199 | 6 |
| Husillo | O203-O205 | 3 |
| Refrigerante/Lubricante con LEDs | O208-O209, O212-O213 | 4 |
| **Total** | | **99** |

## Arquitectura de la Macro O0123

La macro gestiona el ciclo completo de cambio de herramienta con esta secuencia:

1. **Gate de modo por origen** (inicio): Si `#153=1` (panel) permite solo JOG/MANUAL (`#3906==2`); si `#153=0` (NC) permite solo AUTO (`#3906==1`)
2. **Interlocks pre-arranque**: Bloquea ATC si husillo esta en giro (`#3918!=0`) y bloquea llamada panel en estado running (`#154==1 && #3932==1`)
3. **Verificacion pre-vuelo** (Sec 1b): Confirma cono sujetado via P22 antes de iniciar
4. **Reset de salidas** (Sec 2): Apaga todas las salidas y verifica cono sujetado post-reset via P22
5. **Validaciones** (Sec 3-4): Salidas tempranas si T=0 o T=actual; valida rango de herramientas
6. **Retraccion y orientacion** (Sec 5): Sube Z, orienta husillo, confirma orientacion via polling P20
7. **Liberacion de herramienta** (Sec 6): Acerca ATC, libera cono, verifica liberacion P21, retrae Z
8. **Rotacion del magazin** (Sec 7-9): Algoritmo de ruta mas corta, conteo por pulsos P23
9. **Insercion de herramienta** (Sec 10): Acerca ATC, baja Z, cierra cono, verifica sujecion P22, regresa ATC
10. **Finalizacion** (Sec 11-12): Cancela orientacion, aplica compensacion de longitud, verificacion final P22

## Sensores — Funciones Dedicadas (Regla Estricta)

| Sensor | Variable | Funcion UNICA | Estado activo |
|--------|----------|---------------|---------------|
| P20 | `#1020` | Orientacion husillo | L1 = orientado |
| P21 | `#1021` | Liberacion cono | L1 = liberado |
| P22 | `#1022` | Sujecion cono | L1 = sujetado |

**Nunca** usar P21 para verificar sujecion, ni P22 para verificar liberacion, ni P20 para otra cosa que orientacion.

> **IMPORTANTE:** P20 y P21 se usan tanto como salidas (M89) como entradas (#1000+N) con funciones completamente diferentes. Como salida, P20 = regresar ATC; como entrada, P20 = sensor orientacion husillo.

## Variables Macro Clave

| Variable | Funcion |
|----------|---------|
| `#153` | Origen de llamada a O0123 (0=NC, 1=teclas F panel) |
| `#154` | Snapshot temporal de origen en O0123 |
| `#200` | Numero de herramienta a cambiar (entrada) |
| `#201` | Numero de herramienta actual (leida de `#4120`) |
| `#400` | Maximo numero de herramientas en magazin (21) |
| `#401` | Altura segura eje Z |
| `#402` | Posicion Z de retraccion completa |
| `#403` | Posicion Z 2.5mm arriba del punto de referencia |
| `#404` | Punto de referencia eje Z |
| `#405` | Velocidad de avance (F) para movimientos Z |
| `#408` | Retardo para detener rotacion adelante (ms) |
| `#409` | Retardo para detener rotacion atras (ms) |
| `#409+N` | Valores de compensacion de longitud por herramienta |

## Senales I/O (M89/M88)

| Comando | Pin | Funcion |
|---------|-----|---------|
| `M89 P6` | P6 | Liberar/cerrar cono (L1=abrir, L0=cerrar) |
| `M89 P8` | P8 | Rotacion magazin adelante |
| `M89 P9` | P9 | Rotacion magazin atras |
| `M89 P17` | P17 | Orientacion del husillo |
| `M89 P20` | P20 | Regresar ATC |
| `M89 P21` | P21 | Acercar ATC (INVERTIDO en ADTECH) |
| `#1020` | P20 | Sensor orientacion husillo (L1=orientado) |
| `#1021` | P21 | Sensor liberacion cono (L1=liberado) |
| `#1022` | P22 | Sensor sujecion cono (L1=sujetado) |
| `M88 P23` | P23 | Sensor de conteo de herramientas |
| `M88 P25` | P25 | Sensor de regreso ATC (L0=en reposo) |
| `M88 P26` | P26 | Sensor de posicion ATC (L0=en posicion de trabajo) |

## Patrones de Codigo

### Polling con timeout (patron principal)
```
#3=0
WHILE[[#10XX != VAL] && [#3 < N]] DO3
    G04 P100
    #3=#3+1
END3
IF[#10XX != VAL]
{
    #3000=ALARM_NUM (MENSAJE DE ALARMA)
}
```
Timeout = N x 100ms. Ejemplo: `#3 < 30` = 3 segundos.

### Labels DO en uso
| Label | Uso | Seccion |
|-------|-----|---------|
| `DO1` | Conteo de posiciones del magazin | Sec 8 |
| `DO2` | Polling regreso ATC (alarma 303) | Sec 10f |
| `DO3` | Todos los demas polling loops | Reutilizable (secuenciales) |

`DO3` se reutiliza porque los polling loops son secuenciales y nunca se anidan entre si.

### Sintaxis Macro B del ADTECH
- **Operadores**: `+ - * / == != >= <= > <`
- **Control de flujo**: `WHILE[cond]DO#` / `END#`, `IF[cond]{...}`, `IF[cond]GOTO N`
- **Direccionamiento indirecto**: `##var = valor` (escribe en la direccion almacenada en `#var`)
- **Asignacion**: `#var = expresion`
- **Labels DO**: `DO1`-`DO3` disponibles para loops (no anidar el mismo label)

### Comandos M del controlador
- `M89 P## L#` = escribir salida digital (P=pin, L=nivel 0/1)
- `M88 P## L# Q####` = esperar entrada digital (P=pin, L=nivel esperado, Q=timeout ms)
- `#3000=N` = disparar alarma con numero N y mensaje entre parentesis
- `M3000` = fin de macro (return)

## Notas para Modificacion

- Los comentarios en espanol documentan las acciones mecanicas del ATC
- Los tiempos de retardo (`G04 P...`) estan en milisegundos y son criticos para la sincronizacion mecanica — modificar con precaucion
- La compensacion de longitud se almacena en `#[409+#200]` y se escribe al sistema de coordenadas G54 via `#5223`
- Al agregar nuevas alarmas, seguir las series existentes: 100=pre-vuelo, 200=liberacion, 300=insercion/final
- `M_FUNC.NC` contiene macros de fabrica — modificar solo si se entiende el sistema completo de I/O del ADTECH
