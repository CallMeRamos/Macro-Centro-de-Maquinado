# Tabla de Alarmas - O0123 (ATC Macro)

## Controlador: ADTECH CNC4940

---

## Sensores de cono y husillo — Funciones dedicadas

| Sensor | Variable | Funcion dedicada | Estado activo |
|--------|----------|------------------|---------------|
| P20 | `#1020` | **Orientacion husillo** | L1 = husillo orientado |
| P21 | `#1021` | **Liberacion cono** | L1 = cono liberado |
| P22 | `#1022` | **Sujecion cono** | L1 = cono sujetado |

**Regla critica:** Nunca usar P21 para verificar sujecion ni P22 para verificar liberacion. P20 solo confirma orientacion del husillo.

---

## Serie 100 — Verificacion pre-vuelo y post-reset (Secciones 1b y 2e) y orientacion (Seccion 5b)

Estas alarmas se disparan **antes** de iniciar el cambio de herramienta. Detectan condiciones anormales o fallos en la preparacion.

| Alarma | Sensor | Variable | Condicion | Timeout | Linea | Mensaje en pantalla | Accion del operador |
|--------|--------|----------|-----------|---------|-------|---------------------|---------------------|
| 101 | P22 (sujecion) | `#1022` | `#1022 != 1` | — | 28-31 | CONO NO SUJETADO AL INICIO - VERIFIQUE P22 Y REINTENTE T | Verificar mecanismo de sujecion, reintentar T |
| 105 | P22 (sujecion) | `#1022` | `#1022 != 1` | 3s | 50-58 | CONO NO SUJETADO DESPUES DE RESET P22 - VERIFIQUE MECANISMO | Verificar mecanismo de cierre del cono |
| 106 | P20 (orientacion) | `#1020` | `#1020 != 1` | 5s | 85-93 | ORIENTACION HUSILLO NO CONFIRMADA P20 - VERIFIQUE SENSOR Y REINTENTE T | Verificar sensor P20 y mecanismo de orientacion |

**Nota:** Alarma 101 es verificacion instantanea (sin timeout). Alarmas 105 y 106 usan polling con timeout porque los mecanismos necesitan tiempo para estabilizarse.

---

## Serie 200 — Liberacion de herramienta (Seccion 6)

Estas alarmas ocurren durante la **liberacion** de la herramienta actual del husillo.

| Alarma | Sensor | Variable | Condicion | Timeout | Linea | Mensaje en pantalla | Accion del operador |
|--------|--------|----------|-----------|---------|-------|---------------------|---------------------|
| 203 | P26 (ATC pos) | `#1026` | `#1026 != 0` | 5s | 104-112 | ATC NO LLEGO A POSICION PARA LIBERACION - VERIFIQUE MECANISMO | Verificar movimiento del brazo ATC |
| 202 | P21 (liberacion) | `#1021` | `#1021 != 1` | 1.5s | 118-126 | CONO NO SE LIBERO P21 - VERIFIQUE MECANISMO Y REINTENTE T | Verificar mecanismo de liberacion del cono |

**Secuencia normal de Seccion 6:**
1. ATC se acerca al husillo (alarma **203** si no llega en 5s)
2. Se libera cono con `M89 P6 L1`
3. Se verifica P21 = cono liberado (alarma **202** si no se libero en 1.5s)

---

## Serie 300 — Insercion de herramienta y finalizacion (Secciones 10-11)

Estas alarmas ocurren durante la **insercion** de la herramienta nueva y la verificacion final.

| Alarma | Sensor | Variable | Condicion | Timeout | Linea | Mensaje en pantalla | Accion del operador |
|--------|--------|----------|-----------|---------|-------|---------------------|---------------------|
| 304 | P26 (ATC pos) | `#1026` | `#1026 != 0` | 5s | 189-197 | ATC NO LLEGO A POSICION PARA INSERCION - VERIFIQUE MECANISMO | Verificar movimiento del brazo ATC |
| 301 | P22 (sujecion) | `#1022` | `#1022 != 1` | 3s | 210-218 | CONO NO SUJETADO DESPUES DE INSERCION P22 - VERIFIQUE Y REINTENTE T | Verificar cierre del cono sobre herramienta nueva |
| 303 | P25 (ATC rep) | `#1025` | `#1025 != 0` | 5s | 223-231 | ATC NO REGRESO A POSICION - VERIFIQUE MECANISMO Y REINTENTE T | Verificar regreso del brazo ATC |
| 305 | P22 (sujecion) | `#1022` | `#1022 != 1` | — | 240-243 | CONO NO SUJETADO AL FINALIZAR P22 - VERIFIQUE ANTES DE ARRANCAR HUSILLO | Verificar sujecion antes de arrancar husillo |

**Secuencia normal de Secciones 10-11:**
1. ATC se acerca al husillo (alarma **304** si no llega en 5s)
2. Z baja, cono cierra con `M89 P6 L0`
3. Se verifica P22 = cono sujetado (alarma **301** si no sujeto en 3s)
4. ATC regresa a reposo (alarma **303** si no regresa en 5s)
5. Verificacion final P22 = cono sujetado (alarma **305** si no esta sujetado)

---

## Alarmas eliminadas

Las siguientes alarmas existieron en versiones anteriores y fueron removidas:

| Alarma | Razon de eliminacion |
|--------|----------------------|
| ~~102~~ | Herramienta ya montada en husillo — reemplazada por `GOTO 100` (salida silenciosa) |
| ~~103~~ | ATC fuera de posicion al inicio — era redundante con el reset de salidas |
| ~~104~~ | ATC no en reposo al inicio — era redundante con el reset de salidas |
| ~~204~~ | Cono no sujetado antes de liberar — redundante con alarmas 101 y 105 |

---

## Resumen de alarmas activas (9 total)

| Alarma | Seccion | Sensor | Timeout | Descripcion corta |
|--------|---------|--------|---------|-------------------|
| 101 | 1b | P22 | — | Cono no sujetado al inicio |
| 105 | 2e | P22 | 3s | Cono no sujetado post-reset |
| 106 | 5b | P20 | 5s | Orientacion husillo no confirmada |
| 203 | 6b | P26 | 5s | ATC no llego para liberacion |
| 202 | 6e | P21 | 1.5s | Cono no se libero |
| 304 | 10a | P26 | 5s | ATC no llego para insercion |
| 301 | 10e | P22 | 3s | Cono no sujetado post-insercion |
| 303 | 10f | P25 | 5s | ATC no regreso a posicion |
| 305 | 11b | P22 | — | Cono no sujetado al finalizar |

---

## Referencia rapida de sensores

| Pin entrada | Variable macro | Funcion | Estado normal (reposo) |
|-------------|---------------|---------|----------------------|
| P20 | `#1020` | Sensor orientacion husillo | 0 = no orientado |
| P21 | `#1021` | Sensor liberacion cono | 0 = no liberado |
| P22 | `#1022` | Sensor sujecion cono | 1 = sujetado |
| P23 | `#1023` | Conteo herramientas | Pulso H/L |
| P25 | `#1025` | ATC posicion regreso | 0 = en reposo |
| P26 | `#1026` | ATC posicion trabajo | != 0 en reposo (0 = en posicion) |

## Notas tecnicas

- Todas las alarmas con timeout usan el patron `WHILE+polling` con `#3` como contador (100ms por iteracion)
- `DO3` se reutiliza en todos los polling loops (son secuenciales, nunca anidados)
- `DO1` esta reservado para el conteo de posiciones del magazin (Seccion 8)
- `DO2` esta reservado para el polling de alarma 303 (Seccion 10f)
- La variable `#1100+N` (lectura de salidas) **NO funciona** en ADTECH CNC4940 — solo usar `#1000+N` (entradas)
- P20 solo verifica **orientacion del husillo** — nunca se usa para verificar sujecion o liberacion
- P21 solo verifica **liberacion** — nunca se usa para verificar sujecion
- P22 solo verifica **sujecion** — nunca se usa para verificar liberacion
