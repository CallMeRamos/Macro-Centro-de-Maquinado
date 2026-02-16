# Guia Completa de Entradas, Salidas y Variables — ADTECH CNC4940

## Controlador: ADTECH CNC4940 | Archivos: T_FUNC.NC (O0123) + M_FUNC.NC

---

## 1. Salidas Digitales (M89)

Comando: `M89 P## L#` — P = pin, L = nivel (1=activar, 0=desactivar)

### 1.1 Salidas del ATC (usadas en T_FUNC.NC)

| Pin | L1 (activar) | L0 (desactivar) | Notas |
|-----|--------------|-----------------|-------|
| P6 | Liberar cono (abrir mecanismo) | Cerrar cono (sujetar herramienta) | Control del drawbar |
| P8 | Rotacion magazin adelante | Detener rotacion adelante | Carrusel CW |
| P9 | Rotacion magazin atras | Detener rotacion atras | Carrusel CCW |
| P17 | Orientar husillo | Cancelar orientacion | Posicion angular fija |
| P20 | Regresar ATC a reposo | Cancelar regreso | Brazo ATC retrae |
| P21 | Acercar ATC al husillo | Cancelar acercamiento | **LOGICA INVERTIDA en ADTECH** |

#### Donde se usa cada salida en T_FUNC.NC (O0123):

**P6 — Cono del husillo:**
| Linea | Comando | Seccion | Contexto |
|-------|---------|---------|----------|
| 45 | `M89 P6 L0` | 2c | Reset — asegurar cono cerrado |
| 123 | `M89 P6 L1` | 6d | Liberar herramienta actual |
| 213 | `M89 P6 L0` | 10c | Cerrar cono sobre herramienta nueva |

**P8 — Rotacion adelante:**
| Linea | Comando | Seccion | Contexto |
|-------|---------|---------|----------|
| 37 | `M89 P8 L0` | 2a | Reset — detener rotacion |
| 147 | `M89 P8 L1` | 7 | Iniciar rotacion (ruta optima) |
| 158 | `M89 P8 L1` | 7 | Iniciar rotacion (ruta alternativa) |
| 187 | `M89 P8 L0` | 9 | Detener al llegar a destino |

**P9 — Rotacion atras:**
| Linea | Comando | Seccion | Contexto |
|-------|---------|---------|----------|
| 38 | `M89 P9 L0` | 2a | Reset — detener rotacion |
| 152 | `M89 P9 L1` | 7 | Iniciar rotacion (ruta optima) |
| 163 | `M89 P9 L1` | 7 | Iniciar rotacion (ruta alternativa) |
| 192 | `M89 P9 L0` | 9 | Detener al llegar a destino |

**P17 — Orientacion husillo:**
| Linea | Comando | Seccion | Contexto |
|-------|---------|---------|----------|
| 49 | `M89 P17 L0` | 2d | Reset — cancelar orientacion |
| 89 | `M89 P17 L1` | 5 | Orientar antes de cambio |
| 247 | `M89 P17 L0` | 11 | Finalizacion — cancelar |

**P20 — Regreso ATC:**
| Linea | Comando | Seccion | Contexto |
|-------|---------|---------|----------|
| 41 | `M89 P20 L0` | 2b | Reset — cancelar regreso |
| 232 | `M89 P20 L1` | 10f | Regresar ATC post-insercion |
| 244 | `M89 P20 L0` | 10f | Cancelar despues de confirmar |

**P21 — Acercamiento ATC:**
| Linea | Comando | Seccion | Contexto |
|-------|---------|---------|----------|
| 42 | `M89 P21 L0` | 2b | Reset — cancelar acercamiento |
| 110 | `M89 P21 L1` | 6b | Acercar para liberar herramienta |
| 197 | `M89 P21 L1` | 10a | Acercar para insertar herramienta |
| 231 | `M89 P21 L0` | 10f | Cancelar antes de regresar |

### 1.2 Salidas del sistema (usadas en M_FUNC.NC)

Patron: `#2=1400+N` / `##2=1` o `##2=0` — direccionamiento indirecto

| M Code ON | M Code OFF | Salida | LED | Funcion | Guardas |
|-----------|------------|--------|-----|---------|---------|
| M08 | M09 | OUT(#10044) | — | Refrigerante | Pin dinamico via parametro |
| M10 | M11 | OUT02 | #1849 | Sistema | — |
| M12 | M13 | OUT03 | #1852 | Sistema | — |
| M14 | M15 | OUT06 | #1854 | Sistema | `#3918 != 0` (husillo parado) |
| M16 | M17 | OUT07 | #1855 | Sistema | — |
| M18 | M19 | OUT08 | #1856 | Sistema | `#3918 != 0` |
| M20 | M21 | OUT09 | #1857 | Sistema | `#3918 != 0` |
| M22 | M23 | OUT10 | #1860 | Sistema | — |
| M24 | M25 | OUT11 | #1862 | Sistema | — |
| M26 | M27 | OUT12 | #1883 | FCNC6D | — |
| M32 | M33 | OUT(#10043) | — | Lubricante | Pin dinamico via parametro |
| M128 | M129 | OUT13 | #1884 | FCNC6D Refrigerante 2 | — |
| M130 | M131 | OUT14 | #1885 | FCNC6D Contactor | — |
| M198 | M199 | OUT46 | — | Usuario | — |
| M100 | M101 | OUT47 | — | Usuario | — |

> **Nota:** OUT04 y OUT05 no tienen M codes asignados.

### 1.3 Salidas de usuario (sin LEDs)

| M Code ON | M Code OFF | Salida |  | M Code ON | M Code OFF | Salida |
|-----------|------------|--------|--|-----------|------------|--------|
| M68 | M69 | OUT32 |  | M80 | M81 | OUT38 |
| M70 | M71 | OUT33 |  | M82 | M83 | OUT39 |
| M72 | M73 | OUT34 |  | M84 | M85 | OUT40 |
| M74 | M75 | OUT35 |  | M86 | M87 | OUT41 |
| M76 | M77 | OUT36 |  | M90 | M91 | OUT42 |
| M78 | M79 | OUT37 |  | M92 | M93 | OUT43 |
|  |  |  |  | M94 | M95 | OUT44 |
|  |  |  |  | M96 | M97 | OUT45 |

> **M88/M89** no aparecen — son comandos nativos I/O del ADTECH.
> **M98/M99** no aparecen — son subprogram call/return del sistema.

---

## 2. Entradas Digitales (M88 y #1000+N)

Comando M88: `M88 P## L# Q####` — P = pin, L = nivel esperado, Q = timeout (ms)
Variable macro: `#1000+N` — lectura directa del estado del pin N

> **CRITICO:** `#1100+N` (lectura de salidas) **NO FUNCIONA** en ADTECH — nunca usar.

### 2.1 Sensores del ATC

| Pin | Variable | Sensor | L0 | L1 | Funcion dedicada |
|-----|----------|--------|----|----|------------------|
| P20 | `#1020` | Orientacion husillo | No orientado | **Orientado** | Solo verificar orientacion |
| P21 | `#1021` | Liberacion cono | No liberado | **Liberado** | Solo verificar liberacion |
| P22 | `#1022` | Sujecion cono | No sujetado | **Sujetado** | Solo verificar sujecion |
| P23 | `#1023` | Conteo herramientas | Pulso bajo | Pulso alto | Conteo posiciones magazin |
| P25 | `#1025` | Regreso ATC | **En reposo** | Fuera de reposo | Confirmar ATC regreso |
| P26 | `#1026` | Posicion trabajo ATC | **En posicion** | Fuera de posicion | Confirmar ATC llego |

> **IMPORTANTE:** P20 y P21 se usan como salida (M89) Y como entrada (#1000+N) con funciones **completamente diferentes**.
> - P20 como salida = regresar ATC | P20 como entrada = sensor orientacion husillo
> - P21 como salida = acercar ATC | P21 como entrada = sensor liberacion cono

> **REGLA ESTRICTA:** Nunca usar P21 para verificar sujecion. Nunca usar P22 para verificar liberacion. Nunca usar P20 para otra cosa que orientacion.

### 2.2 Donde se usa cada sensor en T_FUNC.NC (O0123):

**P20 — Sensor orientacion husillo (`#1020`):**
| Linea | Metodo | Seccion | Verificacion |
|-------|--------|---------|--------------|
| 92 | `#1020 != 1` polling WHILE | 5b | Espera orientacion (5s timeout) |
| 96 | `#1020 != 1` check IF | 5b | Dispara alarma 106 |

**P21 — Sensor liberacion cono (`#1021`):**
| Linea | Metodo | Seccion | Verificacion |
|-------|--------|---------|--------------|
| 127 | `#1021 != 1` polling WHILE | 6e | Espera liberacion (1.5s timeout) |
| 131 | `#1021 != 1` check IF | 6e | Dispara alarma 202 |

**P22 — Sensor sujecion cono (`#1022`):**
| Linea | Metodo | Seccion | Verificacion |
|-------|--------|---------|--------------|
| 29 | `#1022 != 1` check IF | 1b | Alarma 101: pre-vuelo |
| 53 | `#1022 != 1` polling WHILE | 2e | Espera sujecion post-reset (3s) |
| 57 | `#1022 != 1` check IF | 2e | Dispara alarma 105 |
| 221 | `#1022 != 1` polling WHILE | 10e | Espera sujecion post-insercion (3s) |
| 225 | `#1022 != 1` check IF | 10e | Dispara alarma 301 |
| 252 | `#1022 != 1` check IF | 11b | Alarma 305: verificacion final |

**P23 — Sensor conteo herramientas (via M88):**
| Linea | Metodo | Seccion | Verificacion |
|-------|--------|---------|--------------|
| 170 | `M88 P23 L0 Q5000` | 8 | Espera pulso bajo (5s timeout) |
| 171 | `M88 P23 L1 Q5000` | 8 | Espera pulso alto (5s timeout) |

**P25 — Sensor regreso ATC (`#1025`):**
| Linea | Metodo | Seccion | Verificacion |
|-------|--------|---------|--------------|
| 235 | `#1025 != 0` polling WHILE | 10f | Espera regreso (5s timeout) |
| 239 | `#1025 != 0` check IF | 10f | Dispara alarma 303 |

**P26 — Sensor posicion trabajo ATC (`#1026`):**
| Linea | Metodo | Seccion | Verificacion |
|-------|--------|---------|--------------|
| 112 | `#1026 != 0` polling WHILE | 6b | Espera posicion para liberacion (5s) |
| 116 | `#1026 != 0` check IF | 6b | Dispara alarma 203 |
| 199 | `#1026 != 0` polling WHILE | 10a | Espera posicion para insercion (5s) |
| 203 | `#1026 != 0` check IF | 10a | Dispara alarma 304 |

---

## 3. LEDs del Panel

Direcciones de memoria: `#1800+N` — escritura directa (1=encendido, 0=apagado)

### 3.1 LEDs del sistema (controlados por M_FUNC.NC)

| LED | Direccion | Controlado por | Funcion |
|-----|-----------|----------------|---------|
| `#1810` | 1810 | O208/O209 | Refrigerante |
| `#1811` | 1811 | O212/O213 | Lubricante |
| `#1843` | 1843 | M40/M41 (F0) | Selector pagina (blink=pag1, ON=pag2) |
| `#1848` | 1848 | M42 (F1) + O0123 | Herramienta T1 |
| `#1849` | 1849 | M10/M11 | OUT02 |
| `#1852` | 1852 | M12/M13 | OUT03 |
| `#1853` | 1853 | M44 (F2) + O0123 | Herramienta T2 / T12 |
| `#1854` | 1854 | M14/M15 | OUT06 |
| `#1855` | 1855 | M16/M17 | OUT07 |
| `#1856` | 1856 | M18/M19 | OUT08 |
| `#1857` | 1857 | M20/M21 | OUT09 |
| `#1858` | 1858 | M46 (F3) + O0123 | Herramienta T3 / T13 |
| `#1859` | 1859 | O212/O213 | Lubricante auxiliar |
| `#1860` | 1860 | M22/M23 | OUT10 |
| `#1861` | 1861 | O208/O209 | Refrigerante auxiliar |
| `#1862` | 1862 | M24/M25 | OUT11 |
| `#1863` | 1863 | M48 (F4) + O0123 | Herramienta T4 / T14 |
| `#1874` | 1874 | M50 (F5) + O0123 | Herramienta T5 / T15 |
| `#1883` | 1883 | M26/M27 | OUT12 |
| `#1884` | 1884 | M128/M129 | OUT13 FCNC6D Refrigerante 2 |
| `#1885` | 1885 | M130/M131 | OUT14 FCNC6D Contactor |
| `#1886` | 1886 | M34/M35 | OUT15 FCNC6D |
| `#1887` | 1887 | M36/M37 | OUT16 FCNC6D |
| `#1889` | 1889 | M38/M39 | OUT17 Orient. husillo |
| `#1890` | 1890 | M52 (F6) + O0123 | Herramienta T6 / T16 |
| `#1891` | 1891 | M54 (F7) + O0123 | Herramienta T7 / T17 |
| `#1892` | 1892 | M56 (F8) + O0123 | Herramienta T8 / T18 |
| `#1893` | 1893 | M58 (F9) + O0123 | Herramienta T9 / T19 |
| `#1894` | 1894 | M60 (F10) + O0123 | Herramienta T10 / T20 |
| `#1895` | 1895 | M62 (F11) + O0123 | Herramienta T11 / T21 |
| `#1896` | 1896 | M64/M65 | OUT20 FCNC6D F12 |
| `#1897` | 1897 | M66/M67 | OUT21 FCNC6D F13 |

### 3.2 LEDs de herramientas F1-F11 — Comportamiento radio button

Los LEDs de F1-F11 tienen comportamiento **radio button**: solo uno encendido a la vez, indicando la herramienta activa.

**Mapeo herramienta → LED:**

| Tecla | LED | Pagina 1 | Pagina 2 |
|-------|-----|----------|----------|
| F1 | `#1848` | T1 | T11 |
| F2 | `#1853` | T2 | T12 |
| F3 | `#1858` | T3 | T13 |
| F4 | `#1863` | T4 | T14 |
| F5 | `#1874` | T5 | T15 |
| F6 | `#1890` | T6 | T16 |
| F7 | `#1891` | T7 | T17 |
| F8 | `#1892` | T8 | T18 |
| F9 | `#1893` | T9 | T19 |
| F10 | `#1894` | T10 | T20 |
| F11 | `#1895` | — | T21 |

> **Nota:** Los LEDs NO son secuenciales (#1848, #1853, #1858, #1863, #1874, luego salta a #1890-#1895).

**Mecanismo (variable `#151`):**
- `#151` almacena la **direccion** del LED actualmente encendido
- Al presionar otra tecla F o al completar un cambio de herramienta (O0123), se apaga el LED anterior via `##151=0` (direccionamiento indirecto) y se enciende el nuevo
- Las macros OFF (M43, M45...M63) son **no-op** — el LED persiste hasta que otra accion lo apague
- O0123 seccion 11c actualiza el LED al completar un cambio exitoso, funcionando en **modo AUTO y MPG**

**Bloqueo durante cambio (`#152`):**
- `#152=1` se activa al inicio de O0123, inhabilitando las teclas F1-F11
- `#152=0` se desactiva al final de O0123 o antes de cada alarma
- Previene conflictos mecanicos si el operador presiona otra tecla durante un cambio

---

## 4. Variables Macro

### 4.1 Variables volatiles (#100-#199) — Se pierden al apagar

| Variable | Funcion | Valores | Usado en |
|----------|---------|---------|----------|
| `#150` | Selector de pagina (F0) | 1=pagina 1, 2=pagina 2 | M40/M41, F1-F11 ON macros |
| `#151` | Direccion LED activo (radio button) | 0=ninguno, 1848-1895=direccion LED | F1-F11 ON macros, O0123 sec 11c |
| `#152` | Candado cambio de herramienta | 0=libre, 1=bloqueado | O0123, F1-F11 ON macros |

### 4.2 Variables de usuario (#200-#499) — Usadas en O0123

| Variable | Funcion | Asignacion |
|----------|---------|------------|
| `#200` | Herramienta solicitada | Entrada del comando T |
| `#201` | Herramienta actual | `#201=#4120` (lee del sistema) |
| `#400` | Max herramientas en magazin | 21 |
| `#401` | Altura segura eje Z | Configurado por usuario |
| `#402` | Posicion Z retraccion completa | Configurado por usuario |
| `#403` | Posicion Z 2.5mm arriba del ref | Configurado por usuario |
| `#404` | Punto de referencia eje Z | Configurado por usuario |
| `#405` | Velocidad avance F (movimientos Z) | Configurado por usuario |
| `#408` | Retardo detener rotacion adelante (ms) | Configurado por usuario |
| `#409` | Retardo detener rotacion atras (ms) | Configurado por usuario |
| `#410`-`#430` | Compensacion longitud T1-T21 | `#[409+N]` para herramienta N |

### 4.3 Variables temporales en O0123

| Variable | Uso | Seccion |
|----------|-----|---------|
| `#1` | Direccion rotacion (0=adelante, 1=atras) | 7-9 |
| `#2` | Contador posicion temporal | 8 |
| `#3` | Contador polling / lookup herramienta | 2e, 5b, 6b, 6e, 10a, 10e, 10f, 11c |

### 4.4 Variables del sistema (solo lectura)

| Variable | Funcion | Valores |
|----------|---------|---------|
| `#3906` | Modo actual del controlador | 0=EDIT, 1=AUTO, 2=MANUAL, 3=STEP/MPG, 4=HOME |
| `#3918` | Estado del husillo | 0=parado, 1=adelante (M03), 2=reversa (M04) |
| `#3932` | Estado de ejecucion | 0=stop, 1=running, 3=SBK pause |
| `#4118` | Velocidad del husillo (RPM) | Valor numerico |
| `#4120` | Herramienta T actual | 0-21 |
| `#5223` | Offset Z del sistema G54 | Compensacion de longitud |

### 4.5 Variables de parametros del controlador

| Variable | Funcion |
|----------|---------|
| `#10043` | Numero de pin para lubricante |
| `#10044` | Numero de pin para refrigerante |

---

## 5. Alarmas (T_FUNC.NC)

Comando: `#3000=N (MENSAJE)` — detiene ejecucion con alarma

### 5.1 Alarmas activas — 12 total

| Alarma | Seccion | Sensor | Condicion | Timeout | Descripcion |
|--------|---------|--------|-----------|---------|-------------|
| 1 | 4 | — | `#400 > 21` | — | Herramienta excede maximo del magazin |
| 1 | 4 | — | `#200 > #400` o `#201 > #400` | — | Herramienta fuera de rango |
| 1 | 4 | — | `#201 == 0` | — | Herramienta actual es cero |
| 101 | 1b | P22 | `#1022 != 1` | — | Cono no sujetado al inicio |
| 105 | 2e | P22 | `#1022 != 1` | 3s | Cono no sujetado post-reset |
| 106 | 5b | P20 | `#1020 != 1` | 5s | Orientacion husillo no confirmada |
| 202 | 6e | P21 | `#1021 != 1` | 1.5s | Cono no se libero |
| 203 | 6b | P26 | `#1026 != 0` | 5s | ATC no llego para liberacion |
| 301 | 10e | P22 | `#1022 != 1` | 3s | Cono no sujetado post-insercion |
| 303 | 10f | P25 | `#1025 != 0` | 5s | ATC no regreso a posicion |
| 304 | 10a | P26 | `#1026 != 0` | 5s | ATC no llego para insercion |
| 305 | 11b | P22 | `#1022 != 1` | — | Cono no sujetado al finalizar |

> Todas las alarmas ejecutan `#152=0` antes de `#3000` para desbloquear las teclas F.

### 5.2 Series de alarmas

| Serie | Rango | Fase |
|-------|-------|------|
| 1 | General | Validaciones de rango |
| 100 | 101-106 | Pre-vuelo y preparacion |
| 200 | 202-203 | Liberacion de herramienta |
| 300 | 301-305 | Insercion y finalizacion |

---

## 6. Control de Husillo (M_FUNC.NC)

| Programa | Funcion | Logica |
|----------|---------|--------|
| O203 | Husillo adelante | Si `#3918==0` → `M03 S#4118`; si `#3918==2` → sale; si no → `M05` |
| O204 | Husillo reversa | Si `#3918==0` → `M04 S#4118`; si `#3918==1` → sale; si no → `M05` |
| O205 | Parar husillo | Ejecuta `M05` directamente |

> Solo funcionan en modo MPG (`#3906 == 3`). O203 y O204 leen la velocidad de `#4118`.

---

## 7. Refrigerante y Lubricante con LEDs (M_FUNC.NC)

| Programa | Funcion | Pin de salida | LEDs |
|----------|---------|---------------|------|
| O208 | Refrigerante ON | `#1400+#10044` | `#1810=1`, `#1861=1` |
| O209 | Refrigerante OFF | `#1400+#10044` | `#1810=0`, `#1861=0` |
| O212 | Lubricante ON | `#1400+#10043` | `#1811=1`, `#1859=1` |
| O213 | Lubricante OFF | `#1400+#10043` | `#1811=0`, `#1859=0` |

---

## 8. Seleccion de Herramientas F0-F11 (M_FUNC.NC)

### 8.1 F0 — Selector de pagina (M40/M41)

- Toggle entre pagina 1 y pagina 2 via `#150`
- Pagina 1: LED blink 1 vez → queda OFF
- Pagina 2: LED blink 2 veces → queda ON
- Solo funciona en modo MPG (`#3906 == 3`)

### 8.2 F1-F11 — Seleccion de herramienta (M42-M63)

**Flujo de la macro ON (ejemplo M42 — F1):**
```
1. IF[#3906 != 3] → sale (solo modo MPG)
2. IF[#152 == 1]  → sale (cambio en progreso, BLOQUEADO)
3. IF[#151 > 0]   → ##151=0 (apaga LED anterior)
4. #1848=1         (enciende LED F1)
5. #151=1848       (guarda direccion LED activo)
6. IF[#150 != 2]  → T1 (pagina 1)
   ELSE           → ninguna (F1 no tiene pagina 2)
7. M3000           (fin)
```

**Macro OFF (ejemplo M43 — F1 OFF):**
```
1. M3000 (no-op — LED persiste)
```

### 8.3 Tabla completa F1-F11

| Tecla | ON | OFF | LED | #151= | Pag 1 | Pag 2 |
|-------|-----|-----|-----|-------|-------|-------|
| F1 | M42 (O0042) | M43 (O0043) | #1848 | 1848 | T1 | T11 |
| F2 | M44 (O0044) | M45 (O0045) | #1853 | 1853 | T2 | T12 |
| F3 | M46 (O0046) | M47 (O0047) | #1858 | 1858 | T3 | T13 |
| F4 | M48 (O0048) | M49 (O0049) | #1863 | 1863 | T4 | T14 |
| F5 | M50 (O0050) | M51 (O0051) | #1874 | 1874 | T5 | T15 |
| F6 | M52 (O0052) | M53 (O0053) | #1890 | 1890 | T6 | T16 |
| F7 | M54 (O0054) | M55 (O0055) | #1891 | 1891 | T7 | T17 |
| F8 | M56 (O0056) | M57 (O0057) | #1892 | 1892 | T8 | T18 |
| F9 | M58 (O0058) | M59 (O0059) | #1893 | 1893 | T9 | T19 |
| F10 | M60 (O0060) | M61 (O0061) | #1894 | 1894 | T10 | T20 |
| F11 | M62 (O0062) | M63 (O0063) | #1895 | 1895 | — | T21 |

### 8.4 F12-F13 — FCNC6D (sin radio button)

| Tecla | ON | OFF | Salida | LED | Guardas |
|-------|-----|-----|--------|-----|---------|
| F12 | M64 (O0064) | M65 (O0065) | OUT20 | #1896 | `#3906 != 3`, `#3918 != 0` |
| F13 | M66 (O0066) | M67 (O0067) | OUT21 | #1897 | `#3906 != 3`, `#3918 != 0` |

### 8.5 FCNC6D adicionales (sin tecla F)

| ON | OFF | Salida | LED | Funcion |
|-----|-----|--------|-----|---------|
| M34 (O0034) | M35 (O0035) | OUT15 | #1886 | FCNC6D |
| M36 (O0036) | M37 (O0037) | OUT16 | #1887 | FCNC6D |
| M38 (O0038) | M39 (O0039) | OUT17 | #1889 | Orientacion husillo (guardas: `#3906!=3`, `#1854==1`) |

---

## 9. Indicador LED de Herramienta en Modo AUTO

O0123 seccion 11c actualiza automaticamente el LED de herramienta al completar cada cambio exitoso. Esto funciona en **todos los modos** (AUTO, MPG, STEP).

**Logica (T_FUNC.NC lineas 258-276):**
```
1. IF[#151 > 0] → ##151=0     (apaga LED anterior)
2. #3=#200                     (herramienta nueva)
3. IF[#3 > 11] #3=#3-10       (T12-T21 → mapea a T2-T11)
4. IF[#3 == N] #151=XXXX      (lookup de 11 direcciones LED)
5. ##151=1                     (enciende LED nuevo)
```

**Ejemplo en modo AUTO:**
```
Programa NC ejecuta:
  T1  → LED F1 ON
  T5  → LED F1 OFF, LED F5 ON
  T13 → LED F5 OFF, LED F3 ON (13-10=3)
  T8  → LED F3 OFF, LED F8 ON
  M30 → ultimo LED queda encendido (T8 = F8)
```

---

## 10. Labels DO en uso (T_FUNC.NC)

| Label | Uso | Seccion | Notas |
|-------|-----|---------|-------|
| `DO1` | Conteo de posiciones del magazin | 8 | Loop principal WHILE |
| `DO2` | Polling regreso ATC | 10f | Alarma 303 |
| `DO3` | Todos los demas polling loops | Varias | Reutilizable (secuenciales) |

> `DO3` se reutiliza porque los polling loops son secuenciales y nunca se anidan entre si.

---

## 11. Patron de Polling con Timeout

Patron estandar usado en todas las verificaciones con sensor:

```
#3=0
WHILE[[#10XX != VAL] && [#3 < N]] DO3
    G04 P100
    #3=#3+1
END3
IF[#10XX != VAL]
{
    #152=0
    #3000=ALARM_NUM (MENSAJE DE ALARMA)
}
```

- Cada iteracion = 100ms (`G04 P100`)
- Timeout total = N x 100ms (ejemplo: `#3 < 30` = 3 segundos)
- Siempre desbloquea `#152=0` antes de disparar alarma

---

## 12. Resumen Visual de Pines

```
SALIDAS (M89)                    ENTRADAS (M88 / #1000+N)
===========================      ================================
P6  → Cono (abrir/cerrar)       P20 → Sensor orientacion husillo
P8  → Magazin adelante          P21 → Sensor liberacion cono
P9  → Magazin atras             P22 → Sensor sujecion cono
P17 → Orientar husillo          P23 → Sensor conteo herramientas
P20 → Regresar ATC              P25 → Sensor regreso ATC
P21 → Acercar ATC (INVERTIDO)   P26 → Sensor posicion ATC

SALIDAS M_FUNC (via #1400+N)    LEDS (via #1800+N)
===========================      ================================
OUT02-OUT12 → Sistema+LEDs      #1810-#1897 → Panel del operador
OUT13-OUT14 → FCNC6D+LEDs       #1843 → F0 selector pagina
OUT15-OUT17 → FCNC6D+LEDs       #1848-#1895 → F1-F11 herramientas
OUT20-OUT21 → FCNC6D+LEDs       #1896-#1897 → F12-F13 FCNC6D
OUT32-OUT47 → Usuario (sin LEDs)

VARIABLES VOLATILES              VARIABLES SISTEMA
===========================      ================================
#150 → Pagina (1 o 2)           #3906 → Modo controlador
#151 → LED activo (direccion)   #3918 → Estado husillo
#152 → Candado cambio T         #4120 → Herramienta actual
```
