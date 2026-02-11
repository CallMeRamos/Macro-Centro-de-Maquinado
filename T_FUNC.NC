O0123 (Macro de cambio automatico de herramienta - DEFINITIVO)
(=========================================================)
(  TABLA DE SENALES I/O - ADTECH CNC4940                  )
(=========================================================)
(  SALIDAS [M89]:                                         )
(    P6  : L1=liberar cono / L0=cerrar cono               )
(    P8  : L1=rotacion magazin adelante / L0=detener      )
(    P9  : L1=rotacion magazin atras / L0=detener         )
(    P17 : L1=orientar husillo / L0=cancelar orientacion  )
(    P20 : L1=regresar ATC / L0=cancelar regreso          )
(    P21 : L1=acercar ATC / L0=cancelar [INVERTIDO ADTECH])
(                                                          )
(  ENTRADAS [M88]:                                         )
(    P20 : L0=cono cerrado / L1=cono liberado [sensor 1]  )
(    P21 : L0=cono cerrado / L1=cono liberado [sensor 2]  )
(    P23 : sensor conteo herramientas [pulso H/L]         )
(    P25 : L0=ATC en posicion de regreso                  )
(    P26 : L0=ATC en posicion de trabajo                  )
(=========================================================)

(--- SECCION 1: INICIALIZACION ---)
G90 G599 (programacion absoluta, sistema de coordenadas G599 para cambio de herramienta)
#201=#4120 (lee numero de herramienta actual del sistema)

(--- SECCION 1b: VERIFICACION PRE-VUELO DE I/O ---)
(Si alguna alarma se activa: APAGUE la salida en teclado FCNC6D y reintente)

(Verificar cono cerrado - detecta P6 activado desde teclado)
IF[#1020 == 1]
{
	#3000=101 (CONO ABIERTO - APAGUE P6 EN TECLADO Y REINTENTE T)
}
IF[#1021 == 1]
{
	#3000=102 (CONO ABIERTO sensor 2 - APAGUE P6 EN TECLADO Y REINTENTE T)
}

(Verificar ATC en reposo - detecta P21 activado desde teclado)
IF[#1026 == 0]
{
	#3000=103 (ATC FUERA DE POSICION - APAGUE P21 EN TECLADO Y REINTENTE T)
}

(--- SECCION 2: RESET COMPLETO DE SALIDAS ---)
(--- 2a: Detener movimientos del magazin ---)
M89 P8 L0 (detiene rotacion carrusel adelante)
M89 P9 L0 (detiene rotacion carrusel atras)

(--- 2b: Cancelar senales ATC ---)
M89 P20 L0 (cancela regreso ATC si estaba activo desde teclado)
M89 P21 L0 (cancela acercamiento ATC)

(--- 2c: Asegurar cono cerrado ---)
M89 P6 L0 (cierra cono - asegura sujecion de herramienta)
G04 P500 (espera 500ms para estabilizacion del mecanismo de cierre)

(--- 2d: Cancelar orientacion husillo ---)
M89 P17 L0 (cancela orientacion del husillo)

(--- 2e: Verificacion post-reset - confirma cono cerrado ---)
M88 P20 L0 Q3000 (confirma sensor 1: cono cerrado, alarma 3s)
M88 P21 L0 Q3000 (confirma sensor 2: cono cerrado, alarma 3s)

(--- SECCION 3: SALIDAS TEMPRANAS ---)
IF[[#200] == 0]GOTO 100 (si herramienta solicitada es 0, sale del cambio)
IF[[#200] == #201]GOTO 100 (si herramienta actual es igual a la solicitada, sale)

(--- SECCION 4: VALIDACIONES ---)
IF[#400 > 21] (alarma si el maximo de herramientas excede 21)
{
	#3000=1 (Error: numero de herramienta excede el maximo del magazin)
}

IF[[[#200] > [#400]] || [[#201] > [#400]]] (alarma si herramienta solicitada o actual excede el maximo)
{
	#3000=1 (Error: numero de herramienta excede el maximo del magazin)
}

IF[#201==0] (alarma si herramienta actual es 0)
{
	#3000=1 (Error: numero de herramienta actual es cero)
}

(--- SECCION 5: PREPARACION - RETRACCION Y ORIENTACION ---)
G01 Z[#401] F#405 (sube Z a altura segura)
M09 (apaga refrigerante)
M05 (detiene husillo antes de orientar)
M89 P17 L1 (orienta husillo)
G04 P2000 (espera 2000ms para orientacion de husillo)

(--- SECCION 6: LIBERACION DE HERRAMIENTA ACTUAL ---)
IF[[#201]!=0] (ejecuta solo si hay herramienta montada)
{
	(--- 6a: bajar Z al punto de referencia ---)
	G01 Z[#404] F#405 (baja Z al punto de referencia)

	(--- 6b: acercar ATC ---)
	M89 P21 L1 (acerca ATC al husillo)
	M88 P26 L0 Q5000 (espera sensor ATC en posicion de trabajo, alarma 5s)

	(--- 6c: PRE-CHECK - verificar sensores muestran cono CERRADO antes de liberar ---)
	M88 P20 L0 Q3000 (confirma sensor 1 HIGH = cono cerrado antes de liberar, alarma 3s)
	M88 P21 L0 Q3000 (confirma sensor 2 HIGH = cono cerrado antes de liberar, alarma 3s)

	(--- 6d: liberar cono ---)
	M89 P6 L1 (libera cono del husillo)
	G04 P500 (espera 500ms para mecanismo de liberacion)

	(--- 6e: POST-CHECK - verificar sensores muestran cono LIBERADO ---)
	M88 P20 L1 Q3000 (confirma sensor 1 LOW = cono liberado, alarma 3s)
	M88 P21 L1 Q3000 (confirma sensor 2 LOW = cono liberado, alarma 3s)

	(--- 6f: retraccion Z ---)
	G01 Z[#401] F#405 (sube Z para separar herramienta del husillo)
	G01 Z[#402] F#405 (sube Z a retraccion completa)
}

(--- SECCION 7: ALGORITMO DE ROTACION OPTIMA DEL MAGAZIN ---)
#1=0 (indicador de direccion: 0=adelante, 1=atras)
IF[#201 > [#400/2]] GOTO 1
IF[[#201 >= #200] || [#200 > [#201+[#400/2]]]] GOTO 2
M89 P8 L1 (rotacion carrusel adelante)
#1=0 (indicador = adelante)
GOTO 3

N2
M89 P9 L1 (rotacion carrusel atras)
#1=1 (indicador = atras)
GOTO 3

N1
IF[[#201 >= #200 && #200 <= #400] && [#200 > [#201+#400/2]MOD#400]] GOTO 4
M89 P8 L1 (rotacion carrusel adelante)
#1=0 (indicador = adelante)
GOTO 3

N4
M89 P9 L1 (rotacion carrusel atras)
#1=1 (indicador = atras)

(--- SECCION 8: CONTEO DE POSICIONES ---)
N3
#2=#201 (guarda herramienta actual en variable temporal)
WHILE[#2!=#200] DO1 (repite hasta llegar a herramienta solicitada)
	M88 P23 L0 Q5000 (espera senal conteo en bajo, alarma 5s)
	M88 P23 L1 Q5000 (espera senal conteo en alto, alarma 5s)
	IF[#1==1] GOTO 7 (si rotacion es atras, salta a N7)
	#2 = #2+1 (avanza una posicion adelante)
	IF[#2>#400] #2=1 (reinicia a 1 si excede maximo del magazin)
	GOTO 8
	N7
	#2 = #2-1 (retrocede una posicion)
	IF[#2<=0] #2=#400 (reinicia al maximo si llega a 0 o menor)

	N8

END1 (fin del ciclo WHILE de conteo)

(--- SECCION 9: DETENCION DE ROTACION ---)
IF[#1==1] GOTO 5
G04 P#408 (retardo para detener rotacion adelante)
M89 P8 L0 (apaga senal de rotacion adelante)
GOTO 6

N5
G04 P#409 (retardo para detener rotacion atras)
M89 P9 L0 (apaga senal de rotacion atras)

(--- SECCION 10: INSERCION DE HERRAMIENTA NUEVA ---)
N6
(--- 10a: acercar ATC ---)
M89 P21 L1 (acerca ATC al husillo)
M88 P26 L0 Q5000 (espera sensor ATC en posicion de trabajo, alarma 5s)

(--- 10b: bajar Z a posicion de insercion ---)
G01 Z[#403] F#405 (baja Z a 2.5mm arriba del punto de referencia)

(--- 10c: cerrar cono ---)
M89 P6 L0 (cierra cono del husillo)
G04 P1000 (espera 1000ms para cierre mecanico del cono)

(--- 10d: bajar Z al punto de referencia ---)
G01 Z[#404] F#405 (baja Z al punto de referencia para asentar herramienta)

(--- 10e: POST-CHECK - verificar sensores muestran cono CERRADO ---)
M88 P20 L0 Q3000 (confirma sensor 1 HIGH = cono cerrado, alarma 3s)
M88 P21 L0 Q3000 (confirma sensor 2 HIGH = cono cerrado, alarma 3s)

(--- 10f: regresar ATC ---)
M89 P21 L0 (cancela senal de acercamiento ATC)
M89 P20 L1 (regresa ATC a posicion inicial)
M88 P25 L0 Q5000 (espera sensor regreso ATC, alarma 5s)
M89 P20 L0 (cancela senal de regreso ATC)

(--- SECCION 11: FINALIZACION ---)
M89 P17 L0 (cancela orientacion del husillo)
G01 Z[#401] F#405 (sube Z a altura segura)
#5223=#[409+#200] (aplica compensacion de longitud de herramienta en sistema de coordenadas)

(--- SECCION 12: SALIDA ---)
N100
M30
%
