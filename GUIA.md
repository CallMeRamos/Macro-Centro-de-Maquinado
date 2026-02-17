# Guia Operativa - Macro O0123 (ATC)

## Controlador: ADTECH CNC4940

---

## Que es esta macro

La macro O0123 es el programa de **cambio automatico de herramienta** (ATC) para un centro de maquinado CNC con controlador ADTECH CNC4940. Gestiona el ciclo completo: liberar la herramienta actual del husillo, rotar el magazin a la herramienta solicitada, e insertarla en el husillo.

Se ejecuta automaticamente cuando el programa CNC solicita un cambio de herramienta (comando T seguido de M06, o equivalente configurado en el controlador).
Tambien puede ejecutarse desde teclas F del panel (via `T## + M06`) cuando la llamada de origen marca `#153=1`, solo en modo JOG/MANUAL (`#3906==2`).

---

## Flujo completo paso a paso

### Seccion 1: Inicializacion (lineas 22-31)

1. Establece modo absoluto (`G90`) y sistema de coordenadas `G599`
2. Lee la herramienta actualmente montada del sistema (`#4120` → `#201`)
3. **Alarma 101:** Verifica que el cono este sujetado (P22=1) antes de hacer cualquier cosa

### Seccion 2: Reset de salidas (lineas 33-58)

Apaga todas las salidas para partir de un estado conocido:
1. Detiene rotacion del magazin (P8=0, P9=0)
2. Cancela senales del ATC (P20=0, P21=0)
3. Cierra cono (P6=0) y espera 500ms para estabilizacion
4. Cancela orientacion del husillo (P17=0)
5. **Alarma 105:** Verifica cono sujetado post-reset (P22=1, timeout 3s)

### Seccion 3: Salidas tempranas (lineas 59-61)

- Si la herramienta solicitada es 0 → sale sin cambio (`GOTO 100`)
- Si la herramienta solicitada es igual a la actual → sale sin cambio (`GOTO 100`)

### Seccion 4: Validaciones (lineas 63-77)

- Verifica que `#400` (maximo herramientas) no exceda 21
- Verifica que la herramienta solicitada y actual esten dentro del rango
- Verifica que la herramienta actual no sea 0

### Seccion 5: Retraccion y orientacion (lineas 79-94)

1. Sube Z a altura segura (`#401`)
2. Apaga refrigerante (`M09`) y husillo (`M05`)
3. Orienta husillo (`M89 P17 L1`)
4. **Alarma 106:** Espera confirmacion de orientacion (P20=1, timeout 5s)
5. Espera 2000ms post-orientacion antes de continuar

### Seccion 6: Liberacion de herramienta (lineas 96-132)

Solo se ejecuta si hay herramienta montada (`#201 != 0`):
1. Baja Z al punto de referencia (`#404`)
2. Acerca ATC al husillo (`M89 P21 L1`)
3. **Alarma 203:** Espera que ATC llegue (P26=0, timeout 5s)
4. Libera cono (`M89 P6 L1`)
5. **Alarma 202:** Verifica cono liberado (P21=1, timeout 1.5s)
6. Espera 500ms post-liberacion
7. Sube Z a altura segura y luego a retraccion completa (`#402`)

### Secciones 7-9: Rotacion del magazin (lineas 134-183)

1. **Seccion 7:** Calcula la ruta mas corta (adelante o atras) usando el algoritmo de optimizacion
2. **Seccion 8:** Cuenta posiciones mediante pulsos del sensor P23 (transiciones bajo→alto)
3. **Seccion 9:** Aplica retardo de detencion (`#408` o `#409`) y apaga rotacion

### Seccion 10: Insercion de herramienta (lineas 185-232)

1. Acerca ATC (`M89 P21 L1`)
2. **Alarma 304:** Espera que ATC llegue (P26=0, timeout 5s)
3. Baja Z a 2.5mm arriba del punto de referencia (`#403`)
4. Cierra cono (`M89 P6 L0`) y espera 1000ms
5. Baja Z al punto de referencia (`#404`) para asentar herramienta
6. **Alarma 301:** Verifica cono sujetado (P22=1, timeout 3s)
7. Cancela acercamiento ATC y regresa ATC (`M89 P20 L1`)
8. **Alarma 303:** Espera regreso ATC (P25=0, timeout 5s)
9. Cancela senal de regreso

### Seccion 11: Finalizacion (lineas 234-243)

1. Cancela orientacion del husillo (`M89 P17 L0`)
2. Sube Z a altura segura
3. Aplica compensacion de longitud (`#[409+#200]` → `#5223`)
4. **Alarma 305:** Verificacion final de cono sujetado (P22=1)

### Seccion 12: Salida (lineas 245-248)

`N100` → `M30` (fin de programa)

---

## Diagrama de flujo

```
INICIO (T##)
    |
    v
[1b] Verificar cono sujetado P22 ──NO──> ALARMA 101
    |SI
    v
[2] Reset todas las salidas
    |
    v
[2e] Verificar cono sujetado P22 (3s) ──NO──> ALARMA 105
    |SI
    v
[3] T=0 o T=actual? ──SI──> SALIDA (N100)
    |NO
    v
[4] Validar rango herramientas ──FUERA──> ALARMA 1
    |OK
    v
[5] Subir Z + Orientar husillo
    |
    v
[5b] Confirmar orientacion P20 (5s) ──NO──> ALARMA 106
    |SI
    v
[6] Hay herramienta montada? ──NO──> ir a [7]
    |SI
    v
[6b] Acercar ATC ──timeout──> ALARMA 203
    |OK
    v
[6d] Liberar cono (P6=1)
    |
    v
[6e] Verificar P21 liberado (1.5s) ──NO──> ALARMA 202
    |SI
    v
[6f] Subir Z (retraccion completa)
    |
    v
[7-9] Rotar magazin a herramienta destino
    |
    v
[10a] Acercar ATC ──timeout──> ALARMA 304
    |OK
    v
[10b-d] Bajar Z + Cerrar cono
    |
    v
[10e] Verificar P22 sujetado (3s) ──NO──> ALARMA 301
    |SI
    v
[10f] Regresar ATC ──timeout──> ALARMA 303
    |OK
    v
[11] Cancelar orientacion + Compensacion longitud
    |
    v
[11b] Verificar P22 sujetado ──NO──> ALARMA 305
    |SI
    v
FIN (M30)
```

---

## Tabla de tiempos criticos

### Retardos fijos (G04)

| Linea | Comando | Duracion | Contexto | Nota |
|-------|---------|----------|----------|------|
| 44 | `G04 P500` | 500ms | Post-cierre cono en reset | Estabilizacion mecanica |
| 94 | `G04 P2000` | 2000ms | Post-orientacion husillo | Espera antes de acercar ATC |
| 127 | `G04 P500` | 500ms | Post-liberacion cono | Espera antes de subir Z |
| 204 | `G04 P1000` | 1000ms | Post-cierre cono en insercion | Cierre mecanico del cono |

### Timeouts de alarma (polling loops)

| Alarma | Timeout | Iteraciones | Calculo |
|--------|---------|-------------|---------|
| 105 | 3s | 30 x 100ms | `#3 < 30` |
| 106 | 5s | 50 x 100ms | `#3 < 50` |
| 202 | 1.5s | 15 x 100ms | `#3 < 15` |
| 203 | 5s | 50 x 100ms | `#3 < 50` |
| 301 | 3s | 30 x 100ms | `#3 < 30` |
| 303 | 5s | 50 x 100ms | `#3 < 50` |
| 304 | 5s | 50 x 100ms | `#3 < 50` |

### Retardos de detencion del magazin (variables)

| Variable | Funcion | Valor configurado por operador |
|----------|---------|-------------------------------|
| `#408` | Retardo detencion rotacion adelante | Ajustar segun inercia del magazin |
| `#409` | Retardo detencion rotacion atras | Ajustar segun inercia del magazin |

---

## Algoritmo de ruta mas corta del magazin

El magazin es circular con `#400` posiciones (21 por defecto). El algoritmo determina si es mas rapido rotar hacia adelante o hacia atras para llegar de la herramienta actual (`#201`) a la solicitada (`#200`).

### Logica (Seccion 7, lineas 134-155)

```
Si herramienta_actual > mitad_del_magazin:
    Evalua con formula modular (N1/N4)
Sino:
    Si actual >= solicitada O solicitada > actual + mitad:
        Rotar ATRAS
    Sino:
        Rotar ADELANTE
```

El conteo se realiza en la Seccion 8 mediante:
- `M88 P23 L0 Q5000` — espera pulso bajo del sensor
- `M88 P23 L1 Q5000` — espera pulso alto del sensor
- Cada ciclo completo (bajo→alto) = una posicion avanzada
- Variable `#2` lleva la cuenta de la posicion actual
- El loop `DO1` termina cuando `#2 == #200`

---

## Troubleshooting por alarma

### Alarma 101 — CONO NO SUJETADO AL INICIO
**Causa:** El sensor P22 no detecta cono sujetado al comenzar el cambio.
**Verificar:**
- Que haya herramienta fisica en el husillo (si deberia haber)
- Sensor P22 — revisar cableado y alineacion
- Que no se haya activado P6 manualmente desde el teclado FCNC6D

### Alarma 105 — CONO NO SUJETADO DESPUES DE RESET
**Causa:** Despues de cerrar cono con `M89 P6 L0` y esperar 3s, P22 sigue sin confirmar sujecion.
**Verificar:**
- Mecanismo de cierre del cono (presion neumatica/hidraulica)
- Sensor P22 — puede estar desalineado
- Herramienta — puede estar atascada en posicion intermedia

### Alarma 106 — ORIENTACION HUSILLO NO CONFIRMADA
**Causa:** Despues de activar orientacion con `M89 P17 L1` y esperar 5s, P20 no confirma.
**Verificar:**
- Sensor P20 — cableado y alineacion
- Sistema de orientacion del husillo (servo, encoder)
- Que el husillo no este obstruido mecanicamente

### Alarma 202 — CONO NO SE LIBERO
**Causa:** Despues de activar liberacion con `M89 P6 L1` y esperar 1.5s, P21 no detecta liberacion.
**Verificar:**
- Presion neumatica/hidraulica del sistema de liberacion
- Sensor P21 — cableado y posicion
- Que la herramienta no este trabada en el cono
- **Nota:** Timeout reducido a 1.5s — si el cono no libera rapido, hay un problema mecanico

### Alarma 203 — ATC NO LLEGO PARA LIBERACION
**Causa:** ATC activado con `M89 P21 L1` pero P26 no confirma llegada en 5s.
**Verificar:**
- Movimiento mecanico del brazo ATC
- Sensor P26 — posicion y cableado
- Que la logica invertida de P21 en ADTECH este correcta
- Obstrucciones en el recorrido del brazo

### Alarma 301 — CONO NO SUJETADO POST-INSERCION
**Causa:** Despues de cerrar cono y asentar herramienta nueva, P22 no confirma sujecion en 3s.
**Verificar:**
- Que la herramienta este correctamente alineada en el cono
- Presion de cierre del mecanismo
- Sensor P22
- Que el cono no tenga residuos o desgaste

### Alarma 303 — ATC NO REGRESO A POSICION
**Causa:** ATC activado con `M89 P20 L1` pero P25 no confirma regreso en 5s.
**Verificar:**
- Movimiento del brazo ATC en direccion de regreso
- Sensor P25 — posicion y cableado
- Obstrucciones mecanicas en el recorrido

### Alarma 304 — ATC NO LLEGO PARA INSERCION
**Causa:** ATC activado con `M89 P21 L1` pero P26 no confirma llegada en 5s.
**Verificar:**
- Mismas causas que alarma 203 (mismo mecanismo, diferente etapa)
- Verificar que el ATC no se haya quedado en posicion intermedia

### Alarma 305 — CONO NO SUJETADO AL FINALIZAR
**Causa:** Verificacion final antes de permitir arranque de husillo — P22 no muestra sujecion.
**Verificar:**
- Herramienta en el husillo — puede haberse aflojado durante el regreso del ATC
- Sensor P22
- **CRITICO:** No arrancar husillo sin resolver esta alarma — riesgo de expulsar herramienta

---

## Variables configurables por el operador

| Variable | Funcion | Rango tipico | Precaucion |
|----------|---------|--------------|------------|
| `#400` | Numero maximo de herramientas en magazin | 1-21 | No exceder 21, debe coincidir con magazin fisico |
| `#401` | Altura segura Z (mm) | Depende de maquina | Debe estar por encima de cualquier pieza/fijacion |
| `#402` | Retraccion completa Z (mm) | Depende de maquina | Posicion mas alta del eje Z |
| `#403` | Z 2.5mm arriba de referencia (mm) | `#404` + 2.5 | Posicion de pre-insercion |
| `#404` | Punto de referencia Z (mm) | Depende de maquina | Posicion exacta de acople herramienta |
| `#405` | Velocidad de avance F (mm/min) | 500-2000 | Velocidades muy altas pueden causar colisiones |
| `#408` | Retardo detencion adelante (ms) | 50-500 | Ajustar segun inercia — demasiado bajo = sobrepaso |
| `#409` | Retardo detencion atras (ms) | 50-500 | Ajustar segun inercia — demasiado bajo = sobrepaso |
| `#410`-`#430` | Compensacion longitud T1-T21 (mm) | Medidos | `#[409+N]` donde N = numero de herramienta |

---

## Condiciones de salida temprana

La macro puede terminar sin realizar cambio de herramienta en estos casos:

| Condicion | Linea | Comportamiento |
|-----------|-------|----------------|
| `#200 == 0` | 60 | Salto silencioso a N100 (M30) |
| `#200 == #201` | 61 | Salto silencioso a N100 (M30) — herramienta ya montada |

En ambos casos, la macro ejecuta el reset de salidas (Seccion 2) antes de salir, lo cual es intencional para dejar el sistema en estado limpio.
