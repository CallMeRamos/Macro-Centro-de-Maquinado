# Tabla de Senales I/O - O0123 (ATC Macro)

## Controlador: ADTECH CNC4940

---

## Salidas digitales — M89

Comando: `M89 P## L#` donde P = pin, L = nivel (1=activar, 0=desactivar)

### P6 — Cono del husillo

| Nivel | Accion | Descripcion |
|-------|--------|-------------|
| L1 | Liberar cono | Abre el mecanismo de sujecion para soltar la herramienta |
| L0 | Cerrar cono | Cierra el mecanismo para sujetar la herramienta |

**Donde se usa:**
| Linea | Comando | Seccion | Contexto |
|-------|---------|---------|----------|
| 43 | `M89 P6 L0` | 2c | Reset — asegurar cono cerrado |
| 115 | `M89 P6 L1` | 6d | Liberar herramienta actual del husillo |
| 203 | `M89 P6 L0` | 10c | Cerrar cono sobre herramienta nueva |

---

### P8 — Rotacion magazin adelante

| Nivel | Accion | Descripcion |
|-------|--------|-------------|
| L1 | Rotar adelante | Gira el carrusel en sentido adelante |
| L0 | Detener | Detiene la rotacion adelante |

**Donde se usa:**
| Linea | Comando | Seccion | Contexto |
|-------|---------|---------|----------|
| 35 | `M89 P8 L0` | 2a | Reset — detener rotacion |
| 138 | `M89 P8 L1` | 7 | Iniciar rotacion adelante (ruta optima) |
| 149 | `M89 P8 L1` | 7 | Iniciar rotacion adelante (ruta alternativa) |
| 178 | `M89 P8 L0` | 9 | Detener rotacion al llegar a herramienta destino |

---

### P9 — Rotacion magazin atras

| Nivel | Accion | Descripcion |
|-------|--------|-------------|
| L1 | Rotar atras | Gira el carrusel en sentido inverso |
| L0 | Detener | Detiene la rotacion atras |

**Donde se usa:**
| Linea | Comando | Seccion | Contexto |
|-------|---------|---------|----------|
| 36 | `M89 P9 L0` | 2a | Reset — detener rotacion |
| 143 | `M89 P9 L1` | 7 | Iniciar rotacion atras (ruta optima) |
| 154 | `M89 P9 L1` | 7 | Iniciar rotacion atras (ruta alternativa) |
| 183 | `M89 P9 L0` | 9 | Detener rotacion al llegar a herramienta destino |

---

### P17 — Orientacion del husillo

| Nivel | Accion | Descripcion |
|-------|--------|-------------|
| L1 | Orientar | Posiciona el husillo en angulo fijo para acoplar herramienta |
| L0 | Cancelar | Libera la orientacion del husillo |

**Donde se usa:**
| Linea | Comando | Seccion | Contexto |
|-------|---------|---------|----------|
| 47 | `M89 P17 L0` | 2d | Reset — cancelar orientacion |
| 83 | `M89 P17 L1` | 5 | Orientar husillo antes de cambio |
| 235 | `M89 P17 L0` | 11 | Finalizacion — cancelar orientacion |

---

### P20 — Regreso ATC

| Nivel | Accion | Descripcion |
|-------|--------|-------------|
| L1 | Regresar ATC | Mueve el brazo ATC a su posicion de reposo |
| L0 | Cancelar | Cancela la senal de regreso |

**Donde se usa:**
| Linea | Comando | Seccion | Contexto |
|-------|---------|---------|----------|
| 39 | `M89 P20 L0` | 2b | Reset — cancelar regreso |
| 221 | `M89 P20 L1` | 10f | Regresar ATC despues de insertar herramienta |
| 232 | `M89 P20 L0` | 10f | Cancelar senal despues de confirmar regreso |

---

### P21 — Acercamiento ATC

| Nivel | Accion | Descripcion |
|-------|--------|-------------|
| L1 | Acercar ATC | Mueve el brazo ATC hacia el husillo |
| L0 | Cancelar | Cancela el acercamiento |

> **NOTA ADTECH:** La logica de esta senal esta **invertida** en el controlador ADTECH CNC4940.

**Donde se usa:**
| Linea | Comando | Seccion | Contexto |
|-------|---------|---------|----------|
| 40 | `M89 P21 L0` | 2b | Reset — cancelar acercamiento |
| 103 | `M89 P21 L1` | 6b | Acercar ATC para liberar herramienta |
| 188 | `M89 P21 L1` | 10a | Acercar ATC para insertar herramienta |
| 220 | `M89 P21 L0` | 10f | Cancelar acercamiento antes de regresar |

---

## Entradas digitales — M88 y #1000+N

Comando M88: `M88 P## L# Q####` donde P = pin, L = nivel esperado, Q = timeout (ms)
Variable macro: `#1000+N` donde N = numero de pin (lectura directa del estado)

### P20 — Sensor de orientacion del husillo

| Estado | Significado |
|--------|-------------|
| 0 (`L0`) | Husillo **no orientado** |
| 1 (`L1`) | Husillo **orientado** — en posicion angular fija para acople |

Variable macro: **`#1020`**

**Funcion dedicada:** Verificar que el husillo esta correctamente orientado para acoplar/desacoplar herramienta. NO se usa para verificar sujecion ni liberacion del cono.

**Donde se usa:**
| Linea | Metodo | Seccion | Verificacion |
|-------|--------|---------|-------------|
| 86 | `#1020 != 1` (polling) | 5b | Alarma 106: orientacion husillo no confirmada (5s) |
| 90 | `#1020 != 1` (check) | 5b | Disparo de alarma 106 |

---

### P21 — Sensor de liberacion del cono

| Estado | Significado |
|--------|-------------|
| 0 (`L0`) | Cono **no liberado** |
| 1 (`L1`) | Cono **liberado** — herramienta puede salir |

Variable macro: **`#1021`**

**Funcion dedicada:** Verificar que el cono se **libero** correctamente. NO se usa para verificar sujecion/cierre.

**Donde se usa:**
| Linea | Metodo | Seccion | Verificacion |
|-------|--------|---------|-------------|
| 119 | `#1021 != 1` (polling) | 6e | Alarma 202: cono no se libero (1.5s) |
| 123 | `#1021 != 1` (check) | 6e | Disparo de alarma 202 |

---

### P22 — Sensor de sujecion del cono

| Estado | Significado |
|--------|-------------|
| 0 (`L0`) | Cono **no sujetado** — herramienta no esta agarrada |
| 1 (`L1`) | Cono **sujetado** — herramienta correctamente agarrada |

Variable macro: **`#1022`**

**Funcion dedicada:** Verificar que la herramienta esta correctamente **sujeta** (cono cerrado). NO se usa para verificar liberacion.

**Donde se usa:**
| Linea | Metodo | Seccion | Verificacion |
|-------|--------|---------|-------------|
| 28 | `#1022 != 1` (check) | 1b | Alarma 101: cono no sujetado al inicio |
| 51 | `#1022 != 1` (polling) | 2e | Alarma 105: cono no sujetado post-reset (3s) |
| 55 | `#1022 != 1` (check) | 2e | Disparo de alarma 105 |
| 211 | `#1022 != 1` (polling) | 10e | Alarma 301: cono no sujetado post-insercion (3s) |
| 215 | `#1022 != 1` (check) | 10e | Disparo de alarma 301 |
| 240 | `#1022 != 1` (check) | 11b | Alarma 305: cono no sujetado al finalizar |

---

### P23 — Sensor conteo de herramientas

| Estado | Significado |
|--------|-------------|
| Pulso H/L | Cada transicion completa (bajo→alto) = 1 posicion del magazin |

Variable macro: `#1023` (no usada directamente, se lee via M88)

**Donde se usa:**
| Linea | Metodo | Seccion | Verificacion |
|-------|--------|---------|-------------|
| 161 | `M88 P23 L0 Q5000` | 8 | Espera pulso bajo dentro del loop de conteo |
| 162 | `M88 P23 L1 Q5000` | 8 | Espera pulso alto dentro del loop de conteo |

> **Nota:** Estos M88 permanecen con timeout generico (5s) porque estan dentro de `DO1` y reemplazarlos requeriria anidar WHILEs.

---

### P25 — Sensor regreso ATC

| Estado | Significado |
|--------|-------------|
| 0 (`L0`) | ATC **en posicion de reposo** |
| != 0 | ATC **fuera de reposo** |

Variable macro: **`#1025`**

**Donde se usa:**
| Linea | Metodo | Seccion | Verificacion |
|-------|--------|---------|-------------|
| 224 | `#1025 != 0` (polling) | 10f | Alarma 303: ATC no regreso (5s) |
| 228 | `#1025 != 0` (check) | 10f | Disparo de alarma 303 |

---

### P26 — Sensor posicion de trabajo ATC

| Estado | Significado |
|--------|-------------|
| 0 (`L0`) | ATC **en posicion de trabajo** (junto al husillo) |
| != 0 | ATC **no en posicion** |

Variable macro: **`#1026`**

**Donde se usa:**
| Linea | Metodo | Seccion | Verificacion |
|-------|--------|---------|-------------|
| 105 | `#1026 != 0` (polling) | 6b | Alarma 203: ATC no llego para liberacion (5s) |
| 109 | `#1026 != 0` (check) | 6b | Disparo de alarma 203 |
| 190 | `#1026 != 0` (polling) | 10a | Alarma 304: ATC no llego para insercion (5s) |
| 194 | `#1026 != 0` (check) | 10a | Disparo de alarma 304 |

---

## Resumen de pines

```
SALIDAS (M89)              ENTRADAS (M88 / #1000+N)
=============              ========================
P6  → Cono (abrir/cerrar)  P20 → Sensor orientacion husillo
P8  → Magazin adelante     P21 → Sensor liberacion cono
P9  → Magazin atras        P22 → Sensor sujecion cono
P17 → Orientar husillo     P23 → Sensor conteo herramientas
P20 → Regresar ATC         P25 → Sensor regreso ATC
P21 → Acercar ATC          P26 → Sensor posicion ATC
```

> **IMPORTANTE:** P20 y P21 se usan tanto como salidas (M89) como entradas (M88/#1000+N) con funciones completamente diferentes. Como salida, P20 controla el regreso del ATC; como entrada, P20 lee el sensor de orientacion del husillo.

## Nota sobre lectura de I/O en ADTECH CNC4940

- `#1000+N` (lectura de entradas): **FUNCIONA** — usar para todas las verificaciones con `#3000`
- `#1100+N` (lectura de salidas): **NO FUNCIONA** — no refleja el estado real, nunca usar
