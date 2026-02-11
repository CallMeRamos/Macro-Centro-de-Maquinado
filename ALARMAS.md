# Tabla de Alarmas - O0123 (ATC Macro)

## Controlador: ADTECH CNC4940

---

## Sensores de cono — Funciones separadas

| Sensor | Variable | Funcion dedicada | Verifica |
|--------|----------|------------------|----------|
| P20 | `#1020` | **Sujecion** | 0=sujeto, 1=no sujeto |
| P21 | `#1021` | **Liberacion** | 0=no liberado, 1=liberado |

---

## Serie 100 — Verificacion pre-vuelo (Seccion 1b y 2e)

Estas alarmas se disparan **antes** de iniciar el cambio de herramienta. Detectan condiciones anormales causadas por salidas activadas manualmente desde el teclado FCNC6D.

| Alarma | Sensor | Condicion | Timeout | Mensaje en pantalla | Accion del operador |
|--------|--------|-----------|---------|---------------------|---------------------|
| 101 | P20 (sujecion) | `#1020 == 1` | — | CONO ABIERTO - APAGUE P6 EN TECLADO Y REINTENTE T | Apagar P6 en FCNC6D, reintentar T |
| 103 | P26 (ATC pos) | `#1026 == 0` | — | ATC FUERA DE POSICION - APAGUE P21 EN TECLADO Y REINTENTE T | Apagar P21 en FCNC6D, reintentar T |
| 104 | P25 (ATC rep) | `#1025 != 0` | — | ATC NO EN REPOSO - VERIFIQUE POSICION ATC Y REINTENTE T | Verificar posicion fisica del ATC |
| 105 | P20 (sujecion) | `#1020 != 0` | 3s | CONO NO CERRO DESPUES DE RESET sensor 1 - VERIFIQUE MECANISMO | Verificar mecanismo de cierre del cono |

**Nota:** 101, 103-104 son verificaciones instantaneas. 105 espera hasta 3 segundos antes de alarmar (el cono puede tardar en asentar despues del reset de salidas).

---

## Serie 200 — Liberacion de herramienta (Seccion 6)

Estas alarmas ocurren durante la **liberacion** de la herramienta actual del husillo.

| Alarma | Sensor | Condicion | Timeout | Mensaje en pantalla | Accion del operador |
|--------|--------|-----------|---------|---------------------|---------------------|
| 202 | P21 (liberacion) | `#1021 != 1` | — | CONO NO SE LIBERO sensor 2 - VERIFIQUE MECANISMO Y REINTENTE T | Verificar mecanismo de liberacion |
| 203 | P26 (ATC pos) | `#1026 != 0` | 5s | ATC NO LLEGO A POSICION PARA LIBERACION - VERIFIQUE MECANISMO | Verificar movimiento del brazo ATC |
| 204 | P20 (sujecion) | `#1020 != 0` | 3s | CONO ABIERTO ANTES DE LIBERAR sensor 1 - VERIFIQUE CONO | Verificar estado del cono antes de liberar |

**Secuencia normal:** ATC se acerca (203 si falla) → se verifica P20 cono cerrado (204 si falla) → se libera cono → se verifica P21 cono liberado (202 si falla)

---

## Serie 300 — Insercion de herramienta y finalizacion (Secciones 10-11)

Estas alarmas ocurren durante la **insercion** de la herramienta nueva en el husillo y la verificacion final.

| Alarma | Sensor | Condicion | Timeout | Mensaje en pantalla | Accion del operador |
|--------|--------|-----------|---------|---------------------|---------------------|
| 301 | P20 (sujecion) | `#1020 != 0` | — | CONO NO CERRO DESPUES DE INSERCION sensor 1 - VERIFIQUE Y REINTENTE T | Verificar cierre del cono |
| 303 | P25 (ATC rep) | `#1025 != 0` | 5s | ATC NO REGRESO A POSICION - VERIFIQUE MECANISMO Y REINTENTE T | Verificar regreso del brazo ATC |
| 304 | P26 (ATC pos) | `#1026 != 0` | 5s | ATC NO LLEGO A POSICION PARA INSERCION - VERIFIQUE MECANISMO | Verificar movimiento del brazo ATC |
| 305 | P20 (sujecion) | `#1020 != 0` | — | CONO NO SUJETO AL FINALIZAR - VERIFIQUE ANTES DE ARRANCAR HUSILLO | Verificar sujecion antes de arrancar |

**Secuencia normal:** ATC se acerca (304 si falla) → Z baja → cono cierra → se verifica P20 cierre (301 si falla) → ATC regresa (303 si falla) → finalizacion → se verifica P20 sujecion (305 si falla)

---

## Referencia rapida de sensores

| Pin entrada | Variable macro | Funcion | Estado normal (reposo) |
|-------------|---------------|---------|----------------------|
| P20 | `#1020` | Sensor sujecion cono | 0 = sujeto |
| P21 | `#1021` | Sensor liberacion cono | 0 = no liberado |
| P23 | `#1023` | Conteo herramientas | Pulso H/L |
| P25 | `#1025` | ATC posicion regreso | 0 = en reposo |
| P26 | `#1026` | ATC posicion trabajo | 1 = en reposo (no en posicion) |

## Notas tecnicas

- Todas las alarmas con timeout usan el patron `WHILE+polling` con `#3` como contador (100ms por iteracion)
- `DO3` se reutiliza en todos los polling loops (son secuenciales, nunca anidados)
- `DO1` esta reservado para el conteo de posiciones del magazin (Seccion 8)
- `DO2` esta reservado para el polling de alarma 303 (Seccion 10f)
- La variable `#1100+N` (lectura de salidas) **NO funciona** en ADTECH CNC4940 — solo usar `#1000+N` (entradas)
- P20 solo verifica **sujecion** (cerrado/no sujeto) — nunca se usa para verificar liberacion
- P21 solo verifica **liberacion** (liberado/no liberado) — nunca se usa para verificar cierre
